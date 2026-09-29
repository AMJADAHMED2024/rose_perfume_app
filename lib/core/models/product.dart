class Product {
  const Product({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.imageUrl,
    this.imageUrls = const [],
    this.discountPrice,
    this.isFeatured = false,
    this.isDiscounted = false,
    this.offer,
    this.stockQuantity,
    this.categoryId,
    this.categoryNameAr,
    this.descriptionAr,
    this.weightKg = 0,
    this.variants = const [],
    this.selectedVariantId,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final double price;
  final String? imageUrl;
  final List<String> imageUrls;
  final double? discountPrice;
  final bool isFeatured;
  final bool isDiscounted;
  final String? offer;
  final int? stockQuantity;
  final int? categoryId;
  final String? categoryNameAr;
  final String? descriptionAr;
  final double weightKg;
  final List<ProductVariant> variants;
  final int? selectedVariantId;

  String get name => nameAr.isNotEmpty ? nameAr : nameEn;
  double get salePrice => discountPrice ?? price;
  bool get isInStock => stockQuantity == null || stockQuantity! > 0;
  String get cartKey =>
      selectedVariantId == null ? id : '$id:$selectedVariantId';

  Product withVariant(ProductVariant variant) => Product(
    id: id,
    nameAr: variant.name.isEmpty ? nameAr : '$nameAr — ${variant.name}',
    nameEn: variant.name.isEmpty ? nameEn : '$nameEn — ${variant.name}',
    price: variant.price,
    imageUrl: imageUrl,
    imageUrls: imageUrls,
    isFeatured: isFeatured,
    isDiscounted: false,
    offer: offer,
    stockQuantity: stockQuantity,
    categoryId: categoryId,
    categoryNameAr: categoryNameAr,
    descriptionAr: descriptionAr,
    weightKg: variant.weightInGram / 1000,
    variants: variants,
    selectedVariantId: variant.id,
  );

  factory Product.fromJson(Map<String, dynamic> json) {
    final images = json['imageUrls'];
    final imageUrls = images is List
        ? images
              .map((image) => image?.toString().trim() ?? '')
              .where((image) => image.isNotEmpty)
              .toList()
        : <String>[];
    final primaryImage = imageUrls.isNotEmpty
        ? imageUrls.first
        : json['imageUrl']?.toString();
    final rawVariants = json['product_variant'] ?? json['productVariants'];
    return Product(
      id: json['id'].toString(),
      nameAr: json['nameAr']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      price: _asDouble(json['price']),
      imageUrl: primaryImage,
      imageUrls: imageUrls,
      discountPrice: json['finalPrice'] == null
          ? null
          : _asDouble(json['finalPrice']),
      isFeatured: json['isFeatured'] == true,
      isDiscounted: json['isDiscounted'] == true,
      offer: json['offer']?.toString(),
      stockQuantity: json['stockQuantity'] is num
          ? (json['stockQuantity'] as num).toInt()
          : null,
      categoryId: json['categoryId'] is num
          ? (json['categoryId'] as num).toInt()
          : null,
      categoryNameAr: json['categoryNameAr']?.toString(),
      descriptionAr: json['descriptionAr']?.toString(),
      weightKg: _asDouble(json['weight']),
      variants: rawVariants is List
          ? rawVariants
                .whereType<Map>()
                .map(
                  (item) =>
                      ProductVariant.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
      selectedVariantId: json['selectedVariantId'] is num
          ? (json['selectedVariantId'] as num).toInt()
          : int.tryParse('${json['selectedVariantId'] ?? ''}'),
    );
  }

  static double _asDouble(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'price': price,
    'imageUrl': imageUrl,
    'imageUrls': imageUrls,
    'finalPrice': discountPrice,
    'isFeatured': isFeatured,
    'isDiscounted': isDiscounted,
    'offer': offer,
    'stockQuantity': stockQuantity,
    'categoryId': categoryId,
    'categoryNameAr': categoryNameAr,
    'descriptionAr': descriptionAr,
    'weight': weightKg,
    'product_variant': variants.map((item) => item.toJson()).toList(),
    'selectedVariantId': selectedVariantId,
  };
}

class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.name,
    required this.weightInGram,
    required this.price,
  });
  final int id;
  final String name;
  final double weightInGram;
  final double price;
  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
    id: json['id'] is num
        ? (json['id'] as num).toInt()
        : int.tryParse('${json['id']}') ?? 0,
    name: '${json['name'] ?? ''}',
    weightInGram: Product._asDouble(json['weightInGram']),
    price: Product._asDouble(json['price']),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'weightInGram': weightInGram,
    'price': price,
  };
}
