import 'package:edc_matcher/edc_matcher.dart';
import 'package:edc_backend/middleware/structured_logger.dart';

class MatchResult {
  const MatchResult({
    required this.cleanedText,
    required this.matches,
    required this.worstSeverity,
  });

  final String cleanedText;
  final List<EdcEntry> matches;
  final String? worstSeverity;

  Map<String, Object?> toJson() => {
        'cleaned_text': cleanedText,
        'worst_severity': worstSeverity,
        'matches': matches
            .map((e) => {
                  'id': e.id,
                  'name': e.name,
                  'severity': e.severity,
                  'evidence_tier': e.evidenceTier,
                  'draft_app_output_message': e.draftAppOutputMessage,
                })
            .toList(),
      };
}

/// Runs [EdcMatcher] + [RiskClassifier] against [text], emits a structured
/// log event capturing exact-vs-alias match type for every hit.
///
/// [requestId] is included in the log line for correlation with access logs.
MatchResult matchAndClassify(
  String text,
  List<EdcEntry> entries, {
  String requestId = '-',
}) {
  final lower = text.toLowerCase();
  final matched = <EdcEntry>[];
  final details = <MatchDetail>[];

  for (final entry in entries) {
    // Check canonical name first — if it fires, record as exactName.
    if (lower.contains(entry.name.toLowerCase())) {
      matched.add(entry);
      details.add(MatchDetail(
        id: entry.id,
        name: entry.name,
        matchType: MatchType.exactName,
        matchedToken: entry.name,
        severity: entry.severity,
        evidenceTier: entry.evidenceTier,
      ));
      continue;
    }

    // Check aliases — record the first alias that fires.
    final firedAlias = entry.aliases
        .cast<String?>()
        .firstWhere(
          (a) => lower.contains(a!.toLowerCase()),
          orElse: () => null,
        );

    if (firedAlias != null) {
      matched.add(entry);
      details.add(MatchDetail(
        id: entry.id,
        name: entry.name,
        matchType: MatchType.alias,
        matchedToken: firedAlias,
        severity: entry.severity,
        evidenceTier: entry.evidenceTier,
      ));
    }
  }

  final result = RiskClassifier().classify(matched);

  logMatchEvent(
    requestId: requestId,
    cleanedText: text,
    details: details,
    worstSeverity: result.worstSeverity,
    totalEntries: entries.length,
  );

  return MatchResult(
    cleanedText: text,
    matches: result.matched,
    worstSeverity: result.worstSeverity,
  );
}
