import 'package:dart_frog/dart_frog.dart';
import 'package:edc_matcher/edc_matcher.dart';
import 'package:edc_backend/config.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/ocr/ocr_service.dart';
import 'package:edc_backend/product_resolution/product_resolution_service.dart';

final _productService = ProductResolutionService();

Handler middleware(Handler handler) {
  return (context) {
    final config = context.read<AppConfig>();
    final ocr = OcrService(tesseractPath: config.tesseractPath);
    final entries = context.read<EdcCache>().entries;
    return handler
        .use(provider<ProductResolutionService>((_) => _productService))
        .use(provider<OcrService>((_) => ocr))
        .use(provider<List<EdcEntry>>((_) => entries))
        .call(context);
  };
}
