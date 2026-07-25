import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/enums/risk_level.dart';

part 'alternative.freezed.dart';
part 'alternative.g.dart';

/// A safer alternative to a chemical, supplied by the backend
/// (`GET /chemicals/{id}/alternatives`, docs/flutter_app_architecture.md §3).
/// The client renders it as-is and never decides what is "safer".
@freezed
class Alternative with _$Alternative {
  const factory Alternative({
    required String id,
    required String name,
    required RiskLevel risk,
    String? note,
  }) = _Alternative;

  factory Alternative.fromJson(Map<String, dynamic> json) =>
      _$AlternativeFromJson(json);
}
