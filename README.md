# Vainakhfit

A minimal workout tracker focused on speed, simplicity, and offline-first use.

> **Platforms:** Android (APK), iOS (IPA)

---

## ✨ Features

- Fast logging for workouts and sets
- Simple, distraction-free UI
- Works offline; data stays on device
- Lightweight build (no bloat)

---

## 📦 Get the App

Grab the latest builds from **Releases**:

- **Android:** `arm64-v8a`, `armeabi-v7a`, `x86_64` APKs  
- **iOS:** `.ipa` (for sideloading)

👉 Head to the **[Releases](../../releases)** page and download the latest version for your device.

---

## 🛠️ Build from Source

Requirements:
- [Flutter](https://flutter.dev) (stable channel)
- Dart SDK (bundled with Flutter)
- Android Studio/Xcode for platform toolchains

```bash
# 1) Get dependencies
flutter pub get

# 2) Run in debug
flutter run

# 3) Build release (Android)
flutter build apk --release

# Optional: split-per-abi (smaller APKs)
flutter build apk --release --split-per-abi

# 4) Build release (iOS - on macOS)
flutter build ipa --release
