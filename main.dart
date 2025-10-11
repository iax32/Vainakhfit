import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

void main() => runApp(const MyApp());

enum Gender { female, male, other }

/// Built-in exercise catalog (single source of truth)
List<Exercise> builtInExercises() => [
  // Chest (existing)
  Exercise(name: 'Bench Press', muscle: 'Chest', description: 'Barbell bench press targeting chest, triceps and anterior deltoids.'),
  Exercise(name: 'Incline Bench Press', muscle: 'Chest', description: 'Barbell bench press targeting chest, triceps and anterior deltoids.'),
  Exercise(name: 'Decline Bench Press', muscle: 'Chest', description: 'Barbell bench press targeting chest, triceps and anterior deltoids.'),
  Exercise(name: 'Push-up', muscle: 'Chest', description: 'Bodyweight push; hands shoulder-width, neutral spine.'),

  // Back (existing)
  Exercise(name: 'Deadlift', muscle: 'Back', description: 'Posterior chain compound: hinge with neutral back.'),
  Exercise(name: 'Pull-up', muscle: 'Back', description: 'Overhand grip; chest to bar; full hang to chin over bar.'),
  Exercise(name: 'Chin-up', muscle: 'Back', description: 'Underhand grip; chest to bar; full hang to chin over bar.'),
  Exercise(name: 'Barbell Row', muscle: 'Back', description: 'Hinge to ~45°, row bar to lower chest / upper abs.'),

  // Legs (existing)
  Exercise(name: 'Back Squat', muscle: 'Legs', description: 'Bar on traps; squat below parallel with stable knees.'),
  Exercise(name: 'Front Squat', muscle: 'Legs', description: 'Bar on front rack; more quad emphasis.'),
  Exercise(name: 'Romanian Deadlift', muscle: 'Legs', description: 'Hip hinge; hamstrings stretch; slight knee bend.'),

  // Shoulders (existing)
  Exercise(name: 'Overhead Press', muscle: 'Shoulders', description: 'Press bar to overhead; brace core, glutes.'),
  Exercise(name: 'Lateral Raise', muscle: 'Shoulders', description: 'Dumbbells out to sides to shoulder height.'),

  // Arms (existing)
  Exercise(name: 'Dumbbell Curl', muscle: 'Arms', description: 'Elbows pinned; curl without swinging.'),
  Exercise(name: 'Triceps Pushdown', muscle: 'Arms', description: 'Cable pushdown; elbows tucked, full extension.'),

  // Core (existing)
  Exercise(name: 'Plank', muscle: 'Core', description: 'Hold a straight line from head to heels; brace abs and glutes.'),
  Exercise(name: 'Hanging Leg Raise', muscle: 'Core', description: 'Raise legs to 90°; avoid swinging.'),

  // Full Body / Cardio (existing)
  Exercise(name: 'Kettlebell Swing', muscle: 'Full Body', description: 'Hip drive; swing bell to chest height.'),
  Exercise(name: 'Burpee', muscle: 'Cardio', description: 'Squat to plank, push-up, return and jump.'),

  // --------- Chest (add ~25) ----------
  Exercise(name: 'Dumbbell Bench Press', muscle: 'Chest', description: 'Neutral grip option; greater range of motion.'),
  Exercise(name: 'Incline Dumbbell Press', muscle: 'Chest', description: 'Upper chest focus; 15–30° bench angle.'),
  Exercise(name: 'Decline Dumbbell Press', muscle: 'Chest', description: 'Lower chest emphasis; control descent.'),
  Exercise(name: 'Close-Grip Bench Press', muscle: 'Chest', description: 'Narrow grip; triceps and inner chest focus.'),
  Exercise(name: 'Floor Press', muscle: 'Chest', description: 'Reduced range; lockout and triceps emphasis.'),
  Exercise(name: 'Machine Chest Press', muscle: 'Chest', description: 'Stable path; push handles to full extension.'),
  Exercise(name: 'Cable Chest Press', muscle: 'Chest', description: 'Standing press; constant cable tension.'),
  Exercise(name: 'Push-up (Diamond)', muscle: 'Chest', description: 'Hands together; triceps and inner chest bias.'),
  Exercise(name: 'Push-up (Wide)', muscle: 'Chest', description: 'Hands wider than shoulders; chest emphasis.'),
  Exercise(name: 'Archer Push-up', muscle: 'Chest', description: 'Side-to-side loading; unilateral challenge.'),
  Exercise(name: 'Weighted Push-up', muscle: 'Chest', description: 'External load; maintain rigid plank line.'),
  Exercise(name: 'Deficit Push-up', muscle: 'Chest', description: 'Hands elevated; increase depth and stretch.'),
  Exercise(name: 'Ring Push-up', muscle: 'Chest', description: 'Instability; scapular control; neutral wrists.'),
  Exercise(name: 'Dumbbell Flye', muscle: 'Chest', description: 'Arc motion; soft elbows; stretch and squeeze.'),
  Exercise(name: 'Incline Dumbbell Flye', muscle: 'Chest', description: 'Upper chest stretch; slow eccentric.'),
  Exercise(name: 'Cable Flye (High to Low)', muscle: 'Chest', description: 'Lower chest; cross hands slightly.'),
  Exercise(name: 'Cable Flye (Low to High)', muscle: 'Chest', description: 'Upper chest; finish at eye level.'),
  Exercise(name: 'Pec Deck', muscle: 'Chest', description: 'Machine flye; elbows slightly bent; squeeze peak.'),
  Exercise(name: 'Svend Press', muscle: 'Chest', description: 'Plates squeezed together; inner chest bias.'),
  Exercise(name: 'Guillotine Press', muscle: 'Chest', description: 'Bar to neck; very light; high chest activation.'),
  Exercise(name: 'Landmine Press (Chest Focus)', muscle: 'Chest', description: 'Angled press; slight arc toward midline.'),
  Exercise(name: 'Single-Arm Dumbbell Press', muscle: 'Chest', description: 'Anti-rotation core; press one side.'),
  Exercise(name: 'Iso-Hold Dumbbell Press', muscle: 'Chest', description: 'Hold one side; press the other.'),
  Exercise(name: 'Spoto Press', muscle: 'Chest', description: 'Pause 2cm above chest; control tension.'),
  Exercise(name: 'Smith Machine Bench Press', muscle: 'Chest', description: 'Fixed path; safer near failure.'),

  // --------- Back (add ~30) ----------
  Exercise(name: 'Pendlay Row', muscle: 'Back', description: 'From floor each rep; strict torso.'),
  Exercise(name: 'T-Bar Row', muscle: 'Back', description: 'Chest supported or hinged; mid-back focus.'),
  Exercise(name: 'Seal Row', muscle: 'Back', description: 'Prone on bench; strict lat/upper-back pull.'),
  Exercise(name: 'Dumbbell Row', muscle: 'Back', description: 'Hinge; pull to hip; avoid shrugging.'),
  Exercise(name: 'Chest-Supported Row', muscle: 'Back', description: 'Bench support; minimize lower back load.'),
  Exercise(name: 'Cable Row (Seated)', muscle: 'Back', description: 'Neutral spine; pull to navel/sternum.'),
  Exercise(name: 'Lat Pulldown (Wide)', muscle: 'Back', description: 'Elbows down and back; avoid swinging.'),
  Exercise(name: 'Lat Pulldown (Close)', muscle: 'Back', description: 'Neutral/close grip; lat emphasis.'),
  Exercise(name: 'Straight-Arm Pulldown', muscle: 'Back', description: 'Locked elbows; sweep bar to thighs.'),
  Exercise(name: 'Face Pull', muscle: 'Back', description: 'Rope to forehead; external rotation focus.'),
  Exercise(name: 'Inverted Row', muscle: 'Back', description: 'Bodyweight row; heels on floor/bench.'),
  Exercise(name: 'Ring Row', muscle: 'Back', description: 'Instability; keep ribs tucked.'),
  Exercise(name: 'Kroc Row', muscle: 'Back', description: 'High-rep heavy DB row; straps optional.'),
  Exercise(name: 'Meadows Row', muscle: 'Back', description: 'Landmine one-arm row; hip hinge.'),
  Exercise(name: 'Landmine Row', muscle: 'Back', description: 'Chest supported or hinged; neutral grip.'),
  Exercise(name: 'Good Morning', muscle: 'Back', description: 'Bar on back; hinge; hamstrings and erectors.'),
  Exercise(name: 'Back Extension', muscle: 'Back', description: 'Hip hinge on GHD; glute/ham emphasis.'),
  Exercise(name: 'Reverse Hyper', muscle: 'Back', description: 'Swing legs; traction lower back.'),
  Exercise(name: 'Trap Bar Deadlift', muscle: 'Back', description: 'Neutral handles; quad and back blend.'),
  Exercise(name: 'Snatch-Grip Deadlift', muscle: 'Back', description: 'Wide grip; upper-back loading.'),
  Exercise(name: 'Rack Pull', muscle: 'Back', description: 'Partial deadlift; lockout strength.'),
  Exercise(name: 'Deficit Deadlift', muscle: 'Back', description: 'Stand on plate; increased range of motion.'),
  Exercise(name: 'Sumo Deadlift', muscle: 'Back', description: 'Wide stance; upright torso; hip drive.'),
  Exercise(name: 'Jefferson Deadlift', muscle: 'Back', description: 'Straddle bar; anti-rotation pull.'),
  Exercise(name: 'Zercher Squat (Back Focus)', muscle: 'Back', description: 'Elbows under bar; upper-back challenge.'),
  Exercise(name: 'Farmer’s Carry', muscle: 'Back', description: 'Heavy carries; lats and traps engagement.'),
  Exercise(name: 'Suitcase Carry', muscle: 'Back', description: 'One-sided carry; anti-lateral flexion.'),
  Exercise(name: 'Yoke Carry', muscle: 'Back', description: 'Loaded frame carry; full back tension.'),
  Exercise(name: 'Shrug (Barbell)', muscle: 'Back', description: 'Up-down only; hold peak briefly.'),
  Exercise(name: 'Dumbbell Shrug', muscle: 'Back', description: 'Neutral grip; avoid rolling shoulders.'),

  // --------- Legs (add ~35) ----------
  Exercise(name: 'High-Bar Back Squat', muscle: 'Legs', description: 'Upright torso; quad bias.'),
  Exercise(name: 'Low-Bar Back Squat', muscle: 'Legs', description: 'Hip hinge; posterior chain emphasis.'),
  Exercise(name: 'Goblet Squat', muscle: 'Legs', description: 'DB/Kettlebell at chest; torso upright.'),
  Exercise(name: 'Hack Squat (Machine)', muscle: 'Legs', description: 'Sled machine; deep knee flexion.'),
  Exercise(name: 'Leg Press', muscle: 'Legs', description: 'Foot placement alters quad/ham emphasis.'),
  Exercise(name: 'Walking Lunge', muscle: 'Legs', description: 'Long stride; knee track over toes.'),
  Exercise(name: 'Reverse Lunge', muscle: 'Legs', description: 'Step back; hip and glute friendly.'),
  Exercise(name: 'Forward Lunge', muscle: 'Legs', description: 'Step forward; control knee valgus.'),
  Exercise(name: 'Bulgarian Split Squat', muscle: 'Legs', description: 'Rear foot elevated; deep stretch.'),
  Exercise(name: 'Split Squat', muscle: 'Legs', description: 'Feet split; vertical torso; quad load.'),
  Exercise(name: 'Pistol Squat', muscle: 'Legs', description: 'Single-leg squat; assist as needed.'),
  Exercise(name: 'Box Squat', muscle: 'Legs', description: 'Sit back to box; pause and drive.'),
  Exercise(name: 'Zercher Squat', muscle: 'Legs', description: 'Bar in elbows; upright and braced.'),
  Exercise(name: 'Overhead Squat', muscle: 'Legs', description: 'Bar overhead; mobility and stability heavy.'),
  Exercise(name: 'Sissy Squat', muscle: 'Legs', description: 'Knees forward; quad isolation.'),
  Exercise(name: 'Leg Extension', muscle: 'Legs', description: 'Extend to full lock; control eccentric.'),
  Exercise(name: 'Leg Curl (Seated)', muscle: 'Legs', description: 'Hamstring curl; hips pinned.'),
  Exercise(name: 'Leg Curl (Lying)', muscle: 'Legs', description: 'Keep pelvis down; slow negative.'),
  Exercise(name: 'Nordic Curl', muscle: 'Legs', description: 'Partner/anchor; slow eccentric hamstring.'),
  Exercise(name: 'Glute Bridge', muscle: 'Legs', description: 'Hips up; posterior pelvic tilt.'),
  Exercise(name: 'Hip Thrust', muscle: 'Legs', description: 'Bench-supported; lockout and squeeze.'),
  Exercise(name: 'Cable Pull-Through', muscle: 'Legs', description: 'Hinge with rope; glute emphasis.'),
  Exercise(name: 'Step-up', muscle: 'Legs', description: 'Drive through whole foot; control down.'),
  Exercise(name: 'Box Step-down', muscle: 'Legs', description: 'Eccentric control; hip stability.'),
  Exercise(name: 'Calf Raise (Standing)', muscle: 'Legs', description: 'Full stretch; full plantar flexion.'),
  Exercise(name: 'Calf Raise (Seated)', muscle: 'Legs', description: 'Soleus focus; controlled tempo.'),
  Exercise(name: 'Donkey Calf Raise', muscle: 'Legs', description: 'Hips hinged; deep calf stretch.'),
  Exercise(name: 'Smith Machine Squat', muscle: 'Legs', description: 'Fixed track; high-rep quad sets.'),
  Exercise(name: 'Front Foot Elevated Split Squat', muscle: 'Legs', description: 'More dorsiflexion; quad bias.'),
  Exercise(name: 'Cossack Squat', muscle: 'Legs', description: 'Side lunge; adductor mobility.'),
  Exercise(name: 'Jefferson Squat', muscle: 'Legs', description: 'Straddle barbell; neutral spine.'),
  Exercise(name: 'Spanish Squat', muscle: 'Legs', description: 'Band behind knees; upright quads.'),
  Exercise(name: 'Wall Sit', muscle: 'Legs', description: 'Isometric quads; 90° knee angle.'),
  Exercise(name: 'Kettlebell Deadlift', muscle: 'Legs', description: 'Hip hinge patterning; neutral back.'),
  Exercise(name: 'Single-Leg RDL', muscle: 'Legs', description: 'Balance; hip hinge; level hips.'),

  // --------- Shoulders (add ~25) ----------
  Exercise(name: 'Seated Dumbbell Press', muscle: 'Shoulders', description: 'Neutral or pronated grip; full lockout.'),
  Exercise(name: 'Arnold Press', muscle: 'Shoulders', description: 'Rotate palms during press; delt sweep.'),
  Exercise(name: 'Push Press', muscle: 'Shoulders', description: 'Dip-drive; power through sticking point.'),
  Exercise(name: 'Z Press', muscle: 'Shoulders', description: 'Seated on floor; core demands high.'),
  Exercise(name: 'Machine Shoulder Press', muscle: 'Shoulders', description: 'Fixed path; higher rep safety.'),
  Exercise(name: 'Cable Lateral Raise', muscle: 'Shoulders', description: 'Constant tension; slight forward lean.'),
  Exercise(name: 'Seated Lateral Raise', muscle: 'Shoulders', description: 'Strict reps; minimal body English.'),
  Exercise(name: 'Leaning Lateral Raise', muscle: 'Shoulders', description: 'Increase bottom-range tension.'),
  Exercise(name: 'Behind-the-Back Cable Raise', muscle: 'Shoulders', description: 'Cable behind hip; delt isolation.'),
  Exercise(name: 'Front Raise (Plate)', muscle: 'Shoulders', description: 'Lift to eye level; control down.'),
  Exercise(name: 'Front Raise (Dumbbell)', muscle: 'Shoulders', description: 'Alt or bilateral; avoid swinging.'),
  Exercise(name: 'Rear Delt Flye (Dumbbell)', muscle: 'Shoulders', description: 'Hinge; pinkies high; scapula set.'),
  Exercise(name: 'Rear Delt Flye (Cable)', muscle: 'Shoulders', description: 'Cross-cable; micro-bend elbows.'),
  Exercise(name: 'Face Pull (High Anchor)', muscle: 'Shoulders', description: 'External rotation; scap retraction.'),
  Exercise(name: 'Upright Row (EZ Bar)', muscle: 'Shoulders', description: 'Hands shoulder-width; elbows lead.'),
  Exercise(name: 'Landmine Press', muscle: 'Shoulders', description: 'Angled path; scapular upward rotation.'),
  Exercise(name: 'Dumbbell Y-Raise', muscle: 'Shoulders', description: 'Incline bench; lower trap bias.'),
  Exercise(name: 'Cuban Press', muscle: 'Shoulders', description: 'High pull + external rotation press.'),
  Exercise(name: 'Snatch-Grip High Pull', muscle: 'Shoulders', description: 'Powerful shrug; elbows high.'),
  Exercise(name: 'Barbell Front Raise', muscle: 'Shoulders', description: 'Straight bar to shoulder height.'),
  Exercise(name: 'Bradford Press', muscle: 'Shoulders', description: 'Front-to-back partial presses.'),
  Exercise(name: 'Scaption Raise', muscle: 'Shoulders', description: 'Raise in scapular plane; thumbs up.'),
  Exercise(name: 'Handstand Push-up', muscle: 'Shoulders', description: 'Wall-assisted; strict or kipping.'),
  Exercise(name: 'Pike Push-up', muscle: 'Shoulders', description: 'Hips high; vertical pressing pattern.'),
  Exercise(name: 'Smith Machine Shoulder Press', muscle: 'Shoulders', description: 'Guided bar; safer heavy sets.'),

  // --------- Arms (add ~35) ----------
  Exercise(name: 'Barbell Curl', muscle: 'Arms', description: 'Straight/EZ bar; strict torso.'),
  Exercise(name: 'Hammer Curl', muscle: 'Arms', description: 'Neutral grip; brachialis focus.'),
  Exercise(name: 'Incline Dumbbell Curl', muscle: 'Arms', description: 'Elbows back; long head stretch.'),
  Exercise(name: 'Preacher Curl', muscle: 'Arms', description: 'Pad support; eliminate cheating.'),
  Exercise(name: 'Concentration Curl', muscle: 'Arms', description: 'Elbow on thigh; peak squeeze.'),
  Exercise(name: 'Cable Curl', muscle: 'Arms', description: 'Constant tension; full range.'),
  Exercise(name: 'Bayesian Cable Curl', muscle: 'Arms', description: 'Cable behind body; long head bias.'),
  Exercise(name: 'Reverse Curl', muscle: 'Arms', description: 'Pronated grip; brachioradialis work.'),
  Exercise(name: 'Zottman Curl', muscle: 'Arms', description: 'Supinate up, pronate down.'),
  Exercise(name: 'Spider Curl', muscle: 'Arms', description: 'Chest on bench; strict peak work.'),
  Exercise(name: 'Cable Rope Curl', muscle: 'Arms', description: 'Flare at top; squeeze hard.'),
  Exercise(name: 'One-Arm Cable Curl', muscle: 'Arms', description: 'Unilateral; match sides precisely.'),
  Exercise(name: 'Drag Curl', muscle: 'Arms', description: 'Bar path up torso; elbows back.'),
  Exercise(name: 'EZ-Bar Curl', muscle: 'Arms', description: 'Wrist-friendly; varying hand widths.'),
  Exercise(name: 'Triceps Dips', muscle: 'Arms', description: 'Parallel bars; slight forward lean.'),
  Exercise(name: 'Bench Dips', muscle: 'Arms', description: 'Feet elevated to increase load.'),
  Exercise(name: 'Skullcrusher (EZ Bar)', muscle: 'Arms', description: 'Lower behind head; long head stretch.'),
  Exercise(name: 'Overhead Triceps Extension (DB)', muscle: 'Arms', description: 'Elbows narrow; full extension.'),
  Exercise(name: 'Cable Overhead Extension', muscle: 'Arms', description: 'Back to stack; constant tension.'),
  Exercise(name: 'Rope Pushdown', muscle: 'Arms', description: 'Flare rope at bottom; lockout.'),
  Exercise(name: 'Straight-Bar Pushdown', muscle: 'Arms', description: 'Tucked elbows; avoid shoulders.'),
  Exercise(name: 'Single-Arm Pushdown', muscle: 'Arms', description: 'Unilateral; tidy asymmetries.'),
  Exercise(name: 'JM Press', muscle: 'Arms', description: 'Hybrid close-grip + skullcrusher.'),
  Exercise(name: 'Close-Grip Push-up', muscle: 'Arms', description: 'Triceps bias; elbows tight.'),
  Exercise(name: 'Reverse-Grip Pushdown', muscle: 'Arms', description: 'Supinated grip; medial head hit.'),
  Exercise(name: 'Cable Kickback', muscle: 'Arms', description: 'Elbow high; extend fully.'),
  Exercise(name: 'Dumbbell Kickback', muscle: 'Arms', description: 'Light weight; strict lockout.'),
  Exercise(name: 'Kettlebell Hammer Curl', muscle: 'Arms', description: 'Offset load; forearm challenge.'),
  Exercise(name: 'Cross-Body Hammer Curl', muscle: 'Arms', description: 'To opposite shoulder; brachialis.'),
  Exercise(name: 'Reverse-Grip Curl (EZ)', muscle: 'Arms', description: 'Wrist-friendly pronated curl.'),
  Exercise(name: 'Cable Reverse Curl', muscle: 'Arms', description: 'Constant tension; forearms burn.'),
  Exercise(name: 'Overhead Band Triceps Ext', muscle: 'Arms', description: 'Band; long head emphasis.'),
  Exercise(name: 'Band Pushdown', muscle: 'Arms', description: 'Portable triceps finisher.'),
  Exercise(name: 'Forearm Wrist Curl', muscle: 'Arms', description: 'Flexors; full squeeze.'),
  Exercise(name: 'Reverse Wrist Curl', muscle: 'Arms', description: 'Extensors; slow tempo.'),

  // --------- Core (add ~25) ----------
  Exercise(name: 'Crunch', muscle: 'Core', description: 'Short ROM; ribcage to pelvis.'),
  Exercise(name: 'Sit-up', muscle: 'Core', description: 'Full trunk flexion; feet anchored optional.'),
  Exercise(name: 'Cable Crunch', muscle: 'Core', description: 'Kneeling; pull rope down; curl spine.'),
  Exercise(name: 'Decline Sit-up', muscle: 'Core', description: 'Greater ROM; control descent.'),
  Exercise(name: 'Reverse Crunch', muscle: 'Core', description: 'Posterior pelvic tilt; low abs.'),
  Exercise(name: 'Hollow Body Hold', muscle: 'Core', description: 'Lumbar pressed down; ribs tucked.'),
  Exercise(name: 'Dead Bug', muscle: 'Core', description: 'Opposite arm/leg; neutral spine.'),
  Exercise(name: 'Pallof Press', muscle: 'Core', description: 'Anti-rotation; cable/band press-out.'),
  Exercise(name: 'Side Plank', muscle: 'Core', description: 'Elbow under shoulder; stack feet.'),
  Exercise(name: 'Side Plank with Hip Dip', muscle: 'Core', description: 'Controlled dips; oblique focus.'),
  Exercise(name: 'Russian Twist', muscle: 'Core', description: 'Rotate torso; keep spine tall.'),
  Exercise(name: 'V-up', muscle: 'Core', description: 'Fold body; reach hands to feet.'),
  Exercise(name: 'Toe Touches', muscle: 'Core', description: 'Legs up; crunch to toes.'),
  Exercise(name: 'Mountain Climbers', muscle: 'Core', description: 'Plank position; knees drive fast.'),
  Exercise(name: 'Ab Wheel Rollout', muscle: 'Core', description: 'Brace hard; avoid lumbar arch.'),
  Exercise(name: 'Dragon Flag', muscle: 'Core', description: 'Body rigid; lower under control.'),
  Exercise(name: 'Hanging Knee Raise', muscle: 'Core', description: 'Posterior tilt; avoid swinging.'),
  Exercise(name: 'L-Sit', muscle: 'Core', description: 'Parallel bars; legs straight out.'),
  Exercise(name: 'Windshield Wipers', muscle: 'Core', description: 'Hanging; rotate legs side to side.'),
  Exercise(name: 'Sit-up with Twist', muscle: 'Core', description: 'Add rotation at top.'),
  Exercise(name: 'Plank Shoulder Taps', muscle: 'Core', description: 'Anti-rotation; hips steady.'),
  Exercise(name: 'Bird Dog', muscle: 'Core', description: 'Opposite arm/leg reach; stay level.'),
  Exercise(name: 'Stir-the-Pot', muscle: 'Core', description: 'Forearms on ball; circles.'),
  Exercise(name: 'Farmer Carry March', muscle: 'Core', description: 'Loaded march; anti-tilt.'),
  Exercise(name: 'Reverse Hyper Crunch', muscle: 'Core', description: 'GHD; posterior chain + abs.'),

  // --------- Full Body (add ~15) ----------
  Exercise(name: 'Clean', muscle: 'Full Body', description: 'Power from hips; rack on shoulders.'),
  Exercise(name: 'Power Clean', muscle: 'Full Body', description: 'Explosive triple extension; quick rack.'),
  Exercise(name: 'Clean and Jerk', muscle: 'Full Body', description: 'Clean to rack; dip-drive to lockout.'),
  Exercise(name: 'Snatch', muscle: 'Full Body', description: 'Wide grip; overhead catch; fast.'),
  Exercise(name: 'Power Snatch', muscle: 'Full Body', description: 'Catch higher; speed emphasis.'),
  Exercise(name: 'Thruster', muscle: 'Full Body', description: 'Front squat to push press combo.'),
  Exercise(name: 'Man Maker', muscle: 'Full Body', description: 'DB burpee + row + clean + press.'),
  Exercise(name: 'Devil Press', muscle: 'Full Body', description: 'Burpee into dual DB snatch.'),
  Exercise(name: 'Bear Complex', muscle: 'Full Body', description: 'Clean, front squat, press, back squat, press.'),
  Exercise(name: 'Turkish Get-Up', muscle: 'Full Body', description: 'Kettlebell from floor to stand.'),
  Exercise(name: 'Kettlebell Clean', muscle: 'Full Body', description: 'Hip snap; rack softly.'),
  Exercise(name: 'Kettlebell Snatch', muscle: 'Full Body', description: 'Punch through; overhead lockout.'),
  Exercise(name: 'Sandbag Clean', muscle: 'Full Body', description: 'Grip awkward load; hip pop.'),
  Exercise(name: 'Burpee Pull-up', muscle: 'Full Body', description: 'Burpee then jump to pull-up.'),
  Exercise(name: 'Wall Ball', muscle: 'Full Body', description: 'Squat then throw to target.'),

  // --------- Cardio (add ~10) ----------
  Exercise(name: 'Jump Rope', muscle: 'Cardio', description: 'Rhythm hops; light on feet.'),
  Exercise(name: 'Double-Unders', muscle: 'Cardio', description: 'Two rope passes per jump.'),
  Exercise(name: 'Rowing (Erg)', muscle: 'Cardio', description: 'Leg drive; long smooth strokes.'),
  Exercise(name: 'Assault Bike', muscle: 'Cardio', description: 'Arms and legs; interval friendly.'),
  Exercise(name: 'SkiErg', muscle: 'Cardio', description: 'Hip hinge pulls; steady cadence.'),
  Exercise(name: 'Stair Climber', muscle: 'Cardio', description: 'Upright; full foot contact.'),
  Exercise(name: 'Treadmill Run', muscle: 'Cardio', description: 'Midfoot strike; relaxed shoulders.'),
  Exercise(name: 'Incline Walk', muscle: 'Cardio', description: 'Steady uphill; low impact.'),
  Exercise(name: 'Cycling (Spin Bike)', muscle: 'Cardio', description: 'Smooth cadence; avoid knee cave.'),
  Exercise(name: 'Battle Ropes', muscle: 'Cardio', description: 'Alternating waves; core braced.'),

  // --------- Extra Chest to round out count ----------
  Exercise(name: 'Decline Push-up', muscle: 'Chest', description: 'Feet elevated; upper chest load.'),
  Exercise(name: 'Incline Push-up', muscle: 'Chest', description: 'Hands on bench; easier regression.'),
  Exercise(name: 'Iso Squeeze Push-up', muscle: 'Chest', description: 'Hands inward force; isometric tension.'),
  Exercise(name: 'One-Arm Push-up (Assisted)', muscle: 'Chest', description: 'Wide stance; elevate support hand.'),
  Exercise(name: 'Cable Crossover (Mid)', muscle: 'Chest', description: 'Meet hands at sternum; squeeze.'),

  // --------- Extra Back ----------
  Exercise(name: 'Wide-Grip Pull-up', muscle: 'Back', description: 'Elbows down; chest proud.'),
  Exercise(name: 'Neutral-Grip Pull-up', muscle: 'Back', description: 'Parallel bars; shoulder-friendly.'),
  Exercise(name: 'Weighted Pull-up', muscle: 'Back', description: 'Add belt/DB; strict reps.'),
  Exercise(name: 'Band-Assisted Pull-up', muscle: 'Back', description: 'Assistance for full ROM.'),
  Exercise(name: 'Machine Row (Hammer)', muscle: 'Back', description: 'Chest pad; pull elbows back.'),

  // --------- Extra Legs ----------
  Exercise(name: 'Curtsy Lunge', muscle: 'Legs', description: 'Step behind and across; glute med.'),
  Exercise(name: 'Lateral Lunge', muscle: 'Legs', description: 'Step sideways; hips back.'),
  Exercise(name: 'Heels-Elevated Squat', muscle: 'Legs', description: 'Wedge under heels; quad bias.'),
  Exercise(name: 'Smith Machine Lunge', muscle: 'Legs', description: 'Fixed path; long stride.'),
  Exercise(name: 'Belt Squat', muscle: 'Legs', description: 'Load hips; unload spine.'),

  // --------- Extra Shoulders ----------
  Exercise(name: 'Plate Raise', muscle: 'Shoulders', description: 'Front raise with plate; controlled.'),
  Exercise(name: 'Cable Upright Row', muscle: 'Shoulders', description: 'Smooth path; elbows lead.'),
  Exercise(name: 'Rear Delt Row', muscle: 'Shoulders', description: 'Elbows wide; pull to chest.'),
  Exercise(name: 'Machine Lateral Raise', muscle: 'Shoulders', description: 'Seat height aligns shoulder joint.'),
  Exercise(name: 'Face Pull to External Rotation', muscle: 'Shoulders', description: 'ER finish; scap control.'),

  // --------- Extra Arms ----------
  Exercise(name: 'Cable One-Arm Overhead Ext', muscle: 'Arms', description: 'Stagger stance; long head focus.'),
  Exercise(name: 'Kettlebell Curl', muscle: 'Arms', description: 'Offset mass; wrist stability.'),
  Exercise(name: 'Cable High Curl', muscle: 'Arms', description: 'Arms up; constant tension.'),
  Exercise(name: 'Band Curl', muscle: 'Arms', description: 'Ascending resistance; high reps.'),
  Exercise(name: 'Dips (Chest Lean)', muscle: 'Arms', description: 'Forward torso; triceps + chest.'),

  // --------- Extra Core ----------
  Exercise(name: 'Weighted Plank', muscle: 'Core', description: 'Load on back; neutral spine.'),
  Exercise(name: 'Side Bend (DB)', muscle: 'Core', description: 'One DB; controlled lateral flexion.'),
  Exercise(name: 'Cable Woodchop (High-Low)', muscle: 'Core', description: 'Diagonal chop; rotate hips.'),
  Exercise(name: 'Cable Woodchop (Low-High)', muscle: 'Core', description: 'Diagonal lift; tall posture.'),
  Exercise(name: 'Suitcase Deadlift (Core Bias)', muscle: 'Core', description: 'One-sided bar; anti-tilt.'),

  // --------- Mixed/Accessory to reach 200 added ----------
  Exercise(name: 'Sled Push', muscle: 'Full Body', description: 'Drive through feet; steady pace.'),
  Exercise(name: 'Sled Pull (Backward)', muscle: 'Full Body', description: 'Quads burn; upright torso.'),
  Exercise(name: 'Sled Drag (Forward)', muscle: 'Full Body', description: 'Hip extension; long strides.'),
  Exercise(name: 'Farmer Carry Trap Bar', muscle: 'Full Body', description: 'Heavy holds; short steps.'),
  Exercise(name: 'Sandbag Carry', muscle: 'Full Body', description: 'Bear hug; breathe and brace.'),
  Exercise(name: 'Atlas Stone Load (Light)', muscle: 'Full Body', description: 'Round back allowed; tacky optional.'),
  Exercise(name: 'Box Jump', muscle: 'Legs', description: 'Soft landing; step down.'),
  Exercise(name: 'Broad Jump', muscle: 'Legs', description: 'Two-foot horizontal power.'),
  Exercise(name: 'Single-Leg Box Jump', muscle: 'Legs', description: 'Explosive unilateral hop.'),
  Exercise(name: 'Depth Jump', muscle: 'Legs', description: 'Drop then immediate jump.'),
  Exercise(name: 'Kettlebell Goblet Lunge', muscle: 'Legs', description: 'Front-loaded lunge; upright.'),
  Exercise(name: 'Kettlebell Front Rack Squat', muscle: 'Legs', description: 'Dual bells; core crush.'),
  Exercise(name: 'Kettlebell Walking Lunge', muscle: 'Legs', description: 'Racked or suitcase carry.'),
  Exercise(name: 'Trap Bar RDL', muscle: 'Back', description: 'Neutral handles; hinge cleanly.'),
  Exercise(name: 'Cable Hip Abduction', muscle: 'Legs', description: 'Glute med; stand tall.'),
  Exercise(name: 'Cable Hip Adduction', muscle: 'Legs', description: 'Inner thigh; slow control.'),
  Exercise(name: '90/90 Hip Lift', muscle: 'Core', description: 'Posterior tilt; hamstrings on.'),
  Exercise(name: 'Good Morning (Safety Bar)', muscle: 'Back', description: 'Comfortable rack; hinge.'),
  Exercise(name: 'Safety Bar Squat', muscle: 'Legs', description: 'Torso upright; upper-back friendly.'),
  Exercise(name: 'Front Squat (Cross-Arm)', muscle: 'Legs', description: 'Alternative rack; elbows high.'),
  Exercise(name: 'Paused Squat', muscle: 'Legs', description: '1–3s in the hole; drive up.'),
  Exercise(name: 'Tempo Squat', muscle: 'Legs', description: 'Slow eccentric; explode concentric.'),
  Exercise(name: 'Pin Squat', muscle: 'Legs', description: 'Stop on pins; overcome dead-stop.'),
  Exercise(name: 'Deficit RDL', muscle: 'Legs', description: 'Stand on plate; hamstring stretch.'),
  Exercise(name: 'Snatch-Grip RDL', muscle: 'Back', description: 'Wide grip; upper-back tension.'),
  Exercise(name: 'Hip Airplane', muscle: 'Core', description: 'Single-leg hinge; rotate pelvis.'),
  Exercise(name: 'Kettlebell Windmill', muscle: 'Core', description: 'Overhead KB; hinge and rotate.'),
  Exercise(name: 'Overhead Lunge', muscle: 'Legs', description: 'Bar/DB overhead; stabilize core.'),
  Exercise(name: 'Front Rack Lunge', muscle: 'Legs', description: 'Bar on front; upright torso.'),
  Exercise(name: 'Cyclist Squat', muscle: 'Legs', description: 'Narrow stance; heels high.'),
  Exercise(name: 'Poliquin Step-up', muscle: 'Legs', description: 'Slant board; terminal knee.'),
  Exercise(name: 'Spanish Deadlift (Band)', muscle: 'Legs', description: 'Band at hips; hinge pattern.'),
  Exercise(name: 'Hip Halo Walk', muscle: 'Legs', description: 'Band around knees; steps out.'),
  Exercise(name: 'Monster Walks', muscle: 'Legs', description: 'Band; diagonal steps.'),
  Exercise(name: 'Clamshell', muscle: 'Legs', description: 'Side-lying; open knees.'),
  Exercise(name: 'Copenhagen Plank', muscle: 'Core', description: 'Adductor side plank; top leg supported.'),
  Exercise(name: 'Nordic Hip Hinge', muscle: 'Back', description: 'Partnered hinge; ham focus.'),
  Exercise(name: 'Back Extension (45°)', muscle: 'Back', description: 'Hyper bench; hinge pattern.'),
  Exercise(name: 'GHD Sit-up', muscle: 'Core', description: 'Full ROM; control spine.'),
  Exercise(name: 'Reverse Lunge to Knee Drive', muscle: 'Legs', description: 'Explosive drive up.'),
  Exercise(name: 'Split Squat Jumps', muscle: 'Legs', description: 'Alternating plyo lunges.'),
  Exercise(name: 'Speed Skater Jumps', muscle: 'Legs', description: 'Lateral bounds; stick land.'),
  Exercise(name: 'Kettlebell Dead Clean', muscle: 'Full Body', description: 'Hip snap; rack softly.'),
  Exercise(name: 'Kettlebell Long Cycle', muscle: 'Full Body', description: 'Clean and jerk for reps.'),
  Exercise(name: 'Sandbag Shouldering', muscle: 'Full Body', description: 'Load to shoulder; alternate sides.'),
  Exercise(name: 'Log Clean & Press (Light)', muscle: 'Full Body', description: 'Neutral handles; leg drive.'),
  Exercise(name: 'Axle Deadlift', muscle: 'Back', description: 'Thick bar; grip challenge.'),
  Exercise(name: 'Deficit Split Squat', muscle: 'Legs', description: 'Front foot on plate; depth.'),
  Exercise(name: 'Single-Leg Press', muscle: 'Legs', description: 'Unilateral machine press.'),
  Exercise(name: 'Hip Thrust (Single-Leg)', muscle: 'Legs', description: 'Unilateral glute lockout.'),
  Exercise(name: 'Step-up (High Box)', muscle: 'Legs', description: 'Control; push through heel.'),
  Exercise(name: 'Kettlebell Suitcase Deadlift', muscle: 'Core', description: 'Asym load; anti-tilt.'),
  Exercise(name: 'Deadlift Iso Hold', muscle: 'Back', description: 'Hold at lockout; grip focus.'),
  Exercise(name: 'Plate Pinch Hold', muscle: 'Arms', description: 'Thumbs + fingers; grip work.'),
  Exercise(name: 'Towel Pull-up', muscle: 'Back', description: 'Grip burner; neutral wrists.'),
  Exercise(name: 'Mixed-Grip Deadlift', muscle: 'Back', description: 'Supinated/pronated; lock lats.'),
  Exercise(name: 'RDL to Row Combo', muscle: 'Back', description: 'Hinge then row; complex.'),
  Exercise(name: 'Eccentric Pull-up', muscle: 'Back', description: 'Jump up; slow 5–8s down.'),
  Exercise(name: 'Scap Pull-up', muscle: 'Back', description: 'Depress/retract only; small ROM.'),
  Exercise(name: 'Lat Prayer Stretch Pulldown', muscle: 'Back', description: 'Kneel; sweep to thighs.'),
  Exercise(name: 'Cable Rear Delt Row', muscle: 'Shoulders', description: 'Elbows flared; midline pull.'),
  Exercise(name: 'Prone W Raise', muscle: 'Shoulders', description: 'Scap retraction + ER.'),
  Exercise(name: 'Prone T Raise', muscle: 'Shoulders', description: 'Mid traps; thumbs up.'),
  Exercise(name: 'Prone Y Raise', muscle: 'Shoulders', description: 'Lower traps; reach long.'),
  Exercise(name: 'Band Pull-Apart', muscle: 'Shoulders', description: 'Scap set; straight arms.'),
  Exercise(name: 'External Rotation (Cable)', muscle: 'Shoulders', description: 'Elbow at side; rotate out.'),
  Exercise(name: 'Internal Rotation (Cable)', muscle: 'Shoulders', description: 'Elbow at side; rotate in.'),
  Exercise(name: 'Overhead Carry', muscle: 'Full Body', description: 'DB/Kettlebell; ribs down.'),
  Exercise(name: 'Front Rack Carry', muscle: 'Full Body', description: 'Elbows forward; brace tight.'),
  Exercise(name: 'Zercher Carry', muscle: 'Full Body', description: 'Bar in elbows; walk tall.'),
  Exercise(name: 'Bear Crawl', muscle: 'Full Body', description: 'Hips low; contralateral steps.'),
  Exercise(name: 'Crab Walk', muscle: 'Full Body', description: 'Hips up; backwards/forwards.'),
  Exercise(name: 'Lateral Bear Crawl', muscle: 'Full Body', description: 'Sideways crawl; core on.'),
  Exercise(name: 'Sprint (Flat)', muscle: 'Cardio', description: 'Max effort; full recovery.'),
  Exercise(name: 'Hill Sprint', muscle: 'Cardio', description: 'Uphill; reduced impact.'),
  Exercise(name: 'Sled Sprint', muscle: 'Cardio', description: 'Resisted acceleration.'),
  Exercise(name: 'Shadow Boxing', muscle: 'Cardio', description: 'Light combos; quick feet.'),
  Exercise(name: 'Boxing Heavy Bag', muscle: 'Cardio', description: 'Rounds; power shots.'),
  Exercise(name: 'Jumping Jacks', muscle: 'Cardio', description: 'Arms overhead; steady rhythm.'),
  Exercise(name: 'High Knees', muscle: 'Cardio', description: 'Fast cadence; pump arms.'),
  Exercise(name: 'Butt Kicks', muscle: 'Cardio', description: 'Hamstring activation; quick steps.'),
  Exercise(name: 'Burpee Box Jump', muscle: 'Full Body', description: 'Burpee then jump on box.'),
  Exercise(name: 'Overhead Med Ball Slam', muscle: 'Full Body', description: 'Explosive slam; reset fast.'),
  Exercise(name: 'Rotational Med Ball Throw', muscle: 'Full Body', description: 'Hip rotate; wall throw.'),
  Exercise(name: 'Chest Pass Med Ball', muscle: 'Chest', description: 'Explosive throw; catch rebound.'),
  Exercise(name: 'Lateral Med Ball Toss', muscle: 'Full Body', description: 'Side throw; load hips.'),
  Exercise(name: 'KB Gorilla Row', muscle: 'Back', description: 'Hinge; alternating rows.'),
  Exercise(name: 'KB Dead Stop Row', muscle: 'Back', description: 'Reset on floor; strict pull.'),
  Exercise(name: 'DB Row on Bench', muscle: 'Back', description: 'Knee/hand support; pull to hip.'),
  Exercise(name: 'Cable Lat Prayer', muscle: 'Back', description: 'Tall kneel; sweep down.'),
  Exercise(name: 'Smith Machine RDL', muscle: 'Back', description: 'Guided hinge; hamstrings.'),
  Exercise(name: 'Smith Machine Calf Raise', muscle: 'Legs', description: 'Set stops; full ROM.'),
  Exercise(name: 'Standing Adductor Machine', muscle: 'Legs', description: 'Squeeze pads inward.'),
  Exercise(name: 'Standing Abductor Machine', muscle: 'Legs', description: 'Press pads outward.'),
  Exercise(name: 'Hip Thrust (Foam Pad)', muscle: 'Legs', description: 'Pad for comfort; full lock.'),
  Exercise(name: 'Barbell Glute Bridge', muscle: 'Legs', description: 'Floor version; squeeze peak.'),
  Exercise(name: 'Single-Leg Box Squat', muscle: 'Legs', description: 'Control to box; stand tall.'),
  Exercise(name: 'Seated Good Morning', muscle: 'Back', description: 'Hips hinge seated; erectors.'),
  Exercise(name: 'Good Morning (Banded)', muscle: 'Back', description: 'Band posterior chain finisher.'),
  Exercise(name: 'Hip Hinge Wall Drill', muscle: 'Back', description: 'Butt to wall; learn hinge.'),
  Exercise(name: 'Heel Slide Curl', muscle: 'Legs', description: 'Sliders; hamstring curl.'),
  Exercise(name: 'Hamstring Walkouts', muscle: 'Legs', description: 'Bridge then small steps out.'),
  Exercise(name: 'Spanish Squat Iso Hold', muscle: 'Legs', description: 'Band; sit and hold.'),
  Exercise(name: 'Isometric Mid-Thigh Pull', muscle: 'Full Body', description: 'Against pins; maximal pull.'),
  Exercise(name: 'Pin Press (Bench)', muscle: 'Chest', description: 'Bar on pins; lockout power.'),
  Exercise(name: 'Board Press', muscle: 'Chest', description: 'Range limiter; triceps heavy.'),
  Exercise(name: 'Floor Flye', muscle: 'Chest', description: 'Arms stop at floor; safer shoulders.'),
  Exercise(name: 'Cable Press Around', muscle: 'Chest', description: 'Arc across body; adduction.'),
  Exercise(name: 'Reverse-Grip Bench Press', muscle: 'Chest', description: 'Supinated grip; upper chest.'),
  Exercise(name: 'Incline Smith Press', muscle: 'Chest', description: 'Fixed path; upper chest sets.'),
  Exercise(name: 'Partial ROM Bench', muscle: 'Chest', description: 'Top-half overload; triceps.'),
  Exercise(name: 'Overhead Triceps Extension (EZ)', muscle: 'Arms', description: 'Seated; long head stretch.'),
  Exercise(name: 'Rolling DB Triceps Ext', muscle: 'Arms', description: 'Elbows travel; shoulder friendly.'),
  Exercise(name: 'Cable Crossbody Extension', muscle: 'Arms', description: 'Across face; lock out.'),
  Exercise(name: 'Pressdown (V-Bar)', muscle: 'Arms', description: 'Neutral grip; strong finish.'),
  Exercise(name: 'Overhead Rope Extension', muscle: 'Arms', description: 'Flare rope at top.'),
  Exercise(name: 'Kettlebell Skullcrusher', muscle: 'Arms', description: 'Neutral wrists; control.'),
  Exercise(name: 'Tate Press', muscle: 'Arms', description: 'DBs to chest; triceps burn.'),
  Exercise(name: 'Reverse-Grip Bench Dip', muscle: 'Arms', description: 'Supinated; small ROM.'),
  Exercise(name: 'Incline Curl', muscle: 'Arms', description: 'Long head; elbows back.'),
  Exercise(name: 'Cable Preacher Curl', muscle: 'Arms', description: 'Pad + cable; tension constant.'),
  Exercise(name: 'Machine Curl', muscle: 'Arms', description: 'Fixed track; peak squeeze.'),
  Exercise(name: 'One-Arm Preacher Curl', muscle: 'Arms', description: 'Unilateral; strict.'),
  Exercise(name: 'Band Face Curl', muscle: 'Arms', description: 'Band curl to forehead.'),
  Exercise(name: 'Wrist Roller', muscle: 'Arms', description: 'Roll up/down; forearms.'),
  Exercise(name: 'Plate Curl', muscle: 'Arms', description: 'Pinch plate; supinate up.'),
  Exercise(name: 'Cable Rope Hammer Curl', muscle: 'Arms', description: 'Neutral grip; end flare.'),
  Exercise(name: 'JM Press (Smith)', muscle: 'Arms', description: 'Guided triceps compound.'),
  Exercise(name: 'Close-Grip Board Press', muscle: 'Arms', description: 'Triceps lockout focus.'),
  Exercise(name: 'French Press (EZ)', muscle: 'Arms', description: 'Lying triceps; behind head.'),
  Exercise(name: 'Crossbody Cable Extension', muscle: 'Arms', description: 'Elbow high; extend across.'),
  Exercise(name: 'Forearm Pronation/Supination', muscle: 'Arms', description: 'DB/hammer; rotation work.'),

  // --------- Extra Cardio finishers ----------
  Exercise(name: 'Row Sprint Intervals', muscle: 'Cardio', description: '30/30s or similar bursts.'),
  Exercise(name: 'Bike Sprint Intervals', muscle: 'Cardio', description: 'All-out then recover.'),
  Exercise(name: 'Treadmill Sprint Intervals', muscle: 'Cardio', description: 'Timed repeats; safe dismount.'),
  Exercise(name: 'Shuttle Runs', muscle: 'Cardio', description: 'Short sprints; quick turns.'),
  Exercise(name: 'Farmer Carry Intervals', muscle: 'Cardio', description: 'Timed heavy carries.'),

  // --------- Mobility/Prehab (still categorized) ----------
  Exercise(name: 'Banded Shoulder Dislocates', muscle: 'Shoulders', description: 'Wide grip; smooth arcs.'),
  Exercise(name: 'Scap Push-up', muscle: 'Shoulders', description: 'Protraction/retraction only.'),
  Exercise(name: 'Thoracic Extension on Foam Roller', muscle: 'Back', description: 'Upper-back mobility.'),
  Exercise(name: '90/90 Shoulder External Rotation', muscle: 'Shoulders', description: 'Elbow at 90; rotate.'),
  Exercise(name: 'Ankle Dorsiflexion Rock', muscle: 'Legs', description: 'Knee to wall; controlled.'),

  // ===== Chest (25) =====
  Exercise(name: 'Machine Incline Chest Press', muscle: 'Chest', description: 'Guided path; upper-chest focus.'),
  Exercise(name: 'Machine Decline Chest Press', muscle: 'Chest', description: 'Fixed arc; lower-chest emphasis.'),
  Exercise(name: 'Smith Machine Incline Press', muscle: 'Chest', description: 'Fixed track; steady tempo.'),
  Exercise(name: 'Smith Machine Decline Press', muscle: 'Chest', description: 'Reduced stabilizers; lower chest.'),
  Exercise(name: 'Weighted Dips (Chest Lean)', muscle: 'Chest', description: 'Forward torso; adduction squeeze.'),
  Exercise(name: 'Ring Dips (Chest)', muscle: 'Chest', description: 'Instability; deep stretch.'),
  Exercise(name: 'Cable Flye (Mid-to-Mid)', muscle: 'Chest', description: 'Meet at sternum; slight cross.'),
  Exercise(name: 'Cable Flye (One-Arm)', muscle: 'Chest', description: 'Unilateral adduction; anti-rotation.'),
  Exercise(name: 'Low Cable Press', muscle: 'Chest', description: 'From low pulleys; arc upward.'),
  Exercise(name: 'High Cable Press', muscle: 'Chest', description: 'From high pulleys; arc downward.'),
  Exercise(name: 'Standing Landmine Flye', muscle: 'Chest', description: 'Arc in toward midline.'),
  Exercise(name: 'Dumbbell Squeeze Press', muscle: 'Chest', description: 'DBs pressed together; inner chest.'),
  Exercise(name: 'Hex Press', muscle: 'Chest', description: 'DBs touching; slow eccentric.'),
  Exercise(name: 'Floor Flye (DB)', muscle: 'Chest', description: 'Limited ROM; shoulder-friendly.'),
  Exercise(name: 'Push-up (Clap)', muscle: 'Chest', description: 'Plyometric; explosive press.'),
  Exercise(name: 'Push-up (Spiderman)', muscle: 'Chest', description: 'Knee to elbow during push.'),
  Exercise(name: 'Push-up (Pseudo Planche)', muscle: 'Chest', description: 'Hands by hips; forward lean.'),
  Exercise(name: 'Push-up (Archer Ring)', muscle: 'Chest', description: 'Ring instability; side load.'),
  Exercise(name: 'Crossover Push-up', muscle: 'Chest', description: 'Hand on plate; switch sides.'),
  Exercise(name: 'Isometric Chest Press (Plate)', muscle: 'Chest', description: 'Squeeze plate at chest.'),
  Exercise(name: 'Flye Machine (Reverse Grip)', muscle: 'Chest', description: 'Supinated grip; upper chest.'),
  Exercise(name: 'Guillotine DB Press', muscle: 'Chest', description: 'Light weight; bar-to-neck pattern.'),
  Exercise(name: 'Cable Press Around (One-Arm)', muscle: 'Chest', description: 'Wrap arc across torso.'),
  Exercise(name: 'Incline Close-Grip DB Press', muscle: 'Chest', description: 'Narrow DB path; triceps assist.'),
  Exercise(name: 'Tempo Bench (3-1-1)', muscle: 'Chest', description: 'Slow down, pause, drive up.'),

  // ===== Back (25) =====
  Exercise(name: 'Machine High Row', muscle: 'Back', description: 'Elbows down/back; lat focus.'),
  Exercise(name: 'Machine Low Row', muscle: 'Back', description: 'Pull to navel; mid-back.'),
  Exercise(name: 'Seal Row (Barbell)', muscle: 'Back', description: 'Bench-supported; strict pull.'),
  Exercise(name: 'Chest-Supported T-Bar Row', muscle: 'Back', description: 'No low-back stress; heavy rows.'),
  Exercise(name: 'One-Arm Barbell Row', muscle: 'Back', description: 'Barbell end loaded; hip hinge.'),
  Exercise(name: 'Dual Cable Row', muscle: 'Back', description: 'Independently moving handles.'),
  Exercise(name: 'Wide Neutral Pulldown', muscle: 'Back', description: 'Parallel grip; shoulder-friendly.'),
  Exercise(name: 'Behind-the-Neck Pulldown (Light)', muscle: 'Back', description: 'ROM limited; upright spine.'),
  Exercise(name: 'Kneeling Lat Pulldown', muscle: 'Back', description: 'Tall kneel; torso stable.'),
  Exercise(name: 'Pullover (Machine)', muscle: 'Back', description: 'Lat isolation; elbows fixed.'),
  Exercise(name: 'Dumbbell Pullover (Lat Bias)', muscle: 'Back', description: 'Arms soft; ribcage down.'),
  Exercise(name: 'Cable Pullover (Bar)', muscle: 'Back', description: 'Straight arms; sweep to thighs.'),
  Exercise(name: 'Chest-Supported Rear Delt Row', muscle: 'Back', description: 'Elbows flared; upper-back.'),
  Exercise(name: 'Snatch-Grip Barbell Row', muscle: 'Back', description: 'Wide grip; upper-back load.'),
  Exercise(name: 'Underhand Barbell Row', muscle: 'Back', description: 'Supinated; lower-lat line.'),
  Exercise(name: 'Lever Row (Iso-Lateral)', muscle: 'Back', description: 'Single-side focus; brace core.'),
  Exercise(name: 'Kelso Shrug', muscle: 'Back', description: 'Row + shrug; mid traps.'),
  Exercise(name: 'Prone Chest-Supported Shrug', muscle: 'Back', description: 'Scap elevation/depression only.'),
  Exercise(name: 'Cable Face Pull (Kneeling)', muscle: 'Back', description: 'Set hips; rope to eyes.'),
  Exercise(name: 'Reverse Pec Deck', muscle: 'Back', description: 'Rear delts and mid traps.'),
  Exercise(name: 'Band-Assisted Inverted Row', muscle: 'Back', description: 'Full ROM regression.'),
  Exercise(name: 'Weighted Inverted Row', muscle: 'Back', description: 'Add plate/vest; strict.'),
  Exercise(name: 'Deficit Trap Bar Deadlift', muscle: 'Back', description: 'Stand on plate; longer ROM.'),
  Exercise(name: 'Paused Deadlift (Below Knee)', muscle: 'Back', description: 'Stop mid-shin; maintain lats.'),
  Exercise(name: 'RDL (Tempo 4s Down)', muscle: 'Back', description: 'Long eccentric; hamstring load.'),

  // ===== Legs (25) =====
  Exercise(name: 'Smith Machine Split Squat', muscle: 'Legs', description: 'Guided unilateral; long stride.'),
  Exercise(name: 'Pendulum Squat', muscle: 'Legs', description: 'Machine; deep knee travel.'),
  Exercise(name: 'V-Squat (Machine)', muscle: 'Legs', description: 'Back-supported; quad focus.'),
  Exercise(name: 'Power Squat (Machine)', muscle: 'Legs', description: 'Plate-loaded; stable path.'),
  Exercise(name: 'Prowler Push', muscle: 'Legs', description: 'Drive quads; steady steps.'),
  Exercise(name: 'Backward Sled Drag', muscle: 'Legs', description: 'Knee over toes; quad burn.'),
  Exercise(name: 'Spanish Split Squat', muscle: 'Legs', description: 'Band around knees; upright.'),
  Exercise(name: 'Reverse Nordics', muscle: 'Legs', description: 'Quad lengthening; torso tall.'),
  Exercise(name: 'Seated Good Morning (SSB)', muscle: 'Legs', description: 'Hamstrings + erectors seated.'),
  Exercise(name: 'Hamstring Curl (Standing)', muscle: 'Legs', description: 'Unilateral; top squeeze.'),
  Exercise(name: 'Glute Kickback (Cable)', muscle: 'Legs', description: 'Hip extension; squeeze glutes.'),
  Exercise(name: 'Glute Kickback (Machine)', muscle: 'Legs', description: 'Guided hip drive.'),
  Exercise(name: 'Hip Abduction (Cable)', muscle: 'Legs', description: 'Glute med/min; slow control.'),
  Exercise(name: 'Hip Adduction (Cable)', muscle: 'Legs', description: 'Inner thigh; tall posture.'),
  Exercise(name: 'Duck Walk (Band)', muscle: 'Legs', description: 'Band above knees; small steps.'),
  Exercise(name: 'Heels-Elevated Hack Squat', muscle: 'Legs', description: 'Wedge; knee travel forward.'),
  Exercise(name: 'Kang Squat', muscle: 'Legs', description: 'Good morning into squat combo.'),
  Exercise(name: 'Front Squat (Straps)', muscle: 'Legs', description: 'Strap-assisted front rack.'),
  Exercise(name: 'Tempo Lunge (3s Down)', muscle: 'Legs', description: 'Eccentric control; balance.'),
  Exercise(name: 'Walking Lunge (Front Rack)', muscle: 'Legs', description: 'Barbell front rack; upright.'),
  Exercise(name: 'Step-Down (Lateral)', muscle: 'Legs', description: 'Lateral control; knee track.'),
  Exercise(name: 'Sissy Squat (Assisted)', muscle: 'Legs', description: 'Hold support; knee travel.'),
  Exercise(name: 'Jefferson Lunge', muscle: 'Legs', description: 'Straddle bar; anti-rotation.'),
  Exercise(name: 'Box Pistol Squat', muscle: 'Legs', description: 'To box; single-leg pattern.'),
  Exercise(name: 'Seated Calf Raise (Single-Leg)', muscle: 'Legs', description: 'Unilateral soleus work.'),

  // ===== Shoulders (25) =====
  Exercise(name: 'Standing Dumbbell Press (Neutral)', muscle: 'Shoulders', description: 'Neutral grip; scapular plane.'),
  Exercise(name: 'Single-Arm Landmine Press', muscle: 'Shoulders', description: 'Angled path; core anti-rot.'),
  Exercise(name: 'Kettlebell Strict Press', muscle: 'Shoulders', description: 'Bell rests on forearm; lockout.'),
  Exercise(name: 'Kettlebell Bottom-Up Press', muscle: 'Shoulders', description: 'Grip/stability challenge.'),
  Exercise(name: 'Machine Lateral Raise (Unilateral)', muscle: 'Shoulders', description: 'Side by side; strict.'),
  Exercise(name: 'Cable Lateral Raise (Behind Back)', muscle: 'Shoulders', description: 'Stretch start; smooth arc.'),
  Exercise(name: 'Prone Rear Delt Flye (Incline)', muscle: 'Shoulders', description: 'Chest on bench; pinkies high.'),
  Exercise(name: 'Reverse Cable Crossover (Rear Delt)', muscle: 'Shoulders', description: 'Cross arms; small ROM.'),
  Exercise(name: 'Snatch-Grip Push Press', muscle: 'Shoulders', description: 'Wide grip; dip-drive.'),
  Exercise(name: 'Muscle Snatch (Light)', muscle: 'Shoulders', description: 'No re-bend; crisp turnover.'),
  Exercise(name: 'Bradford Press (Smith)', muscle: 'Shoulders', description: 'Front/back partials; no lock.'),
  Exercise(name: 'Partial Lateral Raise (Top Half)', muscle: 'Shoulders', description: 'Short ROM overload.'),
  Exercise(name: 'Incline Y-Raise (DB)', muscle: 'Shoulders', description: 'Lower traps; reach long.'),
  Exercise(name: 'Scaption Raise (Cable)', muscle: 'Shoulders', description: 'Thumbs up; scap plane.'),
  Exercise(name: 'Front Raise (Cable Rope)', muscle: 'Shoulders', description: 'Smooth tension; eye level.'),
  Exercise(name: 'Upright Row (Kettlebell)', muscle: 'Shoulders', description: 'Elbows high; neutral wrists.'),
  Exercise(name: 'Cuban Rotation (Cable)', muscle: 'Shoulders', description: 'High pull + ER; light.'),
  Exercise(name: 'External Rotation (Side-Lying)', muscle: 'Shoulders', description: 'Rotator cuff; slow.'),
  Exercise(name: 'Internal Rotation (Side-Lying)', muscle: 'Shoulders', description: 'Rotator cuff; steady.'),
  Exercise(name: 'Handstand Shoulder Taps', muscle: 'Shoulders', description: 'Wall support; alternating taps.'),
  Exercise(name: 'Wall Walks', muscle: 'Shoulders', description: 'Crawl up wall to HS; control.'),
  Exercise(name: 'Pike Handstand Hold', muscle: 'Shoulders', description: 'Feet on box; vertical press.'),
  Exercise(name: 'Lateral Raise (Cable Behind Body)', muscle: 'Shoulders', description: 'Cable starts behind hip.'),
  Exercise(name: 'Serratus Wall Slides', muscle: 'Shoulders', description: 'Foam roller; protraction.'),
  Exercise(name: 'Overhead Shrug', muscle: 'Shoulders', description: 'Bar overhead; shrug up.'),

  // ===== Arms (25) =====
  Exercise(name: 'Cable Concentration Curl', muscle: 'Arms', description: 'Kneeling; constant tension.'),
  Exercise(name: 'High Cable Curl (Dual)', muscle: 'Arms', description: 'Arms abducted; peak bias.'),
  Exercise(name: 'Machine Preacher Curl', muscle: 'Arms', description: 'Fixed pad; strict reps.'),
  Exercise(name: 'Spider Curl (Cable)', muscle: 'Arms', description: 'Chest on bench; smooth tension.'),
  Exercise(name: 'Kettlebell Zottman Curl', muscle: 'Arms', description: 'Supinate up; pronate down.'),
  Exercise(name: 'Reverse Curl (Fat Grip)', muscle: 'Arms', description: 'Thick handle; forearms.'),
  Exercise(name: 'Cable Reverse Curl (EZ Attachment)', muscle: 'Arms', description: 'Pronated; wrist-friendly.'),
  Exercise(name: 'Cross-Body Cable Curl', muscle: 'Arms', description: 'To opposite shoulder; long head.'),
  Exercise(name: 'Incline Cable Curl', muscle: 'Arms', description: 'Elbows back; stretch.'),
  Exercise(name: 'Overhead Cable Curl', muscle: 'Arms', description: 'Arms high; constant tension.'),
  Exercise(name: 'French Press (DB)', muscle: 'Arms', description: 'Seated two-DB triceps.'),
  Exercise(name: 'Overhead Triceps (Kettlebell)', muscle: 'Arms', description: 'Bell behind head; lockout.'),
  Exercise(name: 'Cable Cross-Body Triceps Ext', muscle: 'Arms', description: 'Across face; full extension.'),
  Exercise(name: 'Underhand Pushdown', muscle: 'Arms', description: 'Supinated; medial head bias.'),
  Exercise(name: 'Dip Machine', muscle: 'Arms', description: 'Guided triceps press-down.'),
  Exercise(name: 'Close-Grip Floor Press', muscle: 'Arms', description: 'Triceps lockout; reduced ROM.'),
  Exercise(name: 'JM Press (Dumbbells)', muscle: 'Arms', description: 'Hybrid press + extension.'),
  Exercise(name: 'Cable Tate Press', muscle: 'Arms', description: 'Rope or handles; squeeze top.'),
  Exercise(name: 'Forearm Farmer Hold', muscle: 'Arms', description: 'Heavy static grip carry.'),
  Exercise(name: 'Plate Wrist Curl (Edge)', muscle: 'Arms', description: 'Forearms on bench; curl plate.'),
  Exercise(name: 'Cable Wrist Flexion', muscle: 'Arms', description: 'Low pulley; strict flexion.'),
  Exercise(name: 'Cable Wrist Extension', muscle: 'Arms', description: 'Low pulley; strict extension.'),
  Exercise(name: 'Reverse Grip EZ Skullcrusher', muscle: 'Arms', description: 'Supinated; elbow-friendly.'),
  Exercise(name: 'Incline Tate Press', muscle: 'Arms', description: 'DBs touch chest; extend.'),
  Exercise(name: 'One-Arm Cable Pushdown (Kneeling)', muscle: 'Arms', description: 'Stabilize torso; full lock.'),

  // ===== Core (25) =====
  Exercise(name: 'Swiss Ball Crunch', muscle: 'Core', description: 'Greater ROM; ribcage to pelvis.'),
  Exercise(name: 'Swiss Ball Stir-the-Pot', muscle: 'Core', description: 'Circles; core brace.'),
  Exercise(name: 'Swiss Ball Pike', muscle: 'Core', description: 'Hips high; controlled fold.'),
  Exercise(name: 'Swiss Ball Rollout', muscle: 'Core', description: 'Similar to wheel; brace.'),
  Exercise(name: 'TRX Fallout', muscle: 'Core', description: 'Suspension rollout; neutral spine.'),
  Exercise(name: 'TRX Body Saw', muscle: 'Core', description: 'Forearm plank; rock back/forward.'),
  Exercise(name: 'Side Plank Star', muscle: 'Core', description: 'Top leg raised; adductors on.'),
  Exercise(name: 'RKC Plank', muscle: 'Core', description: 'Hard brace; short duration.'),
  Exercise(name: 'Long Lever Plank', muscle: 'Core', description: 'Elbows ahead of shoulders.'),
  Exercise(name: 'Hanging Oblique Raise', muscle: 'Core', description: 'Knees to sides; no swing.'),
  Exercise(name: 'Captain’s Chair Leg Raise', muscle: 'Core', description: 'Elbows on pads; tilt pelvis.'),
  Exercise(name: 'Cable Woodchop (Horizontal)', muscle: 'Core', description: 'Rotate torso; hips square.'),
  Exercise(name: 'Half-Kneeling Pallof Press', muscle: 'Core', description: 'Anti-rotation; glute on.'),
  Exercise(name: 'Tall-Kneeling Pallof Press', muscle: 'Core', description: 'Ribs down; squeeze glutes.'),
  Exercise(name: 'Oblique Crunch (Machine)', muscle: 'Core', description: 'Side bend; control ROM.'),
  Exercise(name: 'Decline Reverse Crunch', muscle: 'Core', description: 'Posterior tilt; slow return.'),
  Exercise(name: 'Hanging Toes-to-Bar', muscle: 'Core', description: 'Touch bar; hollow body.'),
  Exercise(name: 'L-Sit on Rings', muscle: 'Core', description: 'Scap depression; legs parallel.'),
  Exercise(name: 'Ab Mat Sit-up', muscle: 'Core', description: 'Lumbar support; full sit.'),
  Exercise(name: 'McGill Curl-Up', muscle: 'Core', description: 'Neutral spine; one knee bent.'),
  Exercise(name: 'Side Bend (Cable)', muscle: 'Core', description: 'Lateral flexion; obliques.'),
  Exercise(name: 'Cable Anti-Extension', muscle: 'Core', description: 'Walkout hold; neutral ribs.'),
  Exercise(name: 'Dead Bug (Band Resisted)', muscle: 'Core', description: 'Band overhead; anti-ext.'),
  Exercise(name: 'Birddog Row', muscle: 'Core', description: 'Bench birddog + DB row combo.'),
  Exercise(name: 'Hanging L-Sit Hold', muscle: 'Core', description: 'Static 90° hip flexion.'),

  // ===== Full Body (25) =====
  Exercise(name: 'Complex A (Row+Clean+Front Squat+Press)', muscle: 'Full Body', description: 'Barbell complex; no drop.'),
  Exercise(name: 'Complex B (RDL+Row+Hang Clean+Jerk)', muscle: 'Full Body', description: 'Bar flow; moderate load.'),
  Exercise(name: 'KB Complex (Swing+Clean+Press)', muscle: 'Full Body', description: 'Unbroken series; both sides.'),
  Exercise(name: 'Bear Crawl Pull-Through', muscle: 'Full Body', description: 'Crawl with KB drag.'),
  Exercise(name: 'Crawl to Push-up', muscle: 'Full Body', description: 'Forward crawl then strict push-up.'),
  Exercise(name: 'Devil Clean (DB)', muscle: 'Full Body', description: 'Burpee into double DB clean.'),
  Exercise(name: 'Ground-to-Overhead (Plate)', muscle: 'Full Body', description: 'From floor to lockout.'),
  Exercise(name: 'Sandbag Over Shoulder', muscle: 'Full Body', description: 'Hip pop; alternate sides.'),
  Exercise(name: 'Sandbag Carry (Bear Hug)', muscle: 'Full Body', description: 'Odd object; brace torso.'),
  Exercise(name: 'Yoke Zercher Carry', muscle: 'Full Body', description: 'Yoke in elbow pits; walk tall.'),
  Exercise(name: 'Sled Rope Pull', muscle: 'Full Body', description: 'Hand-over-hand pull; back/arms.'),
  Exercise(name: 'Sled Push to Sprint', muscle: 'Full Body', description: 'Transition to unresisted run.'),
  Exercise(name: 'Wall Ball (Heavy)', muscle: 'Full Body', description: 'Lower target volume; power.'),
  Exercise(name: 'Thruster (Dumbbell)', muscle: 'Full Body', description: 'DB front squat into press.'),
  Exercise(name: 'Cluster (Clean+Thruster)', muscle: 'Full Body', description: 'Clean then thruster rep.'),
  Exercise(name: 'Man-Maker (Push-up+Row+Clean+Press)', muscle: 'Full Body', description: 'DB sequence; finish stand.'),
  Exercise(name: 'Burpee to DB Snatch', muscle: 'Full Body', description: 'Alt arms; overhead finish.'),
  Exercise(name: 'KB Clean and Jerk (Long Cycle)', muscle: 'Full Body', description: 'Endurance set; pace.'),
  Exercise(name: 'KB Half Snatch', muscle: 'Full Body', description: 'Lower to rack; save grip.'),
  Exercise(name: 'Med Ball Clean', muscle: 'Full Body', description: 'Triple extension; quick elbows.'),
  Exercise(name: 'Med Ball Thruster', muscle: 'Full Body', description: 'Squat and press ball.'),
  Exercise(name: 'Axle Clean (Continental)', muscle: 'Full Body', description: 'Thick bar; belly shelf.'),
  Exercise(name: 'Log Viper Press (Light)', muscle: 'Full Body', description: 'No jerk; leg drive to press.'),
  Exercise(name: 'Odd-Object Shouldering', muscle: 'Full Body', description: 'Stones/sandbags; braced back.'),
  Exercise(name: 'Suitcase Carry to Press', muscle: 'Full Body', description: 'Carry then strict single-arm press.'),

  // ===== Cardio (25) =====
  Exercise(name: 'Row Erg Long Steady', muscle: 'Cardio', description: 'Zone 2; nasal breathing.'),
  Exercise(name: 'Row Erg Pyramid Intervals', muscle: 'Cardio', description: '1-2-3-2-1 min efforts.'),
  Exercise(name: 'Air Bike Long Steady', muscle: 'Cardio', description: 'Even cadence; low RPE.'),
  Exercise(name: 'Air Bike Tabata', muscle: 'Cardio', description: '20s on/10s off x8.'),
  Exercise(name: 'SkiErg Long Steady', muscle: 'Cardio', description: 'Hip hinge pulls; aerobic.'),
  Exercise(name: 'SkiErg Sprint Repeats', muscle: 'Cardio', description: 'Hard 250m; full rest.'),
  Exercise(name: 'Treadmill Hill Intervals', muscle: 'Cardio', description: 'Incline repeats; steady pace.'),
  Exercise(name: 'Track Repeats (400m)', muscle: 'Cardio', description: 'Even splits; walk rest.'),
  Exercise(name: 'Stair Climber Intervals', muscle: 'Cardio', description: '1:1 work:rest sets.'),
  Exercise(name: 'Outdoor Tempo Run', muscle: 'Cardio', description: 'Comfortably hard pace.'),
  Exercise(name: 'Ruck Walk', muscle: 'Cardio', description: 'Loaded pack; brisk walk.'),
  Exercise(name: 'Agility Ladder (Fast Feet)', muscle: 'Cardio', description: 'Light contacts; rhythm.'),
  Exercise(name: 'Shuttle Run (5-10-5)', muscle: 'Cardio', description: 'Pro-agility pattern.'),
  Exercise(name: 'Box Step-Overs (DB)', muscle: 'Cardio', description: 'Continuous; light weights.'),
  Exercise(name: 'Jump Rope (Criss-Cross)', muscle: 'Cardio', description: 'Cross arms while jumping.'),
  Exercise(name: 'Jump Rope (Side Swing)', muscle: 'Cardio', description: 'Alternate side swings.'),
  Exercise(name: 'Jump Rope (EB Swing)', muscle: 'Cardio', description: 'Behind-the-back cross.'),
  Exercise(name: 'Burpee Broad Jump', muscle: 'Cardio', description: 'Burpee then long jump.'),
  Exercise(name: 'Mountain Climbers (Cross-Body)', muscle: 'Cardio', description: 'Knee to opposite elbow.'),
  Exercise(name: 'High Knees in Place (Intervals)', muscle: 'Cardio', description: '30–60s bursts.'),
  Exercise(name: 'Butt Kicks (Run-in-Place)', muscle: 'Cardio', description: 'Quick cadence; light landings.'),
  Exercise(name: 'Sled March (Light, Long)', muscle: 'Cardio', description: 'Long continuous push.'),
  Exercise(name: 'Bike Erg Time Trial (10 min)', muscle: 'Cardio', description: 'Max distance effort.'),
  Exercise(name: 'Row Erg Time Trial (2k)', muscle: 'Cardio', description: 'Even pacing; negative split.'),
  Exercise(name: 'Mixed Modality EMOM Cardio', muscle: 'Cardio', description: 'Rotate erg moves each minute.'),

  // ===== Chest (25 more) =====
  Exercise(name: 'Cable Flye (High Incline)', muscle: 'Chest', description: 'Benches at 30–45°; upper chest.'),
  Exercise(name: 'Cable Flye (Decline Bench)', muscle: 'Chest', description: 'Lower chest; slow eccentric.'),
  Exercise(name: 'One-Arm DB Floor Press', muscle: 'Chest', description: 'Anti-rotation; short ROM.'),
  Exercise(name: 'Paused Dumbbell Bench', muscle: 'Chest', description: '1–2s pause on chest.'),
  Exercise(name: 'Tempo Dumbbell Bench (4-0-1)', muscle: 'Chest', description: 'Long negative; drive up.'),
  Exercise(name: 'Spoto DB Press', muscle: 'Chest', description: 'Stop above chest; tension.'),
  Exercise(name: 'Feet-Up Bench Press', muscle: 'Chest', description: 'Flat back; chest isolation.'),
  Exercise(name: 'Close-Grip DB Press', muscle: 'Chest', description: 'Narrow DB path; tris support.'),
  Exercise(name: 'Machine Flye (Neutral Grip)', muscle: 'Chest', description: 'Neutral handles; squeeze.'),
  Exercise(name: 'Machine Flye (Partial Bottoms)', muscle: 'Chest', description: 'Short ROM stretch reps.'),
  Exercise(name: 'Band-Resisted Push-up', muscle: 'Chest', description: 'Band across back; lockout.'),
  Exercise(name: 'Ring Turned-Out Push-up', muscle: 'Chest', description: 'External rotate rings; adduct.'),
  Exercise(name: 'Archer Push-up on Rings', muscle: 'Chest', description: 'Side bias; stability.'),
  Exercise(name: 'Decline DB Flye', muscle: 'Chest', description: 'Lower chest stretch.'),
  Exercise(name: 'Incline Hex Press', muscle: 'Chest', description: 'DB squeeze on incline.'),
  Exercise(name: 'Smith Machine Close-Grip Press', muscle: 'Chest', description: 'Triceps and inner pecs.'),
  Exercise(name: 'Pin Press (Chest Height)', muscle: 'Chest', description: 'Dead-stop; power off chest.'),
  Exercise(name: 'Board Press (2-Board)', muscle: 'Chest', description: 'Reduced ROM; triceps bias.'),
  Exercise(name: 'Dumbbell Flye (Arcs to Hip)', muscle: 'Chest', description: 'Slight hipward path.'),
  Exercise(name: 'Cable Press (Split Stance)', muscle: 'Chest', description: 'Stable base; punch forward.'),
  Exercise(name: 'Push-up (Med Ball Hands)', muscle: 'Chest', description: 'Narrow unstable base.'),
  Exercise(name: 'Push-up (Ring Feet Elevated)', muscle: 'Chest', description: 'Increased difficulty.'),
  Exercise(name: 'Push-up (Tempo 5s Down)', muscle: 'Chest', description: 'Long eccentric; strict form.'),
  Exercise(name: 'Isometric Flye Hold', muscle: 'Chest', description: 'Hold mid-range; tension.'),
  Exercise(name: 'Cable Iron Cross', muscle: 'Chest', description: 'Arms out; adduction under load.'),

  // ===== Back (25 more) =====
  Exercise(name: 'Lat Pulldown (One-Arm Kneeling)', muscle: 'Back', description: 'Unilateral lat drive.'),
  Exercise(name: 'Half-Kneeling Single-Arm Pulldown', muscle: 'Back', description: 'Hip-to-rib line; lats.'),
  Exercise(name: 'Standing Pulldown (Rope)', muscle: 'Back', description: 'Arms straight; sweep.'),
  Exercise(name: 'Chest-Supported Meadows Row', muscle: 'Back', description: 'Landmine; chest on bench.'),
  Exercise(name: 'Landmine Single-Arm Row', muscle: 'Back', description: 'Hip hinge; pull to hip.'),
  Exercise(name: 'Cable High Row (Overhand)', muscle: 'Back', description: 'Elbows out; mid traps.'),
  Exercise(name: 'Cable Low Row (Neutral)', muscle: 'Back', description: 'Elbows tucked; lats.'),
  Exercise(name: 'Dual Handle Pullover', muscle: 'Back', description: 'Independent handles; arc.'),
  Exercise(name: 'Prone Row to External Rotation', muscle: 'Back', description: 'Scap set + ER.'),
  Exercise(name: 'Chest-Supported Rear Delt Row (Kettlebell)', muscle: 'Back', description: 'KB path; elbows wide.'),
  Exercise(name: 'Barbell Row (Paused on Floor)', muscle: 'Back', description: 'Dead-stop each rep.'),
  Exercise(name: 'Row from Blocks', muscle: 'Back', description: 'Bar elevated; hinge set.'),
  Exercise(name: 'Banded RDL', muscle: 'Back', description: 'Band tension; hinge pattern.'),
  Exercise(name: 'Reverse Hyper (Paused)', muscle: 'Back', description: 'Hold at top; glutes.'),
  Exercise(name: 'Back Extension (Banded)', muscle: 'Back', description: 'Band over neck; controlled.'),
  Exercise(name: 'Shrug (Trap Bar)', muscle: 'Back', description: 'Neutral grip; heavy holds.'),
  Exercise(name: 'Snatch-Grip Shrug', muscle: 'Back', description: 'Wide grip; upper traps.'),
  Exercise(name: 'Scapular Pull-Up (Weighted)', muscle: 'Back', description: 'Short ROM; depression.'),
  Exercise(name: 'Negative Chin-Up (10s)', muscle: 'Back', description: 'Very slow eccentric.'),
  Exercise(name: 'Mixed-Grip Rack Pull', muscle: 'Back', description: 'Above knee; lockout.'),
  Exercise(name: 'Deficit Good Morning', muscle: 'Back', description: 'Stand on plate; hinge deep.'),
  Exercise(name: 'Cambered Bar Good Morning', muscle: 'Back', description: 'Lower back comfort; hinge.'),
  Exercise(name: 'Face Pull (Seated)', muscle: 'Back', description: 'Strict torso; rope to brow.'),
  Exercise(name: 'Cable Reverse Flye (Incline)', muscle: 'Back', description: 'Chest on bench; rear delts.'),
  Exercise(name: 'Band Lat Prayer', muscle: 'Back', description: 'Tall kneel; sweep to thighs.'),
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

  // Naruto affiliation
  String? selectedVillage;
  String? selectedClan;

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

// =====================================================
// === PART 1: Naruto Data, Rank System & User Stats ===
// =====================================================

/// ----------------------
///  Naruto Villages / Clans
/// ----------------------
class NarutoData {
  static const List<String> villages = [
    'Hidden Leaf (Konoha)',
    'Hidden Sand (Suna)',
    'Hidden Mist (Kiri)',
    'Hidden Cloud (Kumo)',
    'Hidden Stone (Iwa)',
    'Hidden Rain (Ame)',
    'Hidden Grass (Kusa)',
    'Hidden Waterfall (Taki)',
    'Hidden Sound (Oto)',
    'Hidden Frost (Yuki)',
    'Hidden Moon (Getsu)',
    'Hidden Eddy (Uzu)',
    'Hidden Star (Hoshi)',
    'Hidden Sky (Sora)',
    'Hidden Snow (Yuki)',
  ];

  static const List<String> clans = [
    // Konoha clans
    'Uchiha',
    'Hyuga',
    'Nara',
    'Akimichi',
    'Yamanaka',
    'Aburame',
    'Inuzuka',
    'Sarutobi',
    'Senju',
    'Uzumaki',
    'Hatake',
    'Shimura',
    'Kurama',
    // Other villages
    'Kazekage',
    'Hozuki',
    'Kaguya',
    'Momochi',
    'Fuma',
    'Kamizuru',
    'Lee',
    // Organizations and groups
    'Anbu',
    'Root',
    'Akatsuki',
    'Seven Swordsmen',
    'Sound Four',
    'Kara',
    'Otsutsuki',
    'S-rank Rogue Nin',
  ];
}

/// ----------------------
///  Rank progression
/// ----------------------
class NarutoRank {
  final String name;
  final int requiredWorkouts;
  final String? icon; // optional emoji or asset

  const NarutoRank(this.name, this.requiredWorkouts, {this.icon});
}

const List<NarutoRank> kNarutoRanks = [
  NarutoRank('Academy Student', 0, icon: '🎓'),
  NarutoRank('Genin', 50, icon: '🥋'),
  NarutoRank('Chunin', 120, icon: '⚔️'),
  NarutoRank('Jounin', 220, icon: '🗡️'),
  NarutoRank('ANBU', 350, icon: '🐺'),
  NarutoRank('Sannin', 500, icon: '🐍'),
  NarutoRank('Kage', 650, icon: '👑'),
  NarutoRank('S-Rank (Legendary)', 800, icon: '🔥'),
];

/// ----------------------
///  Simple statistics DTO
/// ----------------------
class UserStats {
  final int workouts;
  final int durationSeconds;
  final double totalWeight;

  const UserStats({
    required this.workouts,
    required this.durationSeconds,
    required this.totalWeight,
  });

  Duration get duration => Duration(seconds: durationSeconds);
}

/// -----------------------------------------------------
///  Stats & Naruto logic — integrate with AppState below
/// -----------------------------------------------------

extension AppStateStats on AppState {
  // -------------------- Basic statistics --------------------

  int get workoutCount => sessions.length;

  double get totalWeightLifted {
    double total = 0;
    for (final s in sessions) {
      for (final set in s.sets) {
        if (set.weightKg != null) total += set.weightKg! * set.reps;
      }
    }
    return total;
  }

  int get totalDurationSeconds =>
      sessions.fold<int>(0, (acc, s) => acc + (s.durationSeconds ?? 0));

  UserStats get allTimeStats => UserStats(
    workouts: workoutCount,
    durationSeconds: totalDurationSeconds,
    totalWeight: totalWeightLifted,
  );

  UserStats get thisYearStats {
    final now = DateTime.now();
    final yearSessions =
    sessions.where((s) => s.startedAt.year == now.year).toList();
    final workouts = yearSessions.length;
    final dur =
    yearSessions.fold<int>(0, (acc, s) => acc + (s.durationSeconds ?? 0));
    double totalW = 0;
    for (final s in yearSessions) {
      for (final set in s.sets) {
        if (set.weightKg != null) totalW += set.weightKg! * set.reps;
      }
    }
    return UserStats(
      workouts: workouts,
      durationSeconds: dur,
      totalWeight: totalW,
    );
  }

  // -------------------- Rank logic --------------------

  NarutoRank get currentRank {
    final count = workoutCount;
    NarutoRank current = kNarutoRanks.first;
    for (final r in kNarutoRanks) {
      if (count >= r.requiredWorkouts) current = r;
    }
    return current;
  }

  NarutoRank? get nextRank {
    final count = workoutCount;
    for (final r in kNarutoRanks) {
      if (r.requiredWorkouts > count) return r;
    }
    return null;
  }

  int get workoutsUntilNextRank {
    final next = this.nextRank;
    if (next == null) return 0;
    return (next.requiredWorkouts - workoutCount).clamp(0, 9999);
  }

  // -------------------- Clan / Village save-load --------------------

  Future<void> saveNarutoAffiliation({
    String? village,
    String? clan,
  }) async {
    if (village != null) selectedVillage = village;
    if (clan != null) selectedClan = clan;
    await _prefs.setString(
      'naruto_affiliation',
      jsonEncode({
        'village': selectedVillage,
        'clan': selectedClan,
      }),
    );
    notifyListeners();
  }

  Future<void> loadNarutoAffiliation() async {
    final raw = _prefs.getString('naruto_affiliation');
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      selectedVillage = map['village'];
      selectedClan = map['clan'];
    } catch (_) {}
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
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Appearance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ButtonSegment(value: ThemeMode.light, label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
          ],
          selected: {state.themeMode},
          onSelectionChanged: (set) => state.setTheme(set.first),
        ),
        const SizedBox(height: 16),

        const Text('Primary Color',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final c in [
              AppTheme.crimson,
              Colors.blue,
              Colors.teal,
              Colors.amber,
              Colors.purple,
              Colors.green,
              Colors.orange
            ])
              GestureDetector(
                onTap: () => state.setPrimaryColor(c),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: state.primaryColor.value == c.value
                          ? Colors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: () => state.resetPrimaryColorToPrevious(),
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
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Height (cm)'),
          onChanged: (v) =>
              state.saveHeight(double.tryParse(v.replaceAll(',', '.'))),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _weightCtrl,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Weight (kg)'),
          onChanged: (v) =>
              state.saveWeight(double.tryParse(v.replaceAll(',', '.'))),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.update),
          label: const Text('Update current weight (logs progress)'),
          onPressed: () {
            final v =
            double.tryParse(_weightCtrl.text.replaceAll(',', '.'));
            if (v != null) {
              state.logWeightNow(v);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Weight updated and logged.')),
              );
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
        const SizedBox(height: 24),

        // ------------- Naruto affiliation section -------------
        const Text('Village & Clan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: state.selectedVillage,
          hint: const Text('Select Village'),
          items: NarutoData.villages
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (v) async {
            await state.saveNarutoAffiliation(village: v);
            setState(() {});
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: state.selectedClan,
          hint: const Text('Select Clan'),
          items: NarutoData.clans
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (v) async {
            await state.saveNarutoAffiliation(clan: v);
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        Card(
          color: cs.primary.withOpacity(.08),
          child: ListTile(
            leading:
            Text(state.currentRank.icon ?? '🎓', style: const TextStyle(fontSize: 24)),
            title: Text(state.currentRank.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: state.nextRank == null
                ? const Text('Max rank achieved')
                : Text(
                '${state.workoutsUntilNextRank} workouts to ${state.nextRank!.name}'),
          ),
        ),
        const SizedBox(height: 24),

        // ------------- Statistics navigation -------------
        FilledButton.icon(
          icon: const Icon(Icons.bar_chart),
          label: const Text('Open Statistics'),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StatisticsPage()));
          },
        ),
      ],
    );
  }
}

// ------------------------------------------------------
// Statistics Page
// ------------------------------------------------------
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  String _fmtDur(int secs) {
    final d = Duration(seconds: secs);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h h $m m' : '$m m';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final year = state.thisYearStats;
    final all = state.allTimeStats;
    final prList = state.prs.entries.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('This Year',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Card(
            child: Column(
              children: [
                ListTile(
                    title: const Text('Workouts'),
                    trailing: Text('${year.workouts}')),
                ListTile(
                    title: const Text('Duration'),
                    trailing: Text(_fmtDur(year.durationSeconds))),
                ListTile(
                    title: const Text('Weight Lifted'),
                    trailing:
                    Text('${year.totalWeight.toStringAsFixed(0)} kg')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('All Time',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Card(
            child: Column(
              children: [
                ListTile(
                    title: const Text('Workouts'),
                    trailing: Text('${all.workouts}')),
                ListTile(
                    title: const Text('Duration'),
                    trailing: Text(_fmtDur(all.durationSeconds))),
                ListTile(
                    title: const Text('Weight Lifted'),
                    trailing:
                    Text('${all.totalWeight.toStringAsFixed(0)} kg')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Best Lifts (PRs)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Card(
            child: Column(
              children: prList.isEmpty
                  ? [const ListTile(title: Text('No PR data yet'))]
                  : prList.map((e) {
                final pr = e.value;
                return ListTile(
                  title: Text(e.key),
                  subtitle: Text(
                      'Max Weight: ${pr.maxWeightKg?.toStringAsFixed(1) ?? '—'} kg  •  Max Reps: ${pr.maxReps}'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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
  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

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

    // --- compute summary ---
    int totalSets = 0;
    double totalWeight = 0;
    for (final e in active.entries) {
      totalSets += e.logs.length;
      for (final l in e.logs) {
        if (l.weightKg != null) totalWeight += l.weightKg! * l.reps;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: state,
          builder: (_, __) =>
              Text('Workout • ${_fmt(state.activeElapsed)}'),
        ),
        actions: [
          IconButton(
            tooltip: 'Add exercise',
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExerciseSheet(context),
          ),
          IconButton(
            tooltip: 'End & Save',
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: () async {
              final proposed = state.proposeUpdatedPlanFromActive();
              final session = await state.endActiveWorkoutAndSave();
              if (!mounted) return;

              // ask to update defaults if user changed sets/exercises
              if (proposed != null) {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Apply workout changes?'),
                    content: const Text(
                        'You added/edited exercises or sets.\n'
                            'Do you want to update your saved plan defaults?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('No')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Yes, update')),
                    ],
                  ),
                );
                if (ok == true) {
                  await state.updatePlanById(proposed.id, proposed);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan updated successfully.')),
                  );
                }
              }

              if (session != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => WorkoutSummaryPage(session: session)),
                );
              }
            },
          ),
        ],
      ),

      // --- Body ---
      body: AnimatedBuilder(
        animation: state,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- summary card ---
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.07),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _summaryStat('⏱ Duration', _fmt(state.activeElapsed)),
                    _summaryStat('🏋️ Volume',
                        '${totalWeight.toStringAsFixed(0)} kg'),
                    _summaryStat('🔢 Sets', '$totalSets'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- exercise cards ---
            ...List.generate(active.entries.length, (i) {
              final entry = active.entries[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ExerciseCard(entryIndex: i, entry: entry),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _summaryStat(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value,
            style:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
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
    final all = [...builtInExercises(), ...state.customExercises];
    try {
      return all.firstWhere((e) => e.name == name);
    } catch (_) {
      return Exercise(name: name, muscle: 'Other', description: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final ex = _findByName(context);
    final pr = state.prs[name];

    // collect PR progress points from all sessions (sorted by date)
    final data = <(DateTime, double)>[];
    for (final s in state.sessions) {
      double best = 0;
      for (final set in s.sets.where((x) => x.exercise == name)) {
        if (set.weightKg != null) best = math.max(best, set.weightKg!);
      }
      if (best > 0) data.add((s.startedAt, best));
    }
    data.sort((a, b) => a.$1.compareTo(b.$1));

    return Scaffold(
      appBar: AppBar(title: Text(ex?.name ?? name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Muscle group'),
              subtitle: Text(ex?.muscle ?? '—'),
            ),
            if (pr != null)
              ListTile(
                leading: const Icon(Icons.stars_outlined),
                title: const Text('Your PRs'),
                subtitle: Text(
                    'Max Weight: ${pr.maxWeightKg?.toStringAsFixed(1) ?? '—'} kg  •  Max Reps: ${pr.maxReps > 0 ? pr.maxReps : '—'}'),
              ),
            const SizedBox(height: 8),
            const Text('Description',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(ex?.description?.isNotEmpty == true
                ? ex!.description!
                : 'No description available.'),

            const SizedBox(height: 20),
            const Text('PR Progress (All Time)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: data.length < 2
                      ? const Center(child: Text('Not enough PR data yet.'))
                      : CustomPaint(
                    painter: _PRChartPainter(data),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PRChartPainter extends CustomPainter {
  final List<(DateTime, double)> data;
  _PRChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final pad = 10.0;
    final left = pad, right = size.width - pad, top = pad, bottom = size.height - pad;
    final paintLine = Paint()
      ..color = Colors.deepPurpleAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final paintAxis = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    // axes
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paintAxis);
    canvas.drawLine(Offset(left, top), Offset(left, bottom), paintAxis);

    final minT = data.first.$1.millisecondsSinceEpoch.toDouble();
    final maxT = data.last.$1.millisecondsSinceEpoch.toDouble();
    final minY = data.map((e) => e.$2).reduce(math.min);
    final maxY = data.map((e) => e.$2).reduce(math.max);
    final spanT = (maxT - minT).clamp(1, double.infinity);
    final spanY = (maxY - minY).abs() < 1e-6 ? 1.0 : (maxY - minY);

    double xFor(DateTime t) =>
        left + (right - left) * ((t.millisecondsSinceEpoch - minT) / spanT);
    double yFor(double v) =>
        bottom - (bottom - top) * ((v - minY) / spanY);

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = xFor(data[i].$1);
      final y = yFor(data[i].$2);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    canvas.drawPath(path, paintLine);

    // dots
    final dot = Paint()..color = Colors.deepPurpleAccent;
    for (final p in data) {
      canvas.drawCircle(Offset(xFor(p.$1), yFor(p.$2)), 3, dot);
    }

    // axis labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final minLabel = TextSpan(
        text: '${minY.toStringAsFixed(0)} kg',
        style: const TextStyle(fontSize: 10, color: Colors.grey));
    final maxLabel = TextSpan(
        text: '${maxY.toStringAsFixed(0)} kg',
        style: const TextStyle(fontSize: 10, color: Colors.grey));
    tp.text = minLabel;
    tp.layout();
    tp.paint(canvas, Offset(left + 2, bottom - tp.height));
    tp.text = maxLabel;
    tp.layout();
    tp.paint(canvas, Offset(left + 2, top));

    final dateLabel = TextPainter(
        text: TextSpan(
            text: 'Date',
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
        textDirection: TextDirection.ltr)
      ..layout();
    dateLabel.paint(canvas, Offset(right - dateLabel.width, bottom - 14));
  }

  @override
  bool shouldRepaint(covariant _PRChartPainter oldDelegate) =>
      oldDelegate.data != data;
}

/// ---------- Progress (Weight graph + History) ----------
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

enum _Range { week, month, year, all }
enum _GraphType { weight, duration, volume, workouts }
enum _ProgressTab { overview, exercises, measures, photos }

class _ProgressScreenState extends State<ProgressScreen> {
  _GraphType _graph = _GraphType.weight;
  _ProgressTab _tab = _ProgressTab.overview;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;

    // ------------- Top navigation bar -------------
    Widget navBar() {
      return SegmentedButton<_ProgressTab>(
        segments: const [
          ButtonSegment(value: _ProgressTab.overview, label: Text('Overview')),
          ButtonSegment(value: _ProgressTab.exercises, label: Text('Exercises')),
          ButtonSegment(value: _ProgressTab.measures, label: Text('Measures')),
          ButtonSegment(value: _ProgressTab.photos, label: Text('Photos')),
        ],
        selected: {_tab},
        onSelectionChanged: (s) => setState(() => _tab = s.first),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        navBar(),
        const SizedBox(height: 16),
        if (_tab == _ProgressTab.overview) _overviewTab(state, cs),
        if (_tab == _ProgressTab.exercises) _exercisesTab(state),
        if (_tab == _ProgressTab.measures) _measuresTab(state, cs),
        if (_tab == _ProgressTab.photos) _photosTab(state, cs),
      ],
    );
  }

  // --------------------------------------------------
  // Overview tab
  // --------------------------------------------------
  Widget _overviewTab(AppState state, ColorScheme cs) {
    final weightPts = state.weightHistory;
    final yearStats = state.thisYearStats;
    final allStats = state.allTimeStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Progress Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // ---------------- Graph + switcher ----------------
        SizedBox(
          height: 240,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildGraph(state),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Graph switch buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _graphBtn(Icons.access_time, 'Duration', _GraphType.duration),
            _graphBtn(Icons.fitness_center, 'Volume', _GraphType.volume),
            _graphBtn(Icons.event_note, 'Workouts', _GraphType.workouts),
            _graphBtn(Icons.monitor_weight, 'Weight', _GraphType.weight),
          ],
        ),
        const SizedBox(height: 20),

        // ---------------- Yearly / All time stats ----------------
        const Text('This Year', style: TextStyle(fontWeight: FontWeight.bold)),
        Card(
          child: ListTile(
            title: const Text('Workouts'),
            trailing: Text('${yearStats.workouts}'),
            subtitle: Text(
                'Duration: ${_fmtDur(yearStats.durationSeconds)} • Weight lifted: ${yearStats.totalWeight.toStringAsFixed(0)} kg'),
          ),
        ),
        const SizedBox(height: 6),
        const Text('All Time', style: TextStyle(fontWeight: FontWeight.bold)),
        Card(
          child: ListTile(
            title: const Text('Workouts'),
            trailing: Text('${allStats.workouts}'),
            subtitle: Text(
                'Duration: ${_fmtDur(allStats.durationSeconds)} • Weight lifted: ${allStats.totalWeight.toStringAsFixed(0)} kg'),
          ),
        ),
        const SizedBox(height: 12),

        // ---------------- Rank display ----------------
        _rankSection(state, cs),

        const SizedBox(height: 24),
        // ---------------- Radar chart + weekly muscle list ----------------
        const Text('Muscle Focus This Month',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        _muscleRadarChart(state),
        const SizedBox(height: 16),
        const Text('Muscle Groups Hit This Week',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        _muscleList(state),
      ],
    );
  }

  // --------------------------------------------------
  // Graph painter + buttons
  // --------------------------------------------------
  Widget _graphBtn(IconData icon, String label, _GraphType type) {
    final selected = _graph == type;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(100, 36),
        backgroundColor:
        selected ? null : Colors.grey.withOpacity(0.2),
      ),
      onPressed: () => setState(() => _graph = type),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _buildGraph(AppState state) {
    final pts = state.weightHistory;
    if (pts.length < 2) {
      return const Center(child: Text('Not enough data yet.'));
    }

    // pick numeric Y values based on graph type
    List<double> yVals;
    switch (_graph) {
      case _GraphType.weight:
        yVals = pts.map((e) => e.kg).toList();
        break;
      case _GraphType.duration:
        yVals = state.sessions.map((s) => (s.durationSeconds ?? 0) / 60).toList();
        break;
      case _GraphType.volume:
        yVals = state.sessions.map((s) {
          double total = 0;
          for (final set in s.sets) {
            if (set.weightKg != null) total += set.weightKg! * set.reps;
          }
          return total;
        }).toList();
        break;
      case _GraphType.workouts:
        yVals = List.generate(state.sessions.length, (i) => i + 1.0);
        break;
    }

    return CustomPaint(
      painter: _SimpleLinePainter(yVals, label: _graph.name),
      child: Container(),
    );
  }

  // --------------------------------------------------
  // Rank section
  // --------------------------------------------------
  Widget _rankSection(AppState state, ColorScheme cs) {
    final rank = state.currentRank;
    final next = state.nextRank;
    final left = state.workoutsUntilNextRank;

    return Card(
      color: cs.primary.withOpacity(.08),
      child: ListTile(
        leading: Text(rank.icon ?? '🎓', style: const TextStyle(fontSize: 24)),
        title: Text('${rank.name}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: next == null
            ? const Text('You reached the top rank!')
            : Text('Next: ${next.name}  •  $left workouts left'),
      ),
    );
  }

  // --------------------------------------------------
  // Radar chart and weekly list
  // --------------------------------------------------
  Widget _muscleRadarChart(AppState state) {
    // All muscles (always show full radar)
    const allMuscles = [
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

    final now = DateTime.now();
    final monthSessions = state.sessions
        .where((s) =>
    s.startedAt.year == now.year && s.startedAt.month == now.month)
        .toList();

    final counter = <String, int>{for (final m in allMuscles) m: 0};

    for (final s in monthSessions) {
      for (final set in s.sets) {
        final ex = [...builtInExercises(), ...state.customExercises]
            .firstWhere((e) => e.name == set.exercise,
            orElse: () => Exercise(name: set.exercise, muscle: 'Other'));
        counter[ex.muscle] = (counter[ex.muscle] ?? 0) + 1;
      }
    }

    if (counter.values.every((v) => v == 0)) {
      counter['Chest'] = 1; // avoid empty radar
    }

    // Force a square shape for the radar chart
    final width = MediaQuery.of(context).size.width - 48; // some padding

    return Center(
      child: SizedBox(
        width: width,
        height: width, // make it square
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: CustomPaint(
              size: Size.square(width - 24),
              painter: _RadarPainter(counter),
            ),
          ),
        ),
      ),
    );
  }

  Widget _muscleList(AppState state) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekSessions =
    state.sessions.where((s) => s.startedAt.isAfter(weekAgo)).toList();
    final groups = <String>{};
    for (final s in weekSessions) {
      for (final set in s.sets) {
        final ex = [...builtInExercises(), ...state.customExercises]
            .firstWhere((e) => e.name == set.exercise,
            orElse: () => Exercise(name: set.exercise, muscle: 'Other'));
        groups.add(ex.muscle);
      }
    }
    if (groups.isEmpty) return const Text('No workouts this week.');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: groups.map((m) => Chip(label: Text(m))).toList(),
    );
  }

  // --------------------------------------------------
  // Exercises tab
  // --------------------------------------------------
  Widget _exercisesTab(AppState state) {
    final now = DateTime.now();
    final monthSessions =
    state.sessions.where((s) => s.startedAt.month == now.month).toList();
    final recent = <String, double>{};

    for (final s in monthSessions) {
      for (final set in s.sets) {
        if (set.weightKg != null) {
          final w = set.weightKg!;
          recent[set.exercise] = math.max(recent[set.exercise] ?? 0, w);
        }
      }
    }

    if (recent.isEmpty) {
      return const Center(child: Text('No exercises logged this month.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recent.entries.map((e) {
        return Card(
          child: ListTile(
            title: Text(e.key),
            subtitle: Text('PR: ${e.value.toStringAsFixed(1)} kg'),
          ),
        );
      }).toList(),
    );
  }

  // --------------------------------------------------
  // Measures tab
  // --------------------------------------------------
  Widget _measuresTab(AppState state, ColorScheme cs) {
    final parts = [
      'Left Arm',
      'Right Arm',
      'Chest',
      'Waist',
      'Hips',
      'Left Thigh',
      'Right Thigh',
      'Left Calf',
      'Right Calf',
      'Neck',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Body Measurements',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: parts.map((p) {
            return OutlinedButton(
              onPressed: () async {
                final ctrl = TextEditingController();
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Enter $p measurement (cm)'),
                    content: TextField(
                      controller: ctrl,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'e.g. 34.5'),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Save')),
                    ],
                  ),
                );
                if (ok == true && ctrl.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$p saved: ${ctrl.text} cm')),
                  );
                }
              },
              child: Text(p),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // Photos tab
  // --------------------------------------------------
  Widget _photosTab(AppState state, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Progress Photos',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () async {
            final wCtrl = TextEditingController();
            final hCtrl = TextEditingController();
            String? mode = 'Maintaining';
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Upload Progress Photo'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select image and enter details'),
                    const SizedBox(height: 8),
                    TextField(
                        controller: wCtrl,
                        decoration:
                        const InputDecoration(labelText: 'Weight (kg)')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: hCtrl,
                        decoration:
                        const InputDecoration(labelText: 'Height (cm)')),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: mode,
                      onChanged: (v) => mode = v,
                      items: const [
                        DropdownMenuItem(
                            value: 'Bulking', child: Text('Bulking')),
                        DropdownMenuItem(
                            value: 'Cutting', child: Text('Cutting')),
                        DropdownMenuItem(
                            value: 'Maintaining', child: Text('Maintaining')),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Save')),
                ],
              ),
            );
            if (ok == true) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Photo saved (mock, not yet stored).')));
            }
          },
          icon: const Icon(Icons.photo_camera),
          label: const Text('Upload Progress Photo'),
        ),
        const SizedBox(height: 12),
        const Text('Uploaded photos will appear here (future feature).'),
      ],
    );
  }

  // --------------------------------------------------
  // Utilities
  // --------------------------------------------------
  String _fmtDur(int secs) {
    final d = Duration(seconds: secs);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h h $m m' : '$m m';
  }
}

// ------------------------------------------------------
// Simple graph painter
// ------------------------------------------------------
class _SimpleLinePainter extends CustomPainter {
  final List<double> values;
  final String label;
  _SimpleLinePainter(this.values, {required this.label});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine =
    Paint()..color = Colors.blueAccent..strokeWidth = 2..style = PaintingStyle.stroke;
    final paintAxis =
    Paint()..color = Colors.grey..strokeWidth = 1;
    final pad = 8.0;
    final left = pad, right = size.width - pad, top = pad, bottom = size.height - pad;

    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paintAxis);
    canvas.drawLine(Offset(left, top), Offset(left, bottom), paintAxis);

    final minY = values.reduce(math.min);
    final maxY = values.reduce(math.max);
    final spanY = (maxY - minY).abs() < 1e-6 ? 1.0 : (maxY - minY);

    double xFor(int i) => left + (right - left) * (i / (values.length - 1));
    double yFor(double v) => bottom - (bottom - top) * ((v - minY) / spanY);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = xFor(i);
      final y = yFor(values[i]);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paintLine);

    final text = TextPainter(
      text: TextSpan(
          text: label.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: Colors.grey)),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, Offset(right - text.width, top));
  }

  @override
  bool shouldRepaint(covariant _SimpleLinePainter oldDelegate) =>
      oldDelegate.values != values;
}

// ------------------------------------------------------
// Radar chart painter
// ------------------------------------------------------
class _RadarPainter extends CustomPainter {
  final Map<String, int> data;
  _RadarPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2.5;
    final count = data.length;
    if (count == 0) return;

    final paintLine =
    Paint()..color = Colors.blueAccent..strokeWidth = 2..style = PaintingStyle.stroke;
    final paintFill =
    Paint()..color = Colors.blueAccent.withOpacity(0.3)..style = PaintingStyle.fill;
    final keys = data.keys.toList();
    final maxVal = data.values.reduce(math.max).toDouble();

    final path = Path();
    for (int i = 0; i < count; i++) {
      final angle = (math.pi * 2 / count) * i - math.pi / 2;
      final value = data[keys[i]]!.toDouble();
      final r = radius * (value / maxVal);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintLine);

    // labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < count; i++) {      final angle = (math.pi * 2 / count) * i - math.pi / 2;
    final label = keys[i];
    final tp = TextPainter(
      text: TextSpan(
          text: label,
          style: const TextStyle(fontSize: 10, color: Colors.grey)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 80);

    final lx = center.dx + (radius + 16) * math.cos(angle) - tp.width / 2;
    final ly = center.dy + (radius + 16) * math.sin(angle) - tp.height / 2;
    tp.paint(canvas, Offset(lx, ly));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.data != data;
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

