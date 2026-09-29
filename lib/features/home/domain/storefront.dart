import '../../../core/models/product.dart';

class StoreSlider {
  const StoreSlider({
    required this.id,
    required this.name,
    required this.mobileImageUrl,
    required this.desktopImageUrl,
    required this.link,
  });
  final String id;
  final String name;
  final String? mobileImageUrl;
  final String? desktopImageUrl;
  final String? link;

  factory StoreSlider.fromJson(Map<String, dynamic> json) => StoreSlider(
    id: json['id'].toString(),
    name: json['name']?.toString() ?? 'عرض روز برفيوم',
    mobileImageUrl: json['imageUrl']?.toString(),
    desktopImageUrl: json['desktopImageUrl']?.toString(),
    link: json['link']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': mobileImageUrl,
    'desktopImageUrl': desktopImageUrl,
    'link': link,
  };
}

class StoreCategory {
  const StoreCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
  });
  final int id;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  String get name => nameAr.isNotEmpty ? nameAr : nameEn;

  factory StoreCategory.fromJson(Map<String, dynamic> json) => StoreCategory(
    id: (json['id'] as num).toInt(),
    nameAr: json['nameAr']?.toString() ?? '',
    nameEn: json['nameEn']?.toString() ?? '',
    imageUrl: json['imageUrl']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'imageUrl': imageUrl,
  };
}

class StoreBanner {
  const StoreBanner({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.position,
    required this.link,
  });
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String position;
  final String link;

  factory StoreBanner.fromJson(Map<String, dynamic> json) => StoreBanner(
    id: int.tryParse('${json['id']}') ?? 0,
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    imageUrl: json['imageUrl']?.toString() ?? '',
    position: json['position']?.toString() ?? '',
    link: json['link']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'position': position,
    'link': link,
  };
}

class StoreTestimonial {
  const StoreTestimonial({
    required this.id,
    required this.name,
    required this.review,
    required this.job,
  });
  final int id;
  final String name;
  final String review;
  final String job;

  factory StoreTestimonial.fromJson(Map<String, dynamic> json) =>
      StoreTestimonial(
        id: int.tryParse('${json['id']}') ?? 0,
        name: _firstText(json['customerNameAr'], json['customerNameEn']),
        review: _firstText(json['customerReviewAr'], json['customerReviewEn']),
        job: _firstText(json['customerJobAr'], json['customerJobEn']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerNameAr': name,
    'customerReviewAr': review,
    'customerJobAr': job,
  };
}

class Storefront {
  const Storefront({
    required this.sliders,
    required this.categories,
    required this.products,
    required this.banners,
    required this.testimonials,
    required this.newArrivalsEnabled,
    required this.newArrivalsCount,
  });
  final List<StoreSlider> sliders;
  final List<StoreCategory> categories;
  final List<Product> products;
  final List<StoreBanner> banners;
  final List<StoreTestimonial> testimonials;
  final bool newArrivalsEnabled;
  final int newArrivalsCount;
  List<Product> get featured =>
      products.where((item) => item.isFeatured).toList();
  List<Product> get recent => products.take(newArrivalsCount).toList();
  List<Product> get sale =>
      products.where((item) => item.isDiscounted).toList();

  factory Storefront.fromJson(Map<String, dynamic> json) => Storefront(
    sliders: (json['sliders'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => StoreSlider.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    categories: (json['categories'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => StoreCategory.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    products: (json['products'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    banners: (json['banners'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => StoreBanner.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    testimonials: (json['testimonials'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (item) => StoreTestimonial.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(),
    newArrivalsEnabled: json['newArrivalsEnabled'] != false,
    newArrivalsCount: ((json['newArrivalsCount'] as num?)?.toInt() ?? 6).clamp(
      1,
      12,
    ),
  );

  Map<String, dynamic> toJson() => {
    'sliders': sliders.map((item) => item.toJson()).toList(),
    'categories': categories.map((item) => item.toJson()).toList(),
    'products': products.map((item) => item.toJson()).toList(),
    'banners': banners.map((item) => item.toJson()).toList(),
    'testimonials': testimonials.map((item) => item.toJson()).toList(),
    'newArrivalsEnabled': newArrivalsEnabled,
    'newArrivalsCount': newArrivalsCount,
  };
}

String _firstText(dynamic arabic, dynamic english) {
  final ar = arabic?.toString().trim() ?? '';
  return ar.isNotEmpty ? ar : english?.toString().trim() ?? '';
}
