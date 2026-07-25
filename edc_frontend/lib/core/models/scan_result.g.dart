// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScanResultImpl _$$ScanResultImplFromJson(Map<String, dynamic> json) =>
    _$ScanResultImpl(
      scanId: json['scan_id'] as String,
      productName: json['product_name'] as String,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      overallRisk: $enumDecode(_$RiskLevelEnumMap, json['overall_risk']),
      detectedChemicals:
          (json['detected_chemicals'] as List<dynamic>?)
              ?.map((e) => DetectedChemical.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DetectedChemical>[],
      productMeta: json['product_meta'] as String?,
      disclaimer: json['disclaimer'] as String?,
    );

Map<String, dynamic> _$$ScanResultImplToJson(_$ScanResultImpl instance) =>
    <String, dynamic>{
      'scan_id': instance.scanId,
      'product_name': instance.productName,
      'scanned_at': instance.scannedAt.toIso8601String(),
      'overall_risk': _$RiskLevelEnumMap[instance.overallRisk]!,
      'detected_chemicals': instance.detectedChemicals,
      'product_meta': instance.productMeta,
      'disclaimer': instance.disclaimer,
    };

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.veryHigh: 'very_high',
};
