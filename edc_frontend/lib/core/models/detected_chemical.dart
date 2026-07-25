import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/risk_level.dart';

part 'detected_chemical.freezed.dart';
part 'detected_chemical.g.dart';

/// A chemical the backend detected in a scanned product. The client renders it
/// as-is and never computes its `risk` (docs/flutter_app_architecture.md §3).
@freezed
class DetectedChemical with _$DetectedChemical {
  const factory DetectedChemical({
    required String id,
    required String name,
    required RiskLevel risk,
  }) = _DetectedChemical;

  factory DetectedChemical.fromJson(Map<String, dynamic> json) =>
      _$DetectedChemicalFromJson(json);
}
