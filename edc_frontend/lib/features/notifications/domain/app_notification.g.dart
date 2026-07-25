// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$AppNotificationImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  receivedAt: DateTime.parse(json['received_at'] as String),
  risk: $enumDecodeNullable(_$RiskLevelEnumMap, json['risk']),
  read: json['read'] as bool? ?? false,
);

Map<String, dynamic> _$$AppNotificationImplToJson(
  _$AppNotificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'received_at': instance.receivedAt.toIso8601String(),
  'risk': _$RiskLevelEnumMap[instance.risk],
  'read': instance.read,
};

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.veryHigh: 'very_high',
};
