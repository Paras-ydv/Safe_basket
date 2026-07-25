/// Networking configuration. Override at build time with
/// `--dart-define=API_BASE_URL=...` and `--dart-define=USE_FAKES=true`.
abstract final class ApiConfig {
  /// Backend base URL. Placeholder until the real host is provisioned.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.edcapp.example/v1',
  );

  /// When true, providers bind the in-memory fake repositories instead of the
  /// Dio-backed ones. Defaults to false (real repos) per the wiring decision;
  /// flip with `--dart-define=USE_FAKES=true` for offline/dev work.
  static const useFakes = bool.fromEnvironment('USE_FAKES', defaultValue: false);
}
