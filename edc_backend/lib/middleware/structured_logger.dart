import 'dart:convert';
import 'dart:io';

/// Writes a single structured JSON log line to stdout.
/// Each line is a self-contained JSON object — compatible with
/// Cloud Logging, Datadog, and any log aggregator that ingests JSON.
void logJson(Map<String, Object?> fields) {
  stdout.writeln(jsonEncode({
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    ...fields,
  }));
}

/// Match type recorded per [EdcEntry] hit.
enum MatchType {
  /// The entry's canonical name appeared verbatim in the text.
  exactName,

  /// One of the entry's aliases appeared in the text.
  alias,
}

/// Structured log event emitted after every matchAndClassify call.
///
/// Captures:
///   - how many tokens were in the cleaned OCR text
///   - how many entries matched, and whether each was name or alias
///   - worst_severity — the early-warning signal for alias coverage
///   - matched_ratio — matches / total_entries, useful for drift detection
void logMatchEvent({
  required String requestId,
  required String cleanedText,
  required List<MatchDetail> details,
  required String? worstSeverity,
  required int totalEntries,
}) {
  final tokenCount = cleanedText.split(',').length;
  logJson({
    'event': 'match_result',
    'request_id': requestId,
    'token_count': tokenCount,
    'match_count': details.length,
    'worst_severity': worstSeverity,
    // matched_ratio: fraction of the EDC database that fired.
    // A sudden spike here means alias coverage is too broad.
    // A persistent zero means OCR output isn't matching known aliases.
    'matched_ratio': totalEntries == 0
        ? 0.0
        : (details.length / totalEntries * 100).toStringAsFixed(1),
    'matches': details
        .map((d) => {
              'id': d.id,
              'name': d.name,
              'match_type': d.matchType.name,
              'matched_token': d.matchedToken,
              'severity': d.severity,
              'evidence_tier': d.evidenceTier,
            })
        .toList(),
  });
}

class MatchDetail {
  const MatchDetail({
    required this.id,
    required this.name,
    required this.matchType,
    required this.matchedToken,
    required this.severity,
    this.evidenceTier,
  });

  final String id;
  final String name;
  final MatchType matchType;

  /// The specific token from the OCR text that triggered this match.
  final String matchedToken;

  final String severity;
  final String? evidenceTier;
}
