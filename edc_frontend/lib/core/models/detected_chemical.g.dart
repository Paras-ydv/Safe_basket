// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detected_chemical.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DetectedChemicalImpl _$$DetectedChemicalImplFromJson(
  Map<String, dynamic> json,
) => _$DetectedChemicalImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  risk: $enumDecode(_$RiskLevelEnumMap, json['risk']),
);

Map<String, dynamic> _$$DetectedChemicalImplToJson(
  _$DetectedChemicalImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'risk': _$RiskLevelEnumMap[instance.risk]!,
};

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.veryHigh: 'very_high',
};
