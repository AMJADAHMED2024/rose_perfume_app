import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AdminBranch {
  const AdminBranch({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.phone,
    required this.latitude,
    required this.longitude,
  });
  final int id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final String phone;
  final double latitude;
  final double longitude;

  factory AdminBranch.fromJson(Map<String, dynamic> json) => AdminBranch(
    id: _int(json['id']),
    nameAr: _text(json['nameAr']),
    nameEn: _text(json['nameEn']),
    descriptionAr: _text(json['descriptionAr']),
    descriptionEn: _text(json['descriptionEn']),
    phone: _text(json['phone']),
    latitude: _double(json['late']),
    longitude: _double(json['lang']),
  );
}

class AdminBanner {
  const AdminBanner({
    required this.id,
    required this.title,
    required this.description,
    required this.link,
    required this.position,
    required this.imageUrl,
  });
  final int id;
  final String title;
  final String description;
  final String link;
  final String position;
  final String imageUrl;

  factory AdminBanner.fromJson(Map<String, dynamic> json) => AdminBanner(
    id: _int(json['id']),
    title: _text(json['title']),
    description: _text(json['description']),
    link: _text(json['link']),
    position: _text(json['position']),
    imageUrl: _text(json['imageUrl']),
  );
}

class AdminSlider {
  const AdminSlider({
    required this.id,
    required this.name,
    required this.link,
    required this.mobileImageUrl,
    required this.desktopImageUrl,
    required this.isPublished,
  });
  final int id;
  final String name;
  final String link;
  final String mobileImageUrl;
  final String desktopImageUrl;
  final bool isPublished;

  factory AdminSlider.fromJson(Map<String, dynamic> json) => AdminSlider(
    id: _int(json['id']),
    name: _text(json['name']),
    link: _text(json['link']),
    mobileImageUrl: _text(json['imageUrl']),
    desktopImageUrl: _text(json['desktopImageUrl']),
    isPublished: json['ispublish'] == true || json['isPublish'] == true,
  );
}

class AdminTestimonial {
  const AdminTestimonial({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.reviewAr,
    required this.reviewEn,
    required this.jobAr,
    required this.jobEn,
  });
  final int id;
  final String nameAr;
  final String nameEn;
  final String reviewAr;
  final String reviewEn;
  final String jobAr;
  final String jobEn;

  factory AdminTestimonial.fromJson(Map<String, dynamic> json) =>
      AdminTestimonial(
        id: _int(json['id']),
        nameAr: _text(json['customerNameAr']),
        nameEn: _text(json['customerNameEn']),
        reviewAr: _text(json['customerReviewAr']),
        reviewEn: _text(json['customerReviewEn']),
        jobAr: _text(json['customerJobAr']),
        jobEn: _text(json['customerJobEn']),
      );
}

class AdminStorefrontRepository {
  const AdminStorefrontRepository(this._dio);
  final Dio _dio;

  Future<List<AdminBranch>> fetchBranches() async {
    final response = await _dio.get<dynamic>('/api/Branche/get-all');
    return _items(_data(response.data)).map(AdminBranch.fromJson).toList();
  }

  Future<void> saveBranch(AdminBranchDraft draft, {int? id}) => id == null
      ? _dio.post<dynamic>('/api/Branche/create', data: draft.toJson())
      : _dio.put<dynamic>('/api/Branche/update/$id', data: draft.toJson());

  Future<void> deleteBranch(int id) =>
      _dio.delete<dynamic>('/api/Branche/delete/$id');

  Future<List<AdminBanner>> fetchBanners() async {
    final response = await _dio.get<dynamic>('/api/Banner/get-all-banners');
    return _items(_data(response.data)).map(AdminBanner.fromJson).toList();
  }

  Future<void> saveBanner(
    AdminBannerDraft draft, {
    int? id,
    PlatformFile? image,
  }) async {
    final data = await _withFile(draft.toJson(), 'image', image);
    if (id == null) {
      await _dio.post<dynamic>('/api/Banner/create-banner', data: data);
    } else {
      data.fields.add(MapEntry('id', '$id'));
      await _dio.put<dynamic>('/api/Banner/update-banner-by-id', data: data);
    }
  }

  Future<void> deleteBanner(int id) => _dio.delete<dynamic>(
    '/api/Banner/delete-banner-by-id',
    queryParameters: {'id': id},
  );

  Future<List<AdminSlider>> fetchSliders() async {
    final response = await _dio.get<dynamic>('/api/Slider/get-all-slider');
    return _items(_data(response.data)).map(AdminSlider.fromJson).toList();
  }

  Future<int> createSlider(AdminSliderDraft draft) async {
    final response = await _dio.post<dynamic>(
      '/api/Slider/create-slider',
      data: draft.toJson(),
    );
    return _int(_map(_data(response.data))['id']);
  }

  Future<void> updateSlider(int id, AdminSliderDraft draft) => _dio
      .post<dynamic>('/api/Slider/update-silder', data: draft.toJson(id: id));

  Future<void> toggleSlider(int id) =>
      _dio.get<dynamic>('/api/Slider/publish-slider/$id');

  Future<void> deleteSlider(int id) =>
      _dio.get<dynamic>('/api/Slider/delete-slider/$id');

  Future<void> uploadSliderImage({
    required int sliderId,
    required PlatformFile image,
    required bool desktop,
  }) async {
    final data = await _withFile({'sliderId': sliderId}, 'imageFile', image);
    await _dio.post<dynamic>(
      desktop
          ? '/api/SliderImage/create-slider-desktop-image'
          : '/api/SliderImage/create-slider-image',
      data: data,
    );
  }

  Future<List<AdminTestimonial>> fetchTestimonials() async {
    final response = await _dio.post<dynamic>(
      '/api/Testimonial/get-all-testimonial',
      data: const {'pageNumber': 1, 'pageSize': 100},
    );
    return _items(_data(response.data)).map(AdminTestimonial.fromJson).toList();
  }

  Future<void> saveTestimonial(AdminTestimonialDraft draft, {int? id}) =>
      id == null
      ? _dio.post<dynamic>(
          '/api/Testimonial/create-testimonial',
          data: draft.toJson(),
        )
      : _dio.put<dynamic>(
          '/api/Testimonial/update-testimonial',
          queryParameters: {'id': id},
          data: draft.toJson(),
        );

  Future<void> deleteTestimonial(int id) => _dio.delete<dynamic>(
    '/api/Testimonial/delete-testimonial',
    queryParameters: {'id': id},
  );
}

class AdminBranchDraft {
  const AdminBranchDraft({
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.phone,
    required this.latitude,
    required this.longitude,
  });
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final String phone;
  final double latitude;
  final double longitude;
  Map<String, dynamic> toJson() => {
    'nameAr': nameAr,
    'nameEn': nameEn,
    'descriptionAr': descriptionAr,
    'descriptionEn': descriptionEn,
    'phone': phone,
    'late': latitude,
    'lang': longitude,
  };
}

class AdminBannerDraft {
  const AdminBannerDraft({
    required this.title,
    required this.description,
    required this.link,
    required this.position,
  });
  final String title;
  final String description;
  final String link;
  final String position;
  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'link': link,
    'position': position,
  };
}

class AdminSliderDraft {
  const AdminSliderDraft({
    required this.name,
    required this.link,
    required this.isPublished,
  });
  final String name;
  final String link;
  final bool isPublished;
  Map<String, dynamic> toJson({int? id}) {
    final payload = <String, dynamic>{
      'name': name,
      'link': link,
      'ispublish': isPublished,
    };
    if (id != null) payload['id'] = id;
    return payload;
  }
}

class AdminTestimonialDraft {
  const AdminTestimonialDraft({
    required this.nameAr,
    required this.nameEn,
    required this.reviewAr,
    required this.reviewEn,
    required this.jobAr,
    required this.jobEn,
  });
  final String nameAr;
  final String nameEn;
  final String reviewAr;
  final String reviewEn;
  final String jobAr;
  final String jobEn;
  Map<String, dynamic> toJson() => {
    'customerNameAr': nameAr,
    'customerNameEn': nameEn,
    'customerReviewAr': reviewAr,
    'customerReviewEn': reviewEn,
    'customerJobAr': jobAr,
    'customerJobEn': jobEn,
    'createdAt': DateTime.now().toUtc().toIso8601String(),
  };
}

final adminStorefrontRepositoryProvider = Provider<AdminStorefrontRepository>(
  (ref) => AdminStorefrontRepository(ref.watch(dioProvider)),
);

Future<FormData> _withFile(
  Map<String, dynamic> values,
  String field,
  PlatformFile? file,
) async {
  final data = FormData.fromMap(values);
  if (file == null) return data;
  final multipart = file.bytes != null
      ? MultipartFile.fromBytes(file.bytes!, filename: file.name)
      : await MultipartFile.fromFile(file.path!, filename: file.name);
  data.files.add(MapEntry(field, multipart));
  return data;
}

dynamic _data(dynamic value) => _map(value)['data'];
Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};
List<Map<String, dynamic>> _items(dynamic value) {
  final raw = value is Map ? _map(value)['items'] : value;
  return raw is List
      ? raw
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : const [];
}

int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
double _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
String _text(dynamic value) => value?.toString().trim() ?? '';
