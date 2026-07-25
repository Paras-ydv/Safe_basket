import 'package:dio/dio.dart';

import '../../../core/models/scan_result.dart';
import '../../../core/network/api_exception.dart';
import '../domain/scan_job.dart';
import 'scan_repository.dart';

/// Dio-backed [ScanRepository] hitting the `/scan/*` endpoints
/// (docs/flutter_app_architecture.md §3).
class ApiScanRepository implements ScanRepository {
  ApiScanRepository(this._dio);

  final Dio _dio;

  @override
  Future<ScanResult> getScanResult(String scanId) =>
      _postOrGet(() => _dio.get<Map<String, dynamic>>('/scan/$scanId'));

  @override
  Future<ScanResult> submitBarcode({
    required String value,
    required String symbology,
  }) => _postOrGet(
    // Backend takes just the barcode; the resolved product's ingredients are
    // matched server-side. Symbology is decoded on-device but not sent.
    () => _dio.post<Map<String, dynamic>>(
      '/scan/barcode',
      data: {'barcode': value},
    ),
  );

  @override
  Future<ScanResult> submitWater({
    required String sourceType,
    required String location,
  }) => _postOrGet(
    () => _dio.post<Map<String, dynamic>>(
      '/scan/water',
      data: {'sourceType': sourceType, 'location': location},
    ),
  );

  @override
  Future<ScanResult> submitManual(String query) => _postOrGet(
    () => _dio.post<Map<String, dynamic>>(
      '/scan/manual',
      data: {'query': query},
    ),
  );

  @override
  Future<String> submitImageScan(String imagePath) async {
    try {
      final form = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });
      final res = await _dio.post<Map<String, dynamic>>(
        '/scan/image',
        data: form,
      );
      return res.data!['jobId'] as String;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<ScanJobStatus> pollImageScan(String jobId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/scan/image/$jobId');
      final data = res.data!;
      final status = data['status'] as String?;
      return switch (status) {
        'done' => ScanJobStatus(
          state: ScanJobState.done,
          result: ScanResult.fromJson(data['result'] as Map<String, dynamic>),
        ),
        'failed' => ScanJobStatus(
          state: ScanJobState.failed,
          error: data['error'] as String?,
        ),
        _ => const ScanJobStatus(state: ScanJobState.pending),
      };
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<ScanResult> _postOrGet(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final res = await request();
      return ScanResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
