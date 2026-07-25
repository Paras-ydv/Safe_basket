import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../domain/alternative.dart';
import '../domain/chemical_detail.dart';
import 'chemical_repository.dart';

/// Dio-backed [ChemicalRepository] hitting `GET /chemicals/{id}` and
/// `GET /chemicals/{id}/alternatives` (docs/flutter_app_architecture.md §3).
class ApiChemicalRepository implements ChemicalRepository {
  ApiChemicalRepository(this._dio);

  final Dio _dio;

  @override
  Future<ChemicalDetail> getChemical(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/chemicals/$id');
      return ChemicalDetail.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<List<Alternative>> getAlternatives(String id) async {
    try {
      // dynamic: unwrap the envelope to a List via the EnvelopeInterceptor.
      final res = await _dio.get<dynamic>('/chemicals/$id/alternatives');
      final list = (res.data as List<dynamic>?) ?? const [];
      return list
          .map((e) => Alternative.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
