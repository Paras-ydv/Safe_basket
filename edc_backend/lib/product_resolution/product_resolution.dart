class ProductResolution {
  const ProductResolution({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.ingredientsText,
    required this.packagingMaterials,
    required this.sourceUrl,
  });

  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;
  final String ingredientsText;
  final List<String> packagingMaterials;
  final String sourceUrl;

  Map<String, Object?> toJson() => {
        'barcode': barcode,
        'name': name,
        'brand': brand,
        'image_url': imageUrl,
        'ingredients_text': ingredientsText,
        'packaging_materials': packagingMaterials,
        'source_url': sourceUrl,
      };
}
