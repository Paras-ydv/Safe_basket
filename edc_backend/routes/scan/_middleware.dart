import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/config.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/edc_repository/edc_repository.dart';
import 'package:edc_backend/ocr/ocr_service.dart';
import 'package:edc_backend/product_resolution/product_resolution_service.dart';
import 'package:postgres/postgres.dart';

final _productService = ProductResolutionService();
EdcCache? _edcCache;

Handler middleware(Handler handler) {
  return (context) async {
    final config = context.read<AppConfig>();
    final ocr = OcrService(apiKey: config.ocrApiKey);

    // Prime the cache once on first request.
    if (_edcCache == null) {
      final Connection conn = await config.openConnection();
      final repo = EdcRepository(conn);
      _edcCache = EdcCache(() async {
        final c = await config.openConnection();
        final r = EdcRepository(c);
        final entries = await r.findAll();
        await c.close();
        return entries;
      });
      await _edcCache!.prime();
      await conn.close();
    }

    return handler
        .use(provider<ProductResolutionService>((_) => _productService))
        .use(provider<OcrService>((_) => ocr))
        .use(provider<EdcCache>((_) => _edcCache!))
        .call(context);
  };
}
