// Barrel export for the `history` feature. Cross-feature access goes through
// this file only (docs/flutter_app_architecture.md §4.2). Owns the scan-history
// repository that the home teaser also depends on.
export 'application/history_providers.dart';
export 'data/fake_history_repository.dart';
export 'data/history_repository.dart';
export 'domain/trends.dart';
export 'presentation/history_screen.dart';
