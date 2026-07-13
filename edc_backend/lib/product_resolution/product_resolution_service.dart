import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cache_store.dart';
import 'product_resolution.dart';

/// Thrown when no source has a record for the requested barcode.
class ProductNotFoundException implements Exception {
  const ProductNotFoundException(this.barcode);
  final String barcode;
}

/// Thrown when every source returned a network-level error.
class ProductNetworkException implements Exception {
  const ProductNetworkException(this.message);
  final String message;
}

const _sources = [
  'https://world.openfoodfacts.org/api/v2/product',
  'https://world.openbeautyfacts.org/api/v2/product',
  'https://world.openproductsfacts.org/api/v2/product',
];

class ProductResolutionService {
  ProductResolutionService({
    http.Client? client,
    CacheStore<ProductResolution>? cache,
  })  : _client = client ?? http.Client(),
        _cache = cache ?? InMemoryCacheStore<ProductResolution>();

  final http.Client _client;
  final CacheStore<ProductResolution> _cache;

  Future<ProductResolution> resolveBarcode(String barcode) async {
    final cached = await _cache.get(barcode);
    if (cached != null) return cached;

    Object? lastError;

    for (final base in _sources) {
      final url = Uri.parse('$base/$barcode.json');
      try {
        final response = await _client.get(url).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Timeout fetching $base'),
        );
        if (response.statusCode == 404) continue;
        if (response.statusCode != 200) {
          lastError = 'HTTP ${response.statusCode} from $base';
          continue;
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final status = body['status'];
        // OFF APIs return status=0 or status="failure" when not found
        if (status == 0 || status == 'failure') continue;

        final product = body['product'] as Map<String, dynamic>? ?? {};
        final resolved = _parse(barcode, product, url.toString());
        await _cache.set(barcode, resolved, ttl: const Duration(hours: 24));
        return resolved;
      } on Exception catch (e) {
        lastError = e;
      }
    }

    if (lastError != null && lastError is! String) {
      throw ProductNetworkException(lastError.toString());
    }
    throw ProductNotFoundException(barcode);
  }

  ProductResolution _parse(
    String barcode,
    Map<String, dynamic> p,
    String sourceUrl,
  ) {
    final packaging = switch (p['packaging_tags']) {
      final List<dynamic> tags => tags.cast<String>(),
      _ => switch (p['packaging']) {
          final String s when s.isNotEmpty =>
            s.split(',').map((e) => e.trim()).toList(),
          _ => <String>[],
        },
    };

    return ProductResolution(
      barcode: barcode,
      name: (p['product_name'] as String? ?? '').trim(),
      brand: (p['brands'] as String? ?? '').trim(),
      imageUrl: p['image_url'] as String?,
      ingredientsText: (p['ingredients_text'] as String? ?? '').trim(),
      packagingMaterials: packaging,
      sourceUrl: sourceUrl,
    );
  }
}
