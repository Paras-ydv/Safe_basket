import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/product_resolution/product_resolution_service.dart';

final _service = ProductResolutionService();

Handler middleware(Handler handler) {
  return handler.use(provider<ProductResolutionService>((_) => _service));
}
