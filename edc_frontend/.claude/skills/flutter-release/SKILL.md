---
name: flutter-release
description: |
  Use this skill when building a release APK or preparing the app for deployment.
  Triggers on: "build release", "generate apk", "prepare release", "release build".
allowed-tools: Bash Read
---

# Flutter release checklist

Run these steps in order. Do not skip any step.

1. Run `flutter pub get`
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Run `flutter analyze` — fix every error before proceeding. Do not continue with warnings treated as errors.
4. Run `flutter test` — if any test fails, fix it before continuing
5. Run `flutter build apk --release`
6. Confirm build output at `build/app/outputs/flutter-apk/app-release.apk`
7. Create a git commit: `chore: release build vX.X.X`

If any step fails, stop and report the error clearly. Do not skip ahead.