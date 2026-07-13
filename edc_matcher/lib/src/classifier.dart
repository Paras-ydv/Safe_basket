import 'models.dart';

class ClassificationResult {
  const ClassificationResult({
    required this.worstSeverity,
    required this.matched,
  });

  final String? worstSeverity;
  final List<EdcEntry> matched;
}

// Ordered worst → least severe. Nulls / unknowns sort last.
const _severityRank = [
  'High',
  'Moderate-High',
  'Acute',
  'Moderate',
  'Low-Moderate',
  'Dose-dependent',
  'Low',
  'Emerging',
  'Non-EDC',
];

/// Classifies overall risk from a list of matched [EdcEntry] items.
class RiskClassifier {
  const RiskClassifier();

  ClassificationResult classify(List<EdcEntry> matched) {
    if (matched.isEmpty) {
      return const ClassificationResult(worstSeverity: null, matched: []);
    }
    final worst = matched
        .map((e) => e.severity)
        .reduce((a, b) => _rank(a) <= _rank(b) ? a : b);
    return ClassificationResult(worstSeverity: worst, matched: matched);
  }

  int _rank(String s) {
    final i = _severityRank.indexOf(s);
    return i == -1 ? _severityRank.length : i;
  }
}
