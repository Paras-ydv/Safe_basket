class ProductResolution {
  const ProductResolution({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.ingredientsText,
    required this.ingredientsTextIsEnglish,
    required this.packagingMaterials,
    required this.sourceUrl,
  });

  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;

  /// Ingredients text, sourced from `ingredients_text_en` when available,
  /// otherwise from the generic `ingredients_text` field only when the
  /// product's listed language is English (`lang == 'en'`).
  /// Empty string when no English text could be determined.
  final String ingredientsText;

  /// True only when [ingredientsText] is confirmed to be English.
  /// False when the generic field was used but the product language is
  /// non-English, or when no ingredients text was available at all.
  final bool ingredientsTextIsEnglish;

  final List<String> packagingMaterials;
  final String sourceUrl;

  Map<String, Object?> toJson() => {
        'barcode': barcode,
        'name': name,
        'brand': brand,
        'image_url': imageUrl,
        'ingredients_text': ingredientsText.isEmpty ? null : ingredientsText,
        'ingredients_text_is_english': ingredientsTextIsEnglish,
        'packaging_materials': packagingMaterials,
        'source_url': sourceUrl,
      };
}
