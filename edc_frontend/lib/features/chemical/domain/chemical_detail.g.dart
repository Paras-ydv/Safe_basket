// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chemical_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChemicalDetailImpl _$$ChemicalDetailImplFromJson(Map<String, dynamic> json) =>
    _$ChemicalDetailImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      risk: $enumDecode(_$RiskLevelEnumMap, json['risk']),
      chemicalClass: json['chemical_class'] as String,
      healthEffects:
          (json['health_effects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      exposureRoutes:
          (json['exposure_routes'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$ExposureRouteEnumMap, e))
              .toList() ??
          const <ExposureRoute>[],
      regulatoryStatus: json['regulatory_status'] as String,
    );

Map<String, dynamic> _$$ChemicalDetailImplToJson(
  _$ChemicalDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'risk': _$RiskLevelEnumMap[instance.risk]!,
  'chemical_class': instance.chemicalClass,
  'health_effects': instance.healthEffects,
  'exposure_routes': instance.exposureRoutes
      .map((e) => _$ExposureRouteEnumMap[e]!)
      .toList(),
  'regulatory_status': instance.regulatoryStatus,
};

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.veryHigh: 'very_high',
};

const _$ExposureRouteEnumMap = {
  ExposureRoute.dermal: 'dermal',
  ExposureRoute.ingestion: 'ingestion',
  ExposureRoute.inhalation: 'inhalation',
};
