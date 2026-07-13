import 'models.dart';

/// Matches ingredient text against a list of known [EdcEntry] records.
class EdcMatcher {
  const EdcMatcher(this.entries);

  final List<EdcEntry> entries;

  /// Returns all [EdcEntry] items whose name or aliases appear in [text].
  List<EdcEntry> match(String text) {
    final lower = text.toLowerCase();
    return entries
        .where((e) =>
            lower.contains(e.name.toLowerCase()) ||
            e.aliases.any((a) => lower.contains(a.toLowerCase())))
        .toList();
  }
}
