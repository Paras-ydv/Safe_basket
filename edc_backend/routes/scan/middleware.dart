import 'package:dart_frog/dart_frog.dart';
import 'package:edc_matcher/edc_matcher.dart';
import 'package:edc_backend/config.dart';
import 'package:edc_backend/ocr/ocr_service.dart';
import 'package:edc_backend/product_resolution/product_resolution_service.dart';

final _productService = ProductResolutionService();

// EdcEntry list is loaded once at startup from the repository.
// For now we provide an empty list — swap in EdcRepository.findAll()
// once a DB connection is wired into middleware.
const _entries = <EdcEntry>[];

Handler middleware(Handler handler) {
  return (context) {
    final config = context.read<AppConfig>();
    final ocr = OcrService(apiKey: config.ocrApiKey);
    return handler
        .use(provider<ProductResolutionService>((_) => _productService))
        .use(provider<OcrService>((_) => ocr))
        .use(provider<List<EdcEntry>>((_) => _entries))
        .call(context);
  };
}
