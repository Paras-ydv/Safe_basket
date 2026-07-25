import 'package:flutter/material.dart';

import '../enums/risk_level.dart';

/// Risk-level color tokens exposed as a [ThemeExtension] so widgets never
/// hardcode risk colors — they resolve them via `Theme.of(context)`.
///
/// Dark-interface palette (Color Mapping Protocol):
/// low → teal `#2EC4B6` · moderate → amber `#FF9F1C` · high → coral `#FF4D6D`.
/// The design spec defines only three levels; `veryHigh` (part of the backend
/// `RiskLevel` contract, §3) is assigned a more-severe scarlet than `high`.
@immutable
class RiskColors extends ThemeExtension<RiskColors> {
  const RiskColors({
    required this.low,
    required this.moderate,
    required this.high,
    required this.veryHigh,
  });

  final Color low;
  final Color moderate;
  final Color high;
  final Color veryHigh;

  static const dark = RiskColors(
    low: Color(0xFF2EC4B6), // teal — low concern
    moderate: Color(0xFFFF9F1C), // amber — moderate concern
    high: Color(0xFFFF4D6D), // coral — high concern
    veryHigh: Color(0xFFFF1744), // scarlet — very high (spec had no token)
  );

  /// Resolve the color for a given [RiskLevel].
  Color colorFor(RiskLevel level) => switch (level) {
    RiskLevel.low => low,
    RiskLevel.moderate => moderate,
    RiskLevel.high => high,
    RiskLevel.veryHigh => veryHigh,
  };

  @override
  RiskColors copyWith({
    Color? low,
    Color? moderate,
    Color? high,
    Color? veryHigh,
  }) {
    return RiskColors(
      low: low ?? this.low,
      moderate: moderate ?? this.moderate,
      high: high ?? this.high,
      veryHigh: veryHigh ?? this.veryHigh,
    );
  }

  @override
  RiskColors lerp(RiskColors? other, double t) {
    if (other == null) return this;
    return RiskColors(
      low: Color.lerp(low, other.low, t)!,
      moderate: Color.lerp(moderate, other.moderate, t)!,
      high: Color.lerp(high, other.high, t)!,
      veryHigh: Color.lerp(veryHigh, other.veryHigh, t)!,
    );
  }
}

/// Convenience accessor for the risk color tokens on the current theme.
extension RiskColorsX on BuildContext {
  RiskColors get riskColors => Theme.of(this).extension<RiskColors>()!;
}
