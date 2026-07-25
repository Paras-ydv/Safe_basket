import 'package:json_annotation/json_annotation.dart';

/// The four risk levels are the single shared vocabulary between the app and
/// the backend (see docs/flutter_app_architecture.md §3). The backend decides
/// the level; the client only renders and colors it — it never computes risk.
///
/// Lives in `core` (not a feature) because scan, chemical, history and home all
/// speak this vocabulary. Color mapping is in `core/theme/risk_colors.dart`.
/// JSON wire values match the `edc_contracts` package (snake_case).
enum RiskLevel {
  @JsonValue('low')
  low,
  @JsonValue('moderate')
  moderate,
  @JsonValue('high')
  high,
  @JsonValue('very_high')
  veryHigh;

  /// Human-readable label from the source diagram's legend.
  String get label => switch (this) {
    RiskLevel.low => 'Low',
    RiskLevel.moderate => 'Moderate',
    RiskLevel.high => 'High',
    RiskLevel.veryHigh => 'Very High',
  };
}
