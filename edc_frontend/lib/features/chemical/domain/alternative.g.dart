// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alternative.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlternativeImpl _$$AlternativeImplFromJson(Map<String, dynamic> json) =>
    _$AlternativeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      risk: $enumDecode(_$RiskLevelEnumMap, json['risk']),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$AlternativeImplToJson(_$AlternativeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'risk': _$RiskLevelEnumMap[instance.risk]!,
      'note': instance.note,
    };

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.veryHigh: 'very_high',
};
