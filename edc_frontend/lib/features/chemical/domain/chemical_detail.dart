import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/enums/risk_level.dart';
import 'exposure_route.dart';

part 'chemical_detail.freezed.dart';
part 'chemical_detail.g.dart';

/// Full detail for a single chemical, sourced from the backend knowledge base
/// (WHO / ECHA / ATSDR / IARC). The client renders this verbatim and authors no
/// clinical content of its own (docs/flutter_app_architecture.md §5.5).
@freezed
class ChemicalDetail with _$ChemicalDetail {
  const factory ChemicalDetail({
    required String id,
    required String name,
    required RiskLevel risk,
    required String chemicalClass,
    @Default(<String>[]) List<String> healthEffects,
    @Default(<ExposureRoute>[]) List<ExposureRoute> exposureRoutes,
    required String regulatoryStatus,
  }) = _ChemicalDetail;

  factory ChemicalDetail.fromJson(Map<String, dynamic> json) =>
      _$ChemicalDetailFromJson(json);
}
