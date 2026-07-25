import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// Exposes the app's [SharedPreferences] instance. Overridden in `main()` after
/// `SharedPreferences.getInstance()` so the rest of the app can read it
/// synchronously.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) =>
    throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in main()',
    );
