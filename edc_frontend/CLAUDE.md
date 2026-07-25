# My Flutter App

## Commands
- `flutter pub get` — install dependencies
- `dart run build_runner build --delete-conflicting-outputs` — generate code
- `flutter analyze` — run linter
- `flutter test` — run tests
- `flutter run` — start dev build

## Architecture
Feature-first folder structure. Each feature lives in lib/features/<name>/.
State management: Riverpod with @riverpod code generation (AsyncNotifier pattern).
HTTP: Dio with interceptors in lib/core/network/.
Navigation: GoRouter with named routes defined in lib/core/router/.
Models: Freezed + JsonSerializable. Run build_runner after any model change.

## Conventions
- All monetary amounts in the smallest unit (e.g. kobo for NGN), stored as int — never use doubles for money
- Use ref.invalidate() not ref.refresh()
- No business logic in widgets — all logic goes in notifiers or repositories
- Widget files contain only one public widget per file
- Barrel exports via feature.dart in each feature root
- Prefix private widgets with an underscore

## What NOT to do
- Do not add new packages without asking first
- Do not modify *.g.dart or *.freezed.dart files directly — regenerate with build_runner
- Do not put API calls directly in notifiers — always go through the repository layer