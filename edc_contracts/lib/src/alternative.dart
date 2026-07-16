import 'risk_level.dart';

/// A safer alternative to a chemical.
class Alternative {
  const Alternative({
    required this.id,
    required this.name,
    required this.risk,
    this.note,
  });

  final String id;
  final String name;
  final RiskLevel risk;
  final String? note;

  factory Alternative.fromJson(Map<String, dynamic> json) => Alternative(
    id: json['id'] as String,
    name: json['name'] as String,
    risk: RiskLevel.fromWire(json['risk'] as String?),
    note: json['note'] as String?,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'risk': risk.wire,
    'note': note,
  };
}
