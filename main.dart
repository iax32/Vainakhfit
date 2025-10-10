import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

enum Gender { female, male, other }

/// Built-in exercise catalog (single source of truth)
List<Exercise> builtInExercises() => [
  // Chest
  Exercise(name: 'Bench Press', muscle: 'Chest', description: 'Barbell bench press targeting chest, triceps and anterior deltoids.'),
  Exercise(name: 'Incline Dumbbell Press', muscle: 'Chest', description: 'Dumbbells on incline bench; emphasize upper chest.'),
  Exercise(name: 'Push-up', muscle: 'Chest', description: 'Bodyweight push; hands shoulder-width, neutral spine.'),
  // Back
  Exercise(name: 'Deadlift', muscle: 'Back', description: 'Posterior chain compound: hinge with neutral back.'),
  Exercise(name: 'Pull-up', muscle: 'Back', description: 'Overhand grip; chest to bar; full hang to chin over bar.'),
  Exercise(name: 'Barbell Row', muscle: 'Back', description: 'Hinge to ~45°, row bar to lower chest / upper abs.'),
  // Legs
  Exercise(name: 'Back Squat', muscle: 'Legs', description: 'Bar on traps; squat below parallel with stable knees.'),
  Exercise(name: 'Front Squat', muscle: 'Legs', description: 'Bar on front rack; more quad emphasis.'),
  Exercise(name: 'Romanian Deadlift', muscle: 'Legs', description: 'Hip hinge; hamstrings stretch; slight knee bend.'),
  // Shoulders
  Exercise(name: 'Overhead Press', muscle: 'Shoulders', description: 'Press bar to overhead; brace core, glutes.'),
  Exercise(name: 'Lateral Raise', muscle: 'Shoulders', description: 'Dumbbells out to sides to shoulder height.'),
  // Arms
  Exercise(name: 'Dumbbell Curl', muscle: 'Arms', description: 'Elbows pinned; curl without swinging.'),
  Exercise(name: 'Triceps Pushdown', muscle: 'Arms', description: 'Cable pushdown; elbows tucked, full extension.'),
  // Core
  Exercise(name: 'Plank', muscle: 'Core', description: 'Hold a straight line from head to heels; brace abs and glutes.'),
  Exercise(name: 'Hanging Leg Raise', muscle: 'Core', description: 'Raise legs to 90°; avoid swinging.'),
  // Full Body / Cardio
  Exercise(name: 'Kettlebell Swing', muscle: 'Full Body', description: 'Hip drive; swing bell to chest height.'),
  Exercise(name: 'Burpee', muscle: 'Cardio', description: 'Squat to plank, push-up, return and jump.'),
];

String _genId() => DateTime.now().microsecondsSinceEpoch.toString();

/// ---------- NEW: global storage keys ----------
const String _kActiveWorkout = 'active_workout_json';
const String _kPrimaryColor  = 'primary_color_argb';
const String _kPrevPrimaryColor  = 'prev_primary_color_argb';
const String _kWeightHistory = 'weight_history_json';

/// ---------- Models ----------
class Exercise {
  String name;
  String muscle; // Chest, Back, Legs, Shoulders, Arms, Core, Full Body, Cardio, Other
  String? description;

  Exercise({required this.name, required this.muscle, this.description});

  Map<String, dynamic> toJson() =>
      {'name': name, 'muscle': muscle, 'description': description};

  factory Exercise.fromJson(Map<String, dynamic> j) =>
      Exercise(name: j['name'], muscle: j['muscle'] ?? 'Other', description: j['description']);
}

class PlanExercise {
  String name;
  int sets;
  int reps;
  double? weightKg;
  PlanExercise({required this.name, required this.sets, required this.reps, this.weightKg});

  Map<String, dynamic> toJson() =>
      {'name': name, 'sets': sets, 'reps': reps, 'weightKg': weightKg};

  factory PlanExercise.fromJson(Map<String, dynamic> j) => PlanExercise(
    name: j['name'],
    sets: j['sets'],
    reps: j['reps'],
    weightKg: (j['weightKg'] as num?)?.toDouble(),
  );
}

class WorkoutPlan {
  /// Unique identifier to avoid title collisions.
  final String id;
  String title;
  List<PlanExercise> items;

  /// Weekly schedule; empty = no schedule
  /// 1..7 where 1=Mon ... 7=Sun (matches DateTime.weekday)
  List<int> scheduleWeekdays;

  WorkoutPlan({
    required this.id,
    required this.title,
    required this.items,
    this.scheduleWeekdays = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'items': items.map((e) => e.toJson()).toList(),
    'scheduleWeekdays': scheduleWeekdays,
  };

  factory WorkoutPlan.fromJson(Map<String, dynamic> j) => WorkoutPlan(
    id: (j['id'] as String?) ?? _genId(),
    title: j['title'] as String,
    items: (j['items'] as List)
        .map((e) => PlanExercise.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    scheduleWeekdays: (j['scheduleWeekdays'] as List?)?.cast<int>() ?? const [],
  );

  WorkoutPlan copyWith({
    String? id,
    String? title,
    List<PlanExercise>? items,
    List<int>? scheduleWeekdays,
  }) =>
      WorkoutPlan(
        id: id ?? this.id,
        title: title ?? this.title,
        items: items ?? this.items,
        scheduleWeekdays: scheduleWeekdays ?? this.scheduleWeekdays,
      );
}

class WorkoutSetLog {
  String exercise;
  int reps;
  double? weightKg;
  WorkoutSetLog({required this.exercise, required this.reps, this.weightKg});

  Map<String, dynamic> toJson() =>
      {'exercise': exercise, 'reps': reps, 'weightKg': weightKg};

  factory WorkoutSetLog.fromJson(Map<String, dynamic> j) => WorkoutSetLog(
    exercise: j['exercise'],
    reps: j['reps'],
    weightKg: (j['weightKg'] as num?)?.toDouble(),
  );
}

class WorkoutSession {
  DateTime startedAt;
  DateTime? endedAt;
  int? durationSeconds;
  List<WorkoutSetLog> sets;
  WorkoutSession({required this.startedAt, this.endedAt, this.durationSeconds, required this.sets});

  Map<String, dynamic> toJson() => {
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'durationSeconds': durationSeconds,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> j) => WorkoutSession(
    startedAt: DateTime.parse(j['startedAt']),
    endedAt: j['endedAt'] != null ? DateTime.parse(j['endedAt']) : null,
    durationSeconds: (j['durationSeconds'] as num?)?.toInt(),
    sets: (j['sets'] as List)
        .map((e) => WorkoutSetLog.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

/// Per-exercise PR
class ExercisePR {
  String name;
  int maxReps;
  double? maxWeightKg;
  ExercisePR({required this.name, this.maxWeightKg, this.maxReps = 0});

  Map<String, dynamic> toJson() => {
    'name': name,
    'maxReps': maxReps,
    'maxWeightKg': maxWeightKg,
  };

  factory ExercisePR.fromJson(Map<String, dynamic> j) => ExercisePR(
    name: j['name'],
    maxReps: (j['maxReps'] ?? 0) as int,
    maxWeightKg: (j['maxWeightKg'] as num?)?.toDouble(),
  );
}

/// A planned (not yet completed) set row shown under an exercise.
class SetTarget {
  int reps;
  double? weightKg;
  SetTarget({required this.reps, this.weightKg});

  // NEW: serialization
  Map<String, dynamic> toJson() => {'reps': reps, 'weightKg': weightKg};
  factory SetTarget.fromJson(Map<String, dynamic> j) =>
      SetTarget(reps: (j['reps'] as num).toInt(), weightKg: (j['weightKg'] as num?)?.toDouble());
}

/// One exercise inside the running workout with its own rest setting/timer and logs
class ActiveExerciseEntry {
  String name;
  int restSeconds; // 0,30,60,90,120
  int? targetSets;
  int? targetReps;
  double? targetWeight;

  /// Planned (editable) rows — Lyfta/Hevy style
  final List<SetTarget> planned = [];

  /// Completed sets
  List<WorkoutSetLog> logs = [];
  int restCountdown = 0;

  ActiveExerciseEntry({
    required this.name,
    this.restSeconds = 60,
    this.targetSets,
    this.targetReps,
    this.targetWeight,
  });

  // NEW: serialization
  Map<String, dynamic> toJson() => {
    'name': name,
    'restSeconds': restSeconds,
    'targetSets': targetSets,
    'targetReps': targetReps,
    'targetWeight': targetWeight,
    'planned': planned.map((e) => e.toJson()).toList(),
    'logs': logs.map((l) => l.toJson()).toList(),
    'restCountdown': restCountdown,
  };

  factory ActiveExerciseEntry.fromJson(Map<String, dynamic> j) {
    final e = ActiveExerciseEntry(
      name: j['name'],
      restSeconds: (j['restSeconds'] as num?)?.toInt() ?? 60,
      targetSets: (j['targetSets'] as num?)?.toInt(),
      targetReps: (j['targetReps'] as num?)?.toInt(),
      targetWeight: (j['targetWeight'] as num?)?.toDouble(),
    );
    final planned =
        (j['planned'] as List?)?.map((x) => SetTarget.fromJson(Map<String, dynamic>.from(x))).toList() ?? [];
    e.planned.addAll(planned);
    e.logs =
        (j['logs'] as List?)?.map((x) => WorkoutSetLog.fromJson(Map<String, dynamic>.from(x))).toList() ?? [];
    e.restCountdown = (j['restCountdown'] as num?)?.toInt() ?? 0;
    return e;
  }
}

/// active workout state
class ActiveWorkout {
  final DateTime startedAt;
  final WorkoutPlan? fromPlan;
  final List<ActiveExerciseEntry> entries;
  ActiveWorkout({required this.startedAt, this.fromPlan, required this.entries});

  // NEW: serialization
  Map<String, dynamic> toJson() => {
    'startedAt': startedAt.toIso8601String(),
    'fromPlan': fromPlan?.toJson(),
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  factory ActiveWorkout.fromJson(Map<String, dynamic> j) {
    return ActiveWorkout(
      startedAt: DateTime.parse(j['startedAt']),
      fromPlan: j['fromPlan'] == null ? null : WorkoutPlan.fromJson(Map<String, dynamic>.from(j['fromPlan'])),
      entries: (j['entries'] as List).map((e) => ActiveExerciseEntry.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}

/// NEW: weight log point
class WeightPoint {
  final DateTime at;
  final double kg;
  WeightPoint(this.at, this.kg);

  Map<String, dynamic> toJson() => {'at': at.toIso8601String(), 'kg': kg};
  factory WeightPoint.fromJson(Map<String, dynamic> j) =>
      WeightPoint(DateTime.parse(j['at']), (j['kg'] as num).toDouble());
}

/// ---------- Inherited scope ----------
class AppState extends ChangeNotifier {
  static const _kThemeKey = 'theme_mode'; // system|light|dark
  static const _kHeight = 'height_cm';
  static const _kWeight = 'weight_kg';
  static const _kGender = 'gender_index';
  static const _kPlans = 'plans_json';
  static const _kExercises = 'exercises_json';
  static const _kWorkoutLogs = 'workout_logs_json';
  static const _kPRs = 'prs_json';
  static const _kDataVersion = 'data_version';

  ThemeMode themeMode = ThemeMode.system;

  double? heightCm;
  double? weightKg;
  Gender? gender;

  List<WorkoutPlan> plans = [];
  List<Exercise> customExercises = [];
  List<WorkoutSession> sessions = [];
  Map<String, ExercisePR> prs = {}; // key: exercise name

  // Active workout
  ActiveWorkout? active;
  Timer? _ticker;

  // NEW: dynamic primary color + weight history
  Color primaryColor = AppTheme.crimson;
  List<WeightPoint> weightHistory = [];

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // simple data versioning hook
    final int ver = _prefs.getInt(_kDataVersion) ?? 1;
    if (ver < 1) {
      await _prefs.setInt(_kDataVersion, 1);
    }

    // Theme
    themeMode = _themeFromString(_prefs.getString(_kThemeKey) ?? 'system');

    // Profile
    heightCm = _prefs.getDouble(_kHeight);
    weightKg = _prefs.getDouble(_kWeight);
    final gi = _prefs.getInt(_kGender);
    if (gi != null && gi >= 0 && gi < Gender.values.length) {
      gender = Gender.values[gi];
    }

    // Plans
    try {
      final plansRaw = _prefs.getString(_kPlans);
      if (plansRaw != null && plansRaw.isNotEmpty) {
        plans = (jsonDecode(plansRaw) as List)
            .map((e) => WorkoutPlan.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      plans = [];
      await _prefs.remove(_kPlans);
    }

    // Custom exercises
    try {
      final exRaw = _prefs.getString(_kExercises);
      if (exRaw != null && exRaw.isNotEmpty) {
        customExercises = (jsonDecode(exRaw) as List)
            .map((e) => Exercise.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      customExercises = [];
      await _prefs.remove(_kExercises);
    }

    // Sessions
    try {
      final logsRaw = _prefs.getString(_kWorkoutLogs);
      if (logsRaw != null && logsRaw.isNotEmpty) {
        sessions = (jsonDecode(logsRaw) as List)
            .map((e) => WorkoutSession.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      sessions = [];
      await _prefs.remove(_kWorkoutLogs);
    }

    // PRs
    try {
      final prRaw = _prefs.getString(_kPRs);
      if (prRaw != null && prRaw.isNotEmpty) {
        final obj = jsonDecode(prRaw) as Map<String, dynamic>;
        prs = obj.map((k, v) => MapEntry(k, ExercisePR.fromJson(Map<String, dynamic>.from(v))));
      }
    } catch (_) {
      prs = {};
      await _prefs.remove(_kPRs);
    }

    // NEW: theme primary color
    final argb = _prefs.getInt(_kPrimaryColor);
    if (argb != null) primaryColor = Color(argb);

    // NEW: load weight history
    try {
      final raw = _prefs.getString(_kWeightHistory);
      if (raw != null && raw.isNotEmpty) {
        final arr = (jsonDecode(raw) as List)
            .map((e) => WeightPoint.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        weightHistory = arr..sort((a, b) => a.at.compareTo(b.at));
      }
    } catch (_) {
      weightHistory = [];
    }

    // NEW: restore active workout if present + resume timers based on savedAt
    try {
      final aRaw = _prefs.getString(_kActiveWorkout);
      if (aRaw != null && aRaw.isNotEmpty) {
        final map = jsonDecode(aRaw) as Map<String, dynamic>;
        final savedAt = map['savedAt'] != null ? DateTime.parse(map['savedAt']) : DateTime.now();
        active = ActiveWorkout.fromJson(map);
        final elapsed = DateTime.now().difference(savedAt).inSeconds;
        for (final e in active!.entries) {
          e.restCountdown = (e.restCountdown - elapsed).clamp(0, 1000000);
        }
        _startTicker();
      }
    } catch (_) {
      active = null;
      await _prefs.remove(_kActiveWorkout);
    }

    notifyListeners();
  }

  // THEME
  Future<void> setTheme(ThemeMode mode) async {
    themeMode = mode;
    await _prefs.setString(_kThemeKey, _themeToString(mode));
    notifyListeners();
  }

  // PROFILE
  Future<void> saveHeight(double? v) async {
    heightCm = v;
    if (v == null) {
      await _prefs.remove(_kHeight);
    } else {
      await _prefs.setDouble(_kHeight, v);
    }
    notifyListeners();
  }

  Future<void> saveWeight(double? v) async {
    weightKg = v;
    if (v == null) {
      await _prefs.remove(_kWeight);
    } else {
      await _prefs.setDouble(_kWeight, v);
    }
    notifyListeners();
  }

  Future<void> saveGender(Gender? g) async {
    gender = g;
    if (g == null) {
      await _prefs.remove(_kGender);
    } else {
      await _prefs.setInt(_kGender, g.index);
    }
    notifyListeners();
  }

  // PLANS
  Future<void> addPlan(WorkoutPlan p) async {
    plans.add(p);
    await _prefs.setString(_kPlans, jsonEncode(plans.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> deletePlan(int index) async {
    plans.removeAt(index);
    await _prefs.setString(_kPlans, jsonEncode(plans.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> updatePlanById(String id, WorkoutPlan newPlan) async {
    final idx = plans.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    plans[idx] = newPlan.copyWith(id: id);
    await _prefs.setString(_kPlans, jsonEncode(plans.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  /// Build a suggested updated plan from the current active entries.
  /// Returns null if there is no original plan, or nothing materially changed.
  WorkoutPlan? proposeUpdatedPlanFromActive() {
    if (active?.fromPlan == null) return null;
    final original = active!.fromPlan!;

    double? _pickWeight(ActiveExerciseEntry e) =>
        e.targetWeight ?? (e.logs.isNotEmpty ? e.logs.last.weightKg : null);

    int _pickReps(ActiveExerciseEntry e) =>
        e.targetReps ?? (e.logs.isNotEmpty ? e.logs.last.reps : 10);

    int _pickSets(ActiveExerciseEntry e) =>
        e.targetSets ?? (e.logs.isNotEmpty ? e.logs.length : 3);

    List<PlanExercise> newItems = active!.entries.map((e) {
      return PlanExercise(
        name: e.name,
        sets: _pickSets(e),
        reps: _pickReps(e),
        weightKg: _pickWeight(e),
      );
    }).toList();

    bool _eqD(double? x, double? y) =>
        (x == null && y == null) || (x != null && y != null && (x - y).abs() < 1e-9);

    bool sameLength = newItems.length == original.items.length;
    bool allSame = sameLength;
    if (sameLength) {
      for (int i = 0; i < newItems.length; i++) {
        final a = newItems[i], b = original.items[i];
        if (a.name != b.name || a.sets != b.sets || a.reps != b.reps || !_eqD(a.weightKg, b.weightKg)) {
          allSame = false; break;
        }
      }
    } else {
      allSame = false;
    }
    if (allSame) return null;
    return original.copyWith(items: newItems);
  }

  // EXERCISES (custom)
  Future<void> addCustomExercise(Exercise e) async {
    customExercises.add(e);
    await _prefs.setString(
      _kExercises,
      jsonEncode(customExercises.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> deleteCustomExerciseAt(int index) async {
    if (index < 0 || index >= customExercises.length) return;
    customExercises.removeAt(index);
    await _prefs.setString(
      _kExercises,
      jsonEncode(customExercises.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> editCustomExercise(int index, Exercise updated) async {
    if (index < 0 || index >= customExercises.length) return;
    customExercises[index] = updated;
    await _prefs.setString(
      _kExercises,
      jsonEncode(customExercises.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  // SESSIONS
  Future<void> _persistSessions() async {
    await _prefs.setString(
      _kWorkoutLogs,
      jsonEncode(sessions.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addSession(WorkoutSession s) async {
    sessions.add(s);
    // keep newest first for UX
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    await _persistSessions();
    notifyListeners();
  }

  Future<void> removeSessionAt(int index) async {
    if (index < 0 || index >= sessions.length) return;
    sessions.removeAt(index);
    await _persistSessions();
    notifyListeners();
  }

  // ---------- Active workout control ----------
  void startActiveWorkout({WorkoutPlan? plan}) {
    if (active != null) return;
    final entries = <ActiveExerciseEntry>[];
    if (plan != null) {
      for (final pe in plan.items) {
        final e = ActiveExerciseEntry(
          name: pe.name,
          targetSets: pe.sets,
          targetReps: pe.reps,
          targetWeight: pe.weightKg,
          restSeconds: 60,
        );
        // Seed planned rows from plan
        final count = (pe.sets).clamp(1, 100);
        for (int i = 0; i < count; i++) {
          e.planned.add(SetTarget(reps: pe.reps, weightKg: pe.weightKg));
        }
        entries.add(e);
      }
    }
    active = ActiveWorkout(startedAt: DateTime.now(), fromPlan: plan, entries: entries);
    _startTicker();
    _persistActive();
    notifyListeners();
  }

  void addExerciseToActive(String name) {
    if (active == null) return;
    active!.entries.add(ActiveExerciseEntry(name: name, restSeconds: 60));
    notifyListeners();
    _persistActive();
  }

  // Legacy add log directly (still used by edits)
  void addSetToEntry(int entryIndex, WorkoutSetLog s) {
    if (active == null) return;
    active!.entries[entryIndex].logs.add(s);
    active!.entries[entryIndex].restCountdown = active!.entries[entryIndex].restSeconds;
    notifyListeners();
    _persistActive();
  }

  void editSet(int entryIndex, int logIndex, {int? reps, double? weight}) {
    final e = active!.entries[entryIndex].logs[logIndex];
    if (reps != null) e.reps = reps;
    if (weight != null) e.weightKg = weight;
    notifyListeners();
    _persistActive();
  }

  void deleteSet(int entryIndex, int logIndex) {
    active!.entries[entryIndex].logs.removeAt(logIndex);
    notifyListeners();
    _persistActive();
  }

  /// Add a planned (uncompleted) set row to an exercise
  void addPlannedSet(int entryIndex, {int? reps, double? weight}) {
    final e = active?.entries[entryIndex];
    if (e == null) return;
    final r = reps ?? e.targetReps ?? 10;
    final w = weight ?? e.targetWeight;
    e.planned.add(SetTarget(reps: r, weightKg: w));
    notifyListeners();
    _persistActive();
  }

  /// Remove an uncompleted planned row
  void removePlannedSet(int entryIndex, int plannedIndex) {
    final e = active?.entries[entryIndex];
    if (e == null) return;
    if (plannedIndex < 0 || plannedIndex >= e.planned.length) return;
    e.planned.removeAt(plannedIndex);
    notifyListeners();
    _persistActive();
  }

  /// Mark a planned row completed -> create log, start rest, drop the planned row
  void completePlannedSet(int entryIndex, int plannedIndex, {int? reps, double? weight}) {
    final e = active?.entries[entryIndex];
    if (e == null) return;
    if (plannedIndex < 0 || plannedIndex >= e.planned.length) return;

    final row = e.planned[plannedIndex];
    final r = reps ?? row.reps;
    final w = weight ?? row.weightKg;

    e.logs.add(WorkoutSetLog(exercise: e.name, reps: r, weightKg: w));
    e.restCountdown = e.restSeconds;
    e.planned.removeAt(plannedIndex);
    notifyListeners();
    _persistActive();
  }

  void setRestPref(int entryIndex, int seconds) {
    active!.entries[entryIndex].restSeconds = seconds;
    notifyListeners();
    _persistActive();
  }

  void tickRest() {
    if (active == null) return;
    for (final e in active!.entries) {
      if (e.restCountdown > 0) e.restCountdown--;
    }
  }

  /// Ends workout, saves session, updates PRs, returns the saved session.
  Future<WorkoutSession?> endActiveWorkoutAndSave() async {
    if (active == null) return null;
    final end = DateTime.now();
    final started = active!.startedAt;
    final dur = end.difference(started).inSeconds;

    // Flatten all logs
    final flat = <WorkoutSetLog>[];
    for (final e in active!.entries) {
      for (final l in e.logs) {
        flat.add(WorkoutSetLog(exercise: e.name, reps: l.reps, weightKg: l.weightKg));
        // update PR tracking (in-memory first)
        final pr = prs[e.name] ?? ExercisePR(name: e.name);
        if (l.weightKg != null) {
          if (pr.maxWeightKg == null || (l.weightKg! > pr.maxWeightKg!)) {
            pr.maxWeightKg = l.weightKg;
          }
        }
        if (l.reps > pr.maxReps) pr.maxReps = l.reps;
        prs[e.name] = pr;
      }
    }

    // Persist PRs
    await _prefs.setString(_kPRs, jsonEncode(prs.map((k, v) => MapEntry(k, v.toJson()))));

    // Save session
    final session = WorkoutSession(
      startedAt: started,
      endedAt: end,
      durationSeconds: dur,
      sets: flat,
    );
    await addSession(session);

    _cancelTicker();
    await _prefs.remove(_kActiveWorkout);
    active = null;
    notifyListeners();
    return session;
  }

  Duration get activeElapsed =>
      active == null ? Duration.zero : DateTime.now().difference(active!.startedAt);

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      tickRest();
      // persist every 5s to keep rest timers robust
      if (DateTime.now().second % 5 == 0) _persistActive();
      notifyListeners();
    });
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  // NEW: persist active workout (with savedAt for resume math)
  Future<void> _persistActive() async {
    if (active == null) {
      await _prefs.remove(_kActiveWorkout);
      return;
    }
    final map = active!.toJson();
    map['savedAt'] = DateTime.now().toIso8601String();
    await _prefs.setString(_kActiveWorkout, jsonEncode(map));
  }

  // NEW: replace/delete exercise in active
  void replaceActiveExercise(int entryIndex, String newName) {
    if (active == null) return;
    final e = active!.entries[entryIndex];
    e.name = newName;
    for (final l in e.logs) {
      l.exercise = newName;
    }
    notifyListeners();
    _persistActive();
  }

  void deleteActiveExercise(int entryIndex) {
    if (active == null) return;
    if (entryIndex < 0 || entryIndex >= active!.entries.length) return;
    active!.entries.removeAt(entryIndex);
    notifyListeners();
    _persistActive();
  }

  // NEW: export/import plans json
  String exportPlansJson({List<String>? planIds}) {
    final sel = planIds == null ? plans : plans.where((p) => planIds.contains(p.id)).toList();
    return jsonEncode(sel.map((p) => p.toJson()).toList());
  }

  Future<(int added, int skipped)> importPlansJson(String jsonStr) async {
    final list = (jsonDecode(jsonStr) as List).cast<dynamic>();
    int added = 0, skipped = 0;
    for (final raw in list) {
      final p = WorkoutPlan.fromJson(Map<String, dynamic>.from(raw as Map));
      final copy = p.copyWith(id: _genId());
      // ensure unknown exercises exist
      for (final it in copy.items) {
        final name = it.name;
        final all = [...builtInExercises(), ...customExercises].map((e) => e.name).toSet();
        if (!all.contains(name)) {
          await addCustomExercise(Exercise(name: name, muscle: 'Other'));
        }
      }
      plans.add(copy);
      added++;
    }
    await _prefs.setString(_kPlans, jsonEncode(plans.map((e) => e.toJson()).toList()));
    notifyListeners();
    return (added, skipped);
  }

  // NEW: weight history ops
  Future<void> logWeightNow(double kg) async {
    weightKg = kg;
    await _prefs.setDouble(_kWeight, kg);
    weightHistory.add(WeightPoint(DateTime.now(), kg));
    weightHistory.sort((a, b) => a.at.compareTo(b.at));
    await _prefs.setString(_kWeightHistory, jsonEncode(weightHistory.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  // NEW: theme color ops
  Future<void> setPrimaryColor(Color c) async {
    if (!_prefs.containsKey(_kPrevPrimaryColor)) {
      await _prefs.setInt(_kPrevPrimaryColor, primaryColor.value);
    }
    primaryColor = c;
    await _prefs.setInt(_kPrimaryColor, c.value);
    notifyListeners();
  }

  Future<void> resetPrimaryColorToPrevious() async {
    final prev = _prefs.getInt(_kPrevPrimaryColor) ?? AppTheme.crimson.value;
    primaryColor = Color(prev);
    await _prefs.setInt(_kPrimaryColor, primaryColor.value);
    await _prefs.remove(_kPrevPrimaryColor);
    notifyListeners();
  }

  // Helpers
  static ThemeMode _themeFromString(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeToString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
}

/// ---------- Inherited scope ----------
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required Widget child})
      : super(notifier: state, child: child);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

/// ---------- App ----------
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState _state = AppState();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _state.init().then((_) => setState(() => _ready = true));
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return AppScope(
      state: _state,
      child: AnimatedBuilder(
        animation: _state,
        builder: (context, _) {
          return MaterialApp(
            title: 'VainakhFit',
            themeMode: _state.themeMode,
            theme: AppTheme.light(_state.primaryColor),
            darkTheme: AppTheme.dark(_state.primaryColor),
            home: const RootNav(),
          );
        },
      ),
    );
  }
}

/// ---------- Root Nav with mini workout bar ----------
class RootNav extends StatefulWidget {
  const RootNav({super.key});
  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;
  final _pages = const [WorkoutsScreen(), ProgressScreen(), SettingsScreen()];
  final _titles = const ['Workouts', 'Progress', 'Settings'];

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hasActive = state.active != null;

    final bottom = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasActive)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const Icon(Icons.timer),
                title: Text('Workout • ${_fmt(state.activeElapsed)}',
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(state.active?.fromPlan?.title ?? 'Empty workout'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ActiveWorkoutPage()),
                        );
                      },
                      child: const Text('Resume'),
                    ),
                    IconButton(
                      tooltip: 'End & Save',
                      onPressed: () async {
                        final state = AppScope.of(context);
                        // Capture a suggested updated plan BEFORE ending (active will be cleared).
                        final proposed = state.proposeUpdatedPlanFromActive();

                        final s = await state.endActiveWorkoutAndSave();
                        if (!mounted) return;

                        if (proposed != null) {
                          final doUpdate = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Update plan with your changes?'),
                              content: const Text(
                                  'You added/edited exercises or targets during this workout. '
                                      'Do you want to update the plan with these changes?'
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Update')),
                              ],
                            ),
                          );
                          if (doUpdate == true) {
                            await state.updatePlanById(proposed.id, proposed);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Plan updated.')),
                            );
                          }
                        }

                        if (s != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => WorkoutSummaryPage(session: s)),
                          );
                        }
                      },
                      icon: const Icon(Icons.stop_circle_outlined),
                    ),

                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ActiveWorkoutPage()),
                  );
                },
              ),
            ),
          ),
        NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Workouts',
            ),
            NavigationDestination(
              icon: Icon(Icons.show_chart_outlined),
              selectedIcon: Icon(Icons.show_chart),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: SafeArea(child: IndexedStack(index: _index, children: _pages)),
      bottomNavigationBar: bottom,
    );
  }
}

/// ---------- Settings ----------
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  Gender? _gender;
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    final s = AppScope.of(context);
    _heightCtrl.text = s.heightCm?.toString() ?? '';
    _weightCtrl.text = s.weightKg?.toString() ?? '';
    _gender = s.gender;
    _inited = true;
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Appearance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('Follow System')),
            ButtonSegment(value: ThemeMode.light, label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
          ],
          selected: {state.themeMode},
          onSelectionChanged: (set) => state.setTheme(set.first),
        ),
        const SizedBox(height: 12),
        const Text('Primary color', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: [
            for (final c in [
              AppTheme.crimson, Colors.blue, Colors.teal, Colors.amber, Colors.purple, Colors.green, Colors.orange
            ])
              GestureDetector(
                onTap: () => AppScope.of(context).setPrimaryColor(c),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: state.primaryColor.value == c.value ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: () => AppScope.of(context).resetPrimaryColorToPrevious(),
              icon: const Icon(Icons.restore),
              label: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Profile',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _heightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Height (cm)', hintText: 'e.g. 172.5'),
          onChanged: (v) => state.saveHeight(double.tryParse(v.replaceAll(',', '.'))),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _weightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Weight (kg)', hintText: 'e.g. 73.5'),
          onChanged: (v) => state.saveWeight(double.tryParse(v.replaceAll(',', '.'))),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.update),
          label: const Text('Update current weight (logs to progress)'),
          onPressed: () {
            final v = double.tryParse(_weightCtrl.text.replaceAll(',', '.'));
            if (v != null) {
              AppScope.of(context).logWeightNow(v);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weight updated and logged.')));
            }
          },
        ),
        const SizedBox(height: 16),
        InputDecorator(
          decoration: const InputDecoration(labelText: 'Gender'),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Gender>(
              value: _gender,
              isExpanded: true,
              hint: const Text('Select gender'),
              onChanged: (g) {
                setState(() => _gender = g);
                state.saveGender(g);
              },
              items: const [
                DropdownMenuItem(value: Gender.female, child: Text('Female')),
                DropdownMenuItem(value: Gender.male, child: Text('Male')),
                DropdownMenuItem(value: Gender.other, child: Text('Other')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------- Workouts ----------
bool _planIsToday(WorkoutPlan p) {
  if (p.scheduleWeekdays.isEmpty) return false;
  final today = DateTime.now().weekday; // 1..7
  return p.scheduleWeekdays.contains(today);
}

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    // Sort with "Today" priority, then title
    final plans = [...state.plans];
    plans.sort((a, b) {
      final at = _planIsToday(a) ? 0 : 1;
      final bt = _planIsToday(b) ? 0 : 1;
      final c = at.compareTo(bt);
      if (c != 0) return c;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('My Plans'),
        if (plans.isEmpty)
          const Text('No plans yet. Create one below.'),
        if (plans.isNotEmpty)
          ...List.generate(plans.length, (i) {
            final p = plans[i];
            return Card(
              child: ListTile(
                title: Text(p.title),
                subtitle: Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('${p.items.length} exercises', overflow: TextOverflow.ellipsis),
                    if (_planIsToday(p)) _TodayBadge(),
                  ],
                ),

                trailing: Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        state.startActiveWorkout(plan: p);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ActiveWorkoutPage()),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditPlanPage(plan: p)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        final idx = state.plans.indexWhere((x) => x.id == p.id);
                        if (idx != -1) state.deletePlan(idx);
                      },
                      tooltip: 'Delete',
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlanDetailsPage(plan: p)),
                ),
              ),
            );
          }),
        const SizedBox(height: 24),

        _sectionTitle('Workout Section'),
        _TileGrid(children: [
          _ActionTile(
            icon: Icons.file_upload_outlined,
            label: 'Import Plans',
            onTap: () async {
              final ctrl = TextEditingController();
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Paste plans JSON'),
                  content: TextField(
                    controller: ctrl, maxLines: 10,
                    decoration: const InputDecoration(hintText: 'Paste JSON exported from VainakhFit'),
                  ),
                  actions: [
                    TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Cancel')),
                    FilledButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Import')),
                  ],
                ),
              );
              if (ok == true) {
                try {
                  final (added, _) = await state.importPlansJson(ctrl.text);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported $added plan(s).')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
                  }
                }
              }
            },
          ),
          _ActionTile(
            icon: Icons.file_download_outlined,
            label: 'Export Plans',
            onTap: () {
              final jsonStr = state.exportPlansJson();
              showDialog(context: context, builder: (_)=>AlertDialog(
                title: const Text('Exported JSON'),
                content: SelectableText(jsonStr, maxLines: 12),
                actions: [
                  TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Close')),
                ],
              ));
            },
          ),
          _ActionTile(
            icon: Icons.play_circle_outline,
            label: 'Start Empty Workout',
            onTap: () {
              state.startActiveWorkout();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActiveWorkoutPage()),
              );
            },
          ),
          _ActionTile(
            icon: Icons.search,
            label: 'Find Plans',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FindPlansPage()),
            ),
          ),
          _ActionTile(
            icon: Icons.edit_calendar_outlined,
            label: 'Create Plan',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreatePlanPage()),
            ),
          ),
        ]),
        const SizedBox(height: 24),

        _sectionTitle('Exercises'),
        _TileGrid(children: [
          _ActionTile(
            icon: Icons.add_circle_outline,
            label: 'Add Custom Exercise',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExercisePage()),
            ),
          ),
          _ActionTile(
            icon: Icons.view_list_outlined,
            label: 'Exercise List',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExerciseListPage()),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _sectionTitle(String s) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(s, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );
}

class _TileGrid extends StatelessWidget {
  final List<Widget> children;
  const _TileGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _ActionTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withOpacity(0.15),
                ),
                child: Icon(icon, size: 26, color: cs.primary),
              ),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- Plan Details ----------
class PlanDetailsPage extends StatelessWidget {
  final WorkoutPlan plan;
  const PlanDetailsPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title),
        actions: [
          IconButton(
            tooltip: 'Edit Plan',
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditPlanPage(plan: plan)),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: plan.items.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return FilledButton.icon(
              onPressed: () {
                state.startActiveWorkout(plan: plan);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ActiveWorkoutPage()),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Workout From Plan'),
            );
          }
          final e = plan.items[i - 1];
          return Card(
            child: ListTile(
              title: Text(e.name),
              subtitle: Text('${e.sets} x ${e.reps}${e.weightKg != null ? ' @ ${e.weightKg} kg' : ''}'),
            ),
          );
        },
      ),
    );
  }
}

/// ---------- Active Workout Page ----------
class ActiveWorkoutPage extends StatefulWidget {
  const ActiveWorkoutPage({super.key});
  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  void _showAddExerciseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: ExercisePicker(
          onPick: (name) {
            AppScope.of(context).addExerciseToActive(name);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final active = state.active;

    if (active == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('No Workout Running')),
        body: const Center(child: Text('Start a workout from the Workouts tab.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: state,
          builder: (_, __) => Text('Workout • ${_fmt(state.activeElapsed)}'),
        ),
        actions: [
          IconButton(
            tooltip: 'Add exercise',
            onPressed: () => _showAddExerciseSheet(context),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: 'End & Save',
            onPressed: () async {
              final s = await state.endActiveWorkoutAndSave();
              if (!mounted) return;
              if (s != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => WorkoutSummaryPage(session: s)),
                );
              }
            },
            icon: const Icon(Icons.stop_circle_outlined),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: state,
        builder: (context, _) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: active.entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final entry = active.entries[i];
            return _ExerciseCard(entryIndex: i, entry: entry);
          },
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final int entryIndex;
  final ActiveExerciseEntry entry;
  const _ExerciseCard({required this.entryIndex, required this.entry});

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  String _fmtRest(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  void _editSetDialog(AppState state, int logIndex) {
    final l = widget.entry.logs[logIndex];
    final repsCtrl = TextEditingController(text: l.reps.toString());
    final wCtrl = TextEditingController(text: l.weightKg?.toString() ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Reps'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: wCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              state.editSet(
                widget.entryIndex,
                logIndex,
                reps: int.tryParse(repsCtrl.text.trim()),
                weight: double.tryParse(wCtrl.text.trim().replaceAll(',', '.')),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final e = widget.entry;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(e.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                DropdownButton<int>(
                  value: e.restSeconds,
                  onChanged: (v) => state.setRestPref(widget.entryIndex, v ?? 60),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('0s')),
                    DropdownMenuItem(value: 30, child: Text('30s')),
                    DropdownMenuItem(value: 60, child: Text('1m')),
                    DropdownMenuItem(value: 90, child: Text('1m 30s')),
                    DropdownMenuItem(value: 120, child: Text('2m')),
                  ],
                ),
                const SizedBox(width: 8),
                if (e.restCountdown > 0)
                  Row(
                    children: [
                      const Icon(Icons.hourglass_bottom, size: 18),
                      const SizedBox(width: 4),
                      Text(_fmtRest(e.restCountdown)),
                    ],
                  ),
                IconButton(
                  tooltip: 'Details',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailPage(name: e.name)));
                  },
                  icon: const Icon(Icons.info_outline),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'replace') {
                      String? chosen;
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (_) => SizedBox(
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: ExercisePicker(onPick: (name) { chosen = name; Navigator.pop(context); }),
                        ),
                      );
                      if (chosen != null) {
                        AppScope.of(context).replaceActiveExercise(widget.entryIndex, chosen!);
                      }
                    } else if (v == 'delete') {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Remove exercise?'),
                          content: Text('Remove "${e.name}" and all its sets from this workout?'),
                          actions: [
                            TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Cancel')),
                            FilledButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Remove')),
                          ],
                        ),
                      );
                      if (ok == true) AppScope.of(context).deleteActiveExercise(widget.entryIndex);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'replace', child: Text('Replace exercise…')),
                    PopupMenuItem(value: 'delete',  child: Text('Delete exercise')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // --- Planned rows list (with wider inputs) ---
            Column(
              children: [
                ...List.generate(widget.entry.planned.length, (idx) {
                  final row = widget.entry.planned[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text('Set ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),

                        // Reps (fixed width so 2–3 digits stay visible)
                        SizedBox(
                          width: 90,
                          child: TextFormField(
                            key: ValueKey('reps_${widget.entryIndex}_$idx'),
                            initialValue: row.reps.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              labelText: 'Reps',
                              prefixIcon: Icon(Icons.repeat),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onChanged: (v) {
                              final r = int.tryParse(v.trim());
                              if (r != null) row.reps = r;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Weight (fixed wider field)
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            key: ValueKey('kg_${widget.entryIndex}_$idx'),
                            initialValue: row.weightKg?.toString() ?? '',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              isDense: true,
                              labelText: 'kg',
                              prefixIcon: Icon(Icons.fitness_center),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onChanged: (v) {
                              final w = double.tryParse(v.trim().replaceAll(',', '.'));
                              row.weightKg = w;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        IconButton(
                          tooltip: 'Mark complete',
                          icon: const Icon(Icons.check_circle),
                          onPressed: () {
                            AppScope.of(context).completePlannedSet(
                              widget.entryIndex,
                              idx,
                              reps: row.reps,
                              weight: row.weightKg,
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Remove set',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            AppScope.of(context).removePlannedSet(widget.entryIndex, idx);
                          },
                        ),
                      ],
                    ),
                  );
                }),

                // Add-set button
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add set'),
                    onPressed: () {
                      final e = widget.entry;
                      final defReps = e.targetReps ?? (e.logs.isNotEmpty ? e.logs.last.reps : 10);
                      final defW = e.targetWeight ?? (e.logs.isNotEmpty ? e.logs.last.weightKg : null);
                      AppScope.of(context).addPlannedSet(widget.entryIndex, reps: defReps, weight: defW);
                    },
                  ),
                ),

                const Divider(),

                // Completed sets history
                ...List.generate(widget.entry.logs.length, (idx) {
                  final l = widget.entry.logs[idx];
                  return Dismissible(
                    key: ValueKey('${widget.entry.name}_$idx'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.red.withOpacity(0.7),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      final removed = l;
                      final removedIndex = idx;
                      AppScope.of(context).deleteSet(widget.entryIndex, idx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Set deleted'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              AppScope.of(context)
                                  .active!
                                  .entries[widget.entryIndex]
                                  .logs
                                  .insert(removedIndex, removed);
                              AppScope.of(context).notifyListeners();
                            },
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check, size: 20),
                      title: Text('Set ${idx + 1}: ${l.reps} reps${l.weightKg != null ? ' @ ${l.weightKg}kg' : ''}'),
                      trailing: IconButton(
                        onPressed: () => _editSetDialog(AppScope.of(context), idx),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class CreatePlanPage extends StatefulWidget {
  const CreatePlanPage({super.key});
  @override
  State<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends State<CreatePlanPage> {
  final _titleCtrl = TextEditingController();
  final List<PlanExercise> _items = [];
  final Set<int> _weekdays = {}; // 1..7

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(() => setState(() {})); // enable Save when title changes
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExerciseAndAdd() async {
    String? chosen;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: ExercisePicker(
          onPick: (name) {
            chosen = name;
            Navigator.pop(context);
          },
        ),
      ),
    );
    if (chosen == null) return;

    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '10');
    final weightCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add "$chosen"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(child: TextField(controller: setsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sets'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: repsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps'))),
            ]),
            const SizedBox(height: 8),
            TextField(controller: weightCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight (kg, optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
    );

    if (ok == true) {
      final sets = int.tryParse(setsCtrl.text.trim()) ?? 3;
      final reps = int.tryParse(repsCtrl.text.trim()) ?? 10;
      final w = double.tryParse(weightCtrl.text.trim().replaceAll(',', '.'));
      setState(() {
        _items.add(PlanExercise(name: chosen!, sets: sets, reps: reps, weightKg: w));
      });
    }
  }

  void _savePlan() {
    if (_titleCtrl.text.trim().isEmpty || _items.isEmpty) return;
    final state = AppScope.of(context);
    state.addPlan(WorkoutPlan(
      id: _genId(),
      title: _titleCtrl.text.trim(),
      items: List.of(_items),
      scheduleWeekdays: _weekdays.toList()..sort(),
    ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan saved locally.')));
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return Scaffold(
      appBar: AppBar(title: const Text('Create Plan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickExerciseAndAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add exercise'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Plan title')),
          const SizedBox(height: 12),
          const Text('Schedule (optional)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final d = i + 1;
              final selected = _weekdays.contains(d);
              return FilterChip(
                label: Text(labels[i]),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    if (selected) {
                      _weekdays.remove(d);
                    } else {
                      _weekdays.add(d);
                    }
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          const Text('Exercises'),
          const SizedBox(height: 8),
          if (_items.isEmpty)
            const Card(child: ListTile(title: Text('No exercises yet'), subtitle: Text('Tap "Add exercise" to pick from the library.'))),
          ...List.generate(_items.length, (i) {
            final e = _items[i];
            return Card(
              child: ListTile(
                title: Text(e.name),
                subtitle: Text('${e.sets} x ${e.reps}${e.weightKg != null ? ' @ ${e.weightKg} kg' : ''}'),
                trailing: IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _items.removeAt(i)),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _items.isEmpty || _titleCtrl.text.trim().isEmpty ? null : _savePlan,
            icon: const Icon(Icons.save),
            label: const Text('Save Plan'),
          ),
        ],
      ),
    );
  }
}

/// Edit Plan
class EditPlanPage extends StatefulWidget {
  final WorkoutPlan plan;
  const EditPlanPage({super.key, required this.plan});
  @override
  State<EditPlanPage> createState() => _EditPlanPageState();
}

class _EditPlanPageState extends State<EditPlanPage> {
  late TextEditingController _titleCtrl;
  late List<PlanExercise> _items;
  late Set<int> _weekdays;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.plan.title);
    _items = widget.plan.items
        .map((e) => PlanExercise(name: e.name, sets: e.sets, reps: e.reps, weightKg: e.weightKg))
        .toList();
    _weekdays = widget.plan.scheduleWeekdays.toSet();
    _titleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _addOrEditExercise({int? index}) async {
    String? chosen = index == null ? null : _items[index].name;

    if (index == null) {
      // pick exercise
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: ExercisePicker(
            onPick: (name) {
              chosen = name;
              Navigator.pop(context);
            },
          ),
        ),
      );
      if (chosen == null) return;
    }

    final setsCtrl = TextEditingController(text: index == null ? '3' : _items[index].sets.toString());
    final repsCtrl = TextEditingController(text: index == null ? '10' : _items[index].reps.toString());
    final weightCtrl = TextEditingController(text: index == null ? '' : (_items[index].weightKg?.toString() ?? ''));

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${index == null ? 'Add' : 'Edit'} "$chosen"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(child: TextField(controller: setsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sets'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: repsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps'))),
            ]),
            const SizedBox(height: 8),
            TextField(controller: weightCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight (kg, optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (ok == true) {
      final sets = int.tryParse(setsCtrl.text.trim()) ?? 3;
      final reps = int.tryParse(repsCtrl.text.trim()) ?? 10;
      final w = double.tryParse(weightCtrl.text.trim().replaceAll(',', '.'));

      setState(() {
        if (index == null) {
          _items.add(PlanExercise(name: chosen!, sets: sets, reps: reps, weightKg: w));
        } else {
          _items[index] = PlanExercise(name: chosen!, sets: sets, reps: reps, weightKg: w);
        }
      });
    }
  }

  void _save() async {
    if (_titleCtrl.text.trim().isEmpty || _items.isEmpty) return;
    final updated = widget.plan.copyWith(
      title: _titleCtrl.text.trim(),
      items: _items,
      scheduleWeekdays: _weekdays.toList()..sort(),
    );
    await AppScope.of(context).updatePlanById(widget.plan.id, updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Plan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditExercise(),
        icon: const Icon(Icons.add),
        label: const Text('Add exercise'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Plan title')),
          const SizedBox(height: 16),
          const Text('Schedule'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final d = i + 1;
              final selected = _weekdays.contains(d);
              return FilterChip(
                label: Text(labels[i]),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    if (selected) _weekdays.remove(d); else _weekdays.add(d);
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          const Text('Exercises'),
          const SizedBox(height: 8),
          if (_items.isEmpty)
            const Card(child: ListTile(title: Text('No exercises yet'))),
          ...List.generate(_items.length, (i) {
            final e = _items[i];
            return Card(
              child: ListTile(
                title: Text(e.name),
                subtitle: Text('${e.sets} x ${e.reps}${e.weightKg != null ? ' @ ${e.weightKg} kg' : ''}'),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _addOrEditExercise(index: i),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _items.removeAt(i)),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _items.isEmpty || _titleCtrl.text.trim().isEmpty ? null : _save,
            icon: const Icon(Icons.save),
            label: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

/// ---------- Find Plans ----------
class FindPlansPage extends StatelessWidget {
  const FindPlansPage({super.key});

  List<WorkoutPlan> _templates() => [
  WorkoutPlan(id: _genId(), title: 'StrongLifts 5x5', items: [
  PlanExercise(name: 'Back Squat', sets: 5, reps: 5),
  PlanExercise(name: 'Bench Press', sets: 5, reps: 5),
  PlanExercise(name: 'Barbell Row', sets: 5, reps: 5),
  ]),
  WorkoutPlan(id: _genId(), title: 'Starting Strength (A)', items: [
  PlanExercise(name: 'Back Squat', sets: 3, reps: 5),
  PlanExercise(name: 'Bench Press', sets: 3, reps: 5),
  PlanExercise(name: 'Deadlift', sets: 1, reps: 5),
  ]),
  WorkoutPlan(id: _genId(), title: 'Starting Strength (B)', items: [
  PlanExercise(name: 'Back Squat', sets: 3, reps: 5),
  PlanExercise(name: 'Overhead Press', sets: 3, reps: 5),
  PlanExercise(name: 'Deadlift', sets: 1, reps: 5),
  ]),
  WorkoutPlan(id: _genId(), title: 'Push/Pull/Legs - Push', items: [
  PlanExercise(name: 'Bench Press', sets: 4, reps: 8),
  PlanExercise(name: 'Overhead Press', sets: 3, reps: 10),
  PlanExercise(name: 'Triceps Pushdown', sets: 3, reps: 12),
  ]),
  WorkoutPlan(id: _genId(), title: 'Push/Pull/Legs - Pull', items: [
  PlanExercise(name: 'Deadlift', sets: 3, reps: 5),
  PlanExercise(name: 'Pull-up', sets: 4, reps: 8),
  PlanExercise(name: 'Barbell Row', sets: 3, reps: 10),
  ]),
  WorkoutPlan(id: _genId(), title: 'Push/Pull/Legs - Legs', items: [
  PlanExercise(name: 'Back Squat', sets: 4, reps: 8),
  PlanExercise(name: 'Romanian Deadlift', sets: 3, reps: 10),
  PlanExercise(name: 'Lateral Raise', sets: 3, reps: 15),
  ]),
  WorkoutPlan(id: _genId(), title: 'Full Body Beginner', items: [
  PlanExercise(name: 'Back Squat', sets: 3, reps: 8),
  PlanExercise(name: 'Bench Press', sets: 3, reps: 8),
  PlanExercise(name: 'Pull-up', sets: 3, reps: 6),
  ]),
  WorkoutPlan(id: _genId(), title: 'Upper/Lower - Upper', items: [
  PlanExercise(name: 'Bench Press', sets: 4, reps: 6),
  PlanExercise(name: 'Barbell Row', sets: 4, reps: 8),
  PlanExercise(name: 'Overhead Press', sets: 3, reps: 10),
  ]),
    WorkoutPlan(id: _genId(), title: 'Upper/Lower - Lower', items: [
      PlanExercise(name: 'Back Squat', sets: 4, reps: 6),
      PlanExercise(name: 'Romanian Deadlift', sets: 3, reps: 8),
      PlanExercise(name: 'Front Squat', sets: 3, reps: 6),
    ]),
    WorkoutPlan(id: _genId(), title: 'Bodyweight Circuit', items: [
      PlanExercise(name: 'Push-up', sets: 4, reps: 15),
      PlanExercise(name: 'Pull-up', sets: 3, reps: 8),
      PlanExercise(name: 'Plank', sets: 3, reps: 60),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final templates = _templates();

    return Scaffold(
      appBar: AppBar(title: const Text('Find Plans')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final p = templates[i];
          return Card(
            child: ListTile(
              title: Text(p.title),
              subtitle: Text('${p.items.length} exercises'),
              trailing: FilledButton(
                onPressed: () async {
                  // add a fresh copy with a new id to avoid shared refs
                  final copy = WorkoutPlan(
                    id: _genId(),
                    title: p.title,
                    items: p.items.map((e) => PlanExercise(name: e.name, sets: e.sets, reps: e.reps, weightKg: e.weightKg)).toList(),
                    scheduleWeekdays: [],
                  );
                  await state.addPlan(copy);
                  // Snack
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added "${p.title}" to My Plans')),
                    );
                  }
                },
                child: const Text('Add'),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PlanDetailsPage(plan: p)),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ---------- Add Custom Exercise ----------
class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key});
  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final _nameCtrl = TextEditingController();
  final _muscleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _muscleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final muscle = _muscleCtrl.text.trim().isEmpty ? 'Other' : _muscleCtrl.text.trim();
    if (name.isEmpty) return;
    final state = AppScope.of(context);
    state.addCustomExercise(Exercise(name: name, muscle: muscle, description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim()));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom exercise saved locally.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Custom Exercise')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Exercise name')),
          const SizedBox(height: 8),
          TextField(controller: _muscleCtrl, decoration: const InputDecoration(labelText: 'Muscle group (e.g., Chest)')),
          const SizedBox(height: 8),
          TextField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Description (optional)')),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save')),
        ],
      ),
    );
  }
}

/// ---------- Exercise List with Filters + PR badges + Detail ----------
class ExerciseListPage extends StatefulWidget {
  const ExerciseListPage({super.key});
  @override
  State<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  String _query = '';
  String _group = 'All';

  final _groups = const [
    'All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Full Body', 'Cardio', 'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final all = [...builtInExercises(), ...state.customExercises];

    final filtered = all.where((e) {
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty || e.name.toLowerCase().contains(q) || (e.description ?? '').toLowerCase().contains(q);
      final matchesGroup = _group == 'All' || e.muscle == _group;
      return matchesQuery && matchesGroup;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(labelText: 'Search exercises', prefixIcon: Icon(Icons.search)),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _group,
                  onChanged: (v) => setState(() => _group = v ?? 'All'),
                  items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final e = filtered[i];
                final pr = state.prs[e.name];
                final prText = [
                  if (pr?.maxWeightKg != null) 'Max: ${pr!.maxWeightKg}kg',
                  if ((pr?.maxReps ?? 0) > 0) 'Reps: ${pr!.maxReps}',
                ].join(' • ');
                final isCustom = state.customExercises.any((c) => c.name == e.name && c.muscle == e.muscle);
                return Card(
                  child: ListTile(
                    title: Text(e.name),
                    subtitle: Text([e.muscle, if (prText.isNotEmpty) prText].join(' • ')),
                    trailing: Wrap(
                      spacing: 6,
                      children: [
                        IconButton(
                          tooltip: 'Details',
                          icon: const Icon(Icons.info_outline),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailPage(name: e.name))),
                        ),
                        if (isCustom)
                          PopupMenuButton<String>(
                            onSelected: (v) async {
                              final idx = state.customExercises.indexWhere((c) => c.name == e.name && c.muscle == e.muscle);
                              if (idx == -1) return;
                              if (v == 'edit') {
                                final nameCtrl = TextEditingController(text: e.name);
                                final mCtrl = TextEditingController(text: e.muscle);
                                final dCtrl = TextEditingController(text: e.description ?? '');
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Edit exercise'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                                        const SizedBox(height: 8),
                                        TextField(controller: mCtrl, decoration: const InputDecoration(labelText: 'Muscle')),
                                        const SizedBox(height: 8),
                                        TextField(controller: dCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await state.editCustomExercise(idx, Exercise(
                                    name: nameCtrl.text.trim().isEmpty ? e.name : nameCtrl.text.trim(),
                                    muscle: mCtrl.text.trim().isEmpty ? e.muscle : mCtrl.text.trim(),
                                    description: dCtrl.text.trim().isEmpty ? null : dCtrl.text.trim(),
                                  ));
                                }
                              } else if (v == 'delete') {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete exercise?'),
                                    content: Text('Remove "${e.name}" from your custom list?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await state.deleteCustomExerciseAt(idx);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exercise deleted.')));
                                  }
                                }
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                      ],
                    ),
                    onTap: () {
                      final s = AppScope.of(context);
                      if (s.active != null) {
                        s.addExerciseToActive(e.name);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${e.name} to workout')));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailPage(name: e.name)));
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Exercise detail (read-only)
class ExerciseDetailPage extends StatelessWidget {
  final String name;
  const ExerciseDetailPage({super.key, required this.name});

  Exercise? _findByName(BuildContext context) {
    final state = AppScope.of(context);
    final list = [
      ...builtInExercises(),
      ...state.customExercises
    ];
    try {
      return list.firstWhere((e) => e.name == name);
    } catch (_) {
      return Exercise(name: name, muscle: 'Other', description: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = _findByName(context);
    final pr = AppScope.of(context).prs[name];
    return Scaffold(
      appBar: AppBar(title: Text(ex?.name ?? name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(leading: const Icon(Icons.fitness_center), title: const Text('Muscle group'), subtitle: Text(ex?.muscle ?? '—')),
            if (pr != null) ListTile(leading: const Icon(Icons.stars_outlined), title: const Text('Your PRs'),
                subtitle: Text('${pr.maxWeightKg != null ? 'Max Weight: ${pr!.maxWeightKg}kg' : 'Max Weight: —'} • Max Reps: ${pr.maxReps > 0 ? pr.maxReps : '—'}')),
            const SizedBox(height: 8),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(ex?.description?.isNotEmpty == true ? ex!.description! : 'No description available yet.'),
          ],
        ),
      ),
    );
  }
}

/// ---------- Progress (Weight graph + History) ----------
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

enum _Range { week, month, year, all }

class _ProgressScreenState extends State<ProgressScreen> {
  _Range _range = _Range.month;

  List<WeightPoint> _filter(List<WeightPoint> src) {
    if (src.isEmpty) return src;
    final now = DateTime.now();
    DateTime from;
    switch (_range) {
      case _Range.week:
        from = now.subtract(const Duration(days: 7));
        break;
      case _Range.month:
        from = DateTime(now.year, now.month - 1, now.day);
        break;
      case _Range.year:
        from = DateTime(now.year - 1, now.month, now.day);
        break;
      case _Range.all:
        return src;
    }
    return src.where((p) => !p.at.isBefore(from)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pts = _filter(state.weightHistory);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Weight Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<_Range>(
          segments: const [
            ButtonSegment(value: _Range.week, label: Text('Week')),
            ButtonSegment(value: _Range.month, label: Text('Month')),
            ButtonSegment(value: _Range.year, label: Text('Year')),
            ButtonSegment(value: _Range.all, label: Text('All')),
          ],
          selected: {_range},
          onSelectionChanged: (s) => setState(() => _range = s.first),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: pts.length < 2
                  ? const Center(child: Text('Not enough data yet. Update your weight in Settings.'))
                  : CustomPaint(
                painter: _WeightChartPainter(pts),
                child: Container(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Workout History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(state.sessions.length, (i) {
          final s = state.sessions[i];
          final startedLocal = s.startedAt.toLocal().toString().split(".").first;
          final title = 'Workout on $startedLocal';
          return Card(
            child: ListTile(
              title: Text(title),
              subtitle: Text('Sets: ${s.sets.length} • Duration: ${_fmtDur(s.durationSeconds)}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_forever_outlined),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete workout?'),
                      content: const Text('This will remove the workout from your history.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await state.removeSessionAt(i);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Workout deleted.')));
                    }
                  }
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WorkoutSummaryPage(session: s)),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  String _fmtDur(int? secs) {
    if (secs == null) return '-';
    final d = Duration(seconds: secs);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightPoint> points;
  _WeightChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paintLine = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintAxis = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    final pad = 10.0;
    final left = pad, right = size.width - pad, top = pad, bottom = size.height - pad;

    // Axes
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paintAxis);
    canvas.drawLine(Offset(left, top), Offset(left, bottom), paintAxis);

    // Map time -> x, weight -> y
    final minT = points.first.at.millisecondsSinceEpoch.toDouble();
    final maxT = points.last.at.millisecondsSinceEpoch.toDouble();
    final minKg = points.map((p) => p.kg).reduce((a, b) => a < b ? a : b);
    final maxKg = points.map((p) => p.kg).reduce((a, b) => a > b ? a : b);

    final spanT = (maxT - minT).clamp(1, double.infinity);
    final spanKg = (maxKg - minKg).abs() < 1e-6 ? 1.0 : (maxKg - minKg);

    double xFor(DateTime t) => left + (right - left) * ((t.millisecondsSinceEpoch - minT) / spanT);
    double yFor(double kg) => bottom - (bottom - top) * ((kg - minKg) / spanKg);

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = xFor(p.at);
      final y = yFor(p.kg);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paintLine);

    // Dots
    final dot = Paint()..color = Colors.blueAccent;
    for (final p in points) {
      canvas.drawCircle(Offset(xFor(p.at), yFor(p.kg)), 2.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) => oldDelegate.points != points;
}

class _SessionBest {
  final double? maxWeight;
  final int maxReps;
  final bool isWeightPR;
  final bool isRepsPR;

  const _SessionBest({
    this.maxWeight,
    required this.maxReps,
    required this.isWeightPR,
    required this.isRepsPR,
  });
}


class WorkoutSummaryPage extends StatelessWidget {
  final WorkoutSession session;
  const WorkoutSummaryPage({super.key, required this.session});

  String _fmtDur(int secs) {
    final d = Duration(seconds: secs);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  double _totalWeightLiftedKg(List<WorkoutSetLog> sets) {
    double total = 0;
    for (final s in sets) {
      if (s.weightKg != null) total += s.weightKg! * s.reps;
    }
    return total;
  }

  int _totalReps(List<WorkoutSetLog> sets) =>
      sets.fold<int>(0, (acc, s) => acc + s.reps);

  /// Very rough MET mapping per exercise name. Defaults to 5.0 (general lifting).
  double _metForExercise(String name) {
    final n = name.toLowerCase();
    if (n.contains('deadlift') || n.contains('squat') || n.contains('bench') || n.contains('row'))
      return 6.0; // vigorous
    if (n.contains('press') || n.contains('pull') || n.contains('push-up'))
      return 5.5;
    if (n.contains('curl') || n.contains('raise') || n.contains('pushdown'))
      return 3.5; // accessory
    if (n.contains('burpee')) return 8.0;
    if (n.contains('kettlebell')) return 7.0;
    if (n.contains('plank')) return 3.0;
    return 5.0;
  }

  /// Kcal estimate using MET formula: kcal = MET * 3.5 * kg / 200 * minutes.
  /// We split total session time across exercises proportional to set count.
  Map<String, double> _estimateKcalPerExercise(
      AppState state, WorkoutSession s) {
    final bw = state.weightKg ?? 75.0;
    final genderAdj = state.gender == Gender.male ? 1.05 : 1.0; // tiny boost for avg male LBM
    final totalSecs = (s.durationSeconds ?? 0).clamp(1, 36000); // up to 10h
    // Count sets per exercise
    final counts = <String, int>{};
    for (final set in s.sets) {
      counts[set.exercise] = (counts[set.exercise] ?? 0) + 1;
    }
    final totalSets = counts.values.fold<int>(0, (a, b) => a + b).clamp(1, 100000);
    final perEx = <String, double>{};
    counts.forEach((ex, cnt) {
      final shareMinutes = (totalSecs * (cnt / totalSets)) / 60.0;
      final met = _metForExercise(ex);
      final kcal = met * 3.5 * bw / 200.0 * shareMinutes * genderAdj;
      perEx[ex] = kcal;
    });
    return perEx;
  }

  /// Fun comparisons for total weight lifted.
  List<String> _weightComparisons(double kg) {
    final items = <String>[
      _cmp(kg, 1847, "Tesla Model 3"),
      _cmp(kg, 480, "grand piano"),
      _cmp(kg, 190, "adult lions"),
      _cmp(kg, 90, "refrigerators"),
      _cmp(kg, 2700, "blue-whale calves"),
    ].where((s) => s.isNotEmpty).toList();

    if (items.isEmpty) {
      items.add("${kg.toStringAsFixed(0)} kg is like a heavy motorcycle");
    }
    return items;
  }

  String _cmp(double totalKg, double unitKg, String label) {
    if (unitKg <= 0) return '';
    final count = totalKg / unitKg;
    if (count < 0.5) return '';
    final nice = count >= 10 ? count.toStringAsFixed(0) : count.toStringAsFixed(1);
    return "≈ $nice × $label";
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    // Aggregates
    final totalKg = _totalWeightLiftedKg(session.sets);
    final totalReps = _totalReps(session.sets);
    final duration = session.durationSeconds ?? 0;

    // Per-exercise grouping
    final byExercise = <String, List<WorkoutSetLog>>{};
    for (final s in session.sets) {
      byExercise.putIfAbsent(s.exercise, () => []).add(s);
    }

    // Bests in this session + PR flags (compared to current stored PRs)
    final Map<String, _SessionBest> sessionBests = {};
    byExercise.forEach((ex, sets) {
      double? maxW;
      int maxR = 0;
      for (final s in sets) {
        if (s.weightKg != null) {
          maxW = (maxW == null) ? s.weightKg : (s.weightKg! > maxW! ? s.weightKg : maxW);
        }
        if (s.reps > maxR) maxR = s.reps;
      }
      final pr = state.prs[ex];
      final isWPR = (maxW != null) && (pr?.maxWeightKg == maxW);
      final isRPR = (maxR > 0) && (pr?.maxReps == maxR);
      sessionBests[ex] = _SessionBest(
        maxWeight: maxW,
        maxReps: maxR,
        isWeightPR: isWPR,
        isRepsPR: isRPR,
      );

    });

    final kcalPerExercise = _estimateKcalPerExercise(state, session);
    final totalKcal = kcalPerExercise.values.fold<double>(0, (a, b) => a + b);

    final comparisons = _weightComparisons(totalKg);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Summary')),
      body: PageView(
        children: [
          // Card 1: Weight lifted
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.scale),
                          SizedBox(width: 6),
                          Text(
                            'Total Weight Lifted',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${totalKg.toStringAsFixed(0)} kg',
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.emoji_objects_outlined),
                          SizedBox(width: 6),
                          Text('Fun comparison:', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...comparisons.map(
                            (c) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chevron_right, size: 18),
                            const SizedBox(width: 6),
                            Flexible(child: Text(c, textAlign: TextAlign.center)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Card 2: Total Reps + Duration
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.repeat),
                          SizedBox(width: 6),
                          Text(
                            'Volume & Time',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Total reps: $totalReps', style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 6),
                          Text('Duration: ${_fmtDur(duration)}', style: const TextStyle(fontSize: 22)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Card 3: Calories per exercise (and total)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.local_fire_department),
                        SizedBox(width: 6),
                        Text(
                          'Calories Burned (estimate)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Total: ${totalKcal.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        children: kcalPerExercise.entries.map((e) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.fitness_center),
                            title: Text(e.key),
                            trailing: Text('${e.value.toStringAsFixed(0)} kcal'),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Card 4: PRs & per-exercise bests
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.stars_outlined),
                        SizedBox(width: 6),
                        Text(
                          'Bests & PRs',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: sessionBests.entries.map((e) {
                          final name = e.key;
                          final best = e.value;
                          final chips = <Widget>[];
                          if (best.maxWeight != null) {
                            chips.add(
                              _chip(
                                'Max ${best.maxWeight!.toStringAsFixed(1)} kg',
                                best.isWeightPR ? Icons.celebration : Icons.fitness_center,
                                best.isWeightPR,
                              ),
                            );
                          }
                          if (best.maxReps > 0) {
                            chips.add(
                              _chip(
                                'Max ${best.maxReps} reps',
                                best.isRepsPR ? Icons.emoji_events : Icons.repeat,
                                best.isRepsPR,
                              ),
                            );
                          }
                          return ListTile(
                            leading: const Icon(Icons.fitness_center),
                            title: Text(name),
                            subtitle: Wrap(spacing: 8, runSpacing: 4, children: chips),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

  Widget _chip(String text, IconData icon, bool highlight) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(highlight ? '$text • PR!' : text),
    );
  }


class AppTheme {
  static const Color crimson = Color(0xFFDC143C);
  static const Color darkSurface = Color(0xFF111111);

  static ThemeData light(Color primary) {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        secondary: primary,
        surface: Colors.white,
        background: Colors.white,
        onPrimary: Colors.white,
        onSurface: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: Colors.white),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(),
      ),
    );

    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: Colors.white,
        indicatorColor: primary.withOpacity(.15),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const MaterialStatePropertyAll(Colors.black),
          overlayColor: MaterialStatePropertyAll(primary.withOpacity(.10)),
        ),
      ),
    );
  }

  static ThemeData dark(Color primary) {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primary,
        secondary: primary,
        surface: darkSurface,
        background: Colors.black,
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: darkSurface),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1A1A1A),
        border: OutlineInputBorder(),
      ),
    );

    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: Colors.black,
        indicatorColor: primary.withOpacity(.2),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          overlayColor: MaterialStatePropertyAll(primary.withOpacity(.15)),
        ),
      ),
    );
  }
}

class _TodayBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.event_available, size: 14),
          SizedBox(width: 4),
          Text('Today', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class ExercisePicker extends StatefulWidget {
  final void Function(String name) onPick;
  const ExercisePicker({super.key, required this.onPick});

  @override
  State<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  String _query = '';
  String _group = 'All';

  final _groups = const [
    'All',
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
    'Full Body',
    'Cardio',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final all = [...builtInExercises(), ...state.customExercises];

    final filtered = all.where((e) {
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          (e.description ?? '').toLowerCase().contains(q);
      final matchesGroup = _group == 'All' || e.muscle == _group;
      return matchesQuery && matchesGroup;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    labelText: 'Search exercises',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _group,
                onChanged: (v) => setState(() => _group = v ?? 'All'),
                items: _groups
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final e = filtered[i];
              return Card(
                child: ListTile(
                  title: Text(e.name),
                  subtitle: Text(e.muscle),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseDetailPage(name: e.name),
                      ),
                    ),
                  ),
                  onTap: () => widget.onPick(e.name),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

