/// The client's clean 4-level risk vocabulary. Normalized from the backend's
/// free-form `severity` text so the client stays a thin renderer with one
/// source of truth (see the reconciliation plan).
enum RiskLevel {
  low,
  moderate,
  high,
  veryHigh;

  /// Snake_case wire value used in JSON.
  String get wire => switch (this) {
    RiskLevel.low => 'low',
    RiskLevel.moderate => 'moderate',
    RiskLevel.high => 'high',
    RiskLevel.veryHigh => 'very_high',
  };

  static RiskLevel fromWire(String? value) => switch (value) {
    'low' => RiskLevel.low,
    'moderate' => RiskLevel.moderate,
    'high' => RiskLevel.high,
    'very_high' => RiskLevel.veryHigh,
    _ => RiskLevel.moderate,
  };
}

/// Maps the backend's free-form `severity` labels to a [RiskLevel].
/// Tunable — this is the single normalization point. Unknown/blank → moderate
/// (conservative default rather than understating).
const Map<String, RiskLevel> _severityToRisk = {
  'Non-EDC': RiskLevel.low,
  'Emerging': RiskLevel.low,
  'Low': RiskLevel.low,
  'Low-Moderate': RiskLevel.moderate,
  'Dose-dependent': RiskLevel.moderate,
  'Moderate': RiskLevel.moderate,
  'Moderate-High': RiskLevel.high,
  'High': RiskLevel.high,
  'Acute': RiskLevel.veryHigh,
};

RiskLevel normalizeSeverity(String? severity) =>
    severity == null ? RiskLevel.moderate : _severityToRisk[severity] ?? RiskLevel.moderate;
