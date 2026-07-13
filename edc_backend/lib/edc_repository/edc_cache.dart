import 'package:edc_matcher/edc_matcher.dart';

/// Holds the in-memory snapshot of [edc_entries] used by [EdcMatcher].
///
/// A single instance is shared across the scan and admin middleware trees.
/// Admin write routes call [refresh] after any mutation so the matcher
/// always sees current data.
class EdcCache {
  EdcCache(this._loader);

  /// Called to reload entries from the database.
  final Future<List<EdcEntry>> Function() _loader;

  List<EdcEntry> _entries = [];

  List<EdcEntry> get entries => _entries;

  /// Loads entries for the first time. Call once at server startup.
  Future<void> prime() async => _entries = await _loader();

  /// Reloads entries from the database. Call after any admin write.
  Future<void> refresh() async => _entries = await _loader();
}
