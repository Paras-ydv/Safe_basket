import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:edc_backend/product_resolution/product_resolution_service.dart';
import 'package:edc_backend/product_resolution/cache_store.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

http.Client _clientReturning(Map<String, http.Response> urlResponses) {
  return MockClient((request) async {
    final key = request.url.toString();
    return urlResponses[key] ??
        http.Response(jsonEncode({'status': 0}), 404);
  });
}

http.Response _offHit(String barcode, {String name = 'Test Product'}) {
  return http.Response(
    jsonEncode({
      'status': 1,
      'product': {
        'product_name': name,
        'brands': 'Test Brand',
        'image_url': 'https://example.com/img.jpg',
        'ingredients_text': 'water, salt',
        'packaging_tags': ['plastic', 'glass'],
      },
    }),
    200,
  );
}

http.Response _offMiss() =>
    http.Response(jsonEncode({'status': 0}), 200);

const _barcode = '1234567890';
const _food = 'https://world.openfoodfacts.org/api/v2/product/$_barcode.json';
const _beauty = 'https://world.openbeautyfacts.org/api/v2/product/$_barcode.json';
const _products = 'https://world.openproductsfacts.org/api/v2/product/$_barcode.json';

ProductResolutionService _service(http.Client client) =>
    ProductResolutionService(
      client: client,
      cache: InMemoryCacheStore(),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('resolveBarcode', () {
    test('found in first source (openfoodfacts)', () async {
      final client = _clientReturning({_food: _offHit(_barcode)});
      final result = await _service(client).resolveBarcode(_barcode);

      expect(result.barcode, _barcode);
      expect(result.name, 'Test Product');
      expect(result.brand, 'Test Brand');
      expect(result.packagingMaterials, ['plastic', 'glass']);
      expect(result.sourceUrl, _food);
    });

    test('found in fallback source (openbeautyfacts) when food misses', () async {
      final client = _clientReturning({
        _food: _offMiss(),
        _beauty: _offHit(_barcode, name: 'Beauty Product'),
      });
      final result = await _service(client).resolveBarcode(_barcode);

      expect(result.name, 'Beauty Product');
      expect(result.sourceUrl, _beauty);
    });

    test('throws ProductNotFoundException when no source has the barcode', () async {
      final client = _clientReturning({
        _food: _offMiss(),
        _beauty: _offMiss(),
        _products: _offMiss(),
      });

      expect(
        () => _service(client).resolveBarcode(_barcode),
        throwsA(isA<ProductNotFoundException>()),
      );
    });

    test('throws ProductNetworkException on network error from all sources',
        () async {
      final client = MockClient((_) async => throw Exception('connection refused'));

      expect(
        () => _service(client).resolveBarcode(_barcode),
        throwsA(isA<ProductNetworkException>()),
      );
    });
  });
}
