import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_matcher/edc_matcher.dart';
import 'package:postgres/postgres.dart';
import 'package:edc_backend/config.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/edc_repository/edc_repository.dart';
import 'package:edc_backend/ocr/ocr_service.dart';
import 'package:edc_backend/product_resolution/product_resolution_service.dart';
import 'package:edc_backend/response_envelope.dart';

final _productService = ProductResolutionService();

// Shared cache primed once at startup and reused across all scan requests.
EdcCache? _cache;

Handler middleware(Handler handler) {
  return (context) async {
    final config = context.read<AppConfig>();
    final ocr = OcrService(apiKey: config.ocrApiKey);

    if (_cache == null) {
      final Connection conn;
      try {
        conn = await config.openConnection().timeout(const Duration(seconds: 5));
      } on TimeoutException {
        return errorResponse('db_unavailable', 'Database connection timed out.',
            statusCode: 503);
      } on Exception catch (e) {
        return errorResponse('db_unavailable', 'Database connection failed: $e',
            statusCode: 503);
      }
      final repo = EdcRepository(conn);
      _cache = EdcCache(() => repo.findAll());
      await _cache!.prime();
    }

    return handler
        .use(provider<ProductResolutionService>((_) => _productService))
        .use(provider<OcrService>((_) => ocr))
        .use(provider<List<EdcEntry>>((_) => _cache!.entries))
        .call(context);
  };
}
