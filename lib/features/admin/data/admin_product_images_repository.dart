import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AdminProductImage {
  const AdminProductImage({required this.id, required this.url});
  final int id;
  final String url;
  factory AdminProductImage.fromJson(Map<String, dynamic> json) =>
      AdminProductImage(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse('${json['id']}') ?? 0,
        url: json['imageUrl']?.toString() ?? '',
      );
}

class AdminProductImagesRepository {
  const AdminProductImagesRepository(this._dio);
  final Dio _dio;

  Future<List<AdminProductImage>> fetch(int productId) async {
    final response = await _dio.get<dynamic>(
      '/api/ProductImage/get-image-by-product-id/$productId',
    );
    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : const <String, dynamic>{};
    final data = body['data'];
    return data is List
        ? data
              .whereType<Map>()
              .map(
                (item) =>
                    AdminProductImage.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const [];
  }

  Future<void> upload({
    required int productId,
    required PlatformFile file,
  }) async {
    final multipart = file.bytes != null
        ? MultipartFile.fromBytes(file.bytes!, filename: file.name)
        : await MultipartFile.fromFile(file.path!, filename: file.name);
    await _dio.post<dynamic>(
      '/api/ProductImage/create-product-image',
      data: FormData.fromMap({'productId': productId, 'imageFile': multipart}),
    );
  }

  Future<void> replace({
    required int imageId,
    required int productId,
    required PlatformFile file,
  }) async {
    final multipart = file.bytes != null
        ? MultipartFile.fromBytes(file.bytes!, filename: file.name)
        : await MultipartFile.fromFile(file.path!, filename: file.name);
    await _dio.post<dynamic>(
      '/api/ProductImage/update-image',
      data: FormData.fromMap({
        'id': imageId,
        'productId': productId,
        'imageFile': multipart,
      }),
    );
  }

  Future<void> delete(int imageId) => _dio.delete<dynamic>(
    '/api/ProductImage/delete-product-image',
    queryParameters: {'id': imageId},
  );
}

final adminProductImagesRepositoryProvider =
    Provider<AdminProductImagesRepository>(
      (ref) => AdminProductImagesRepository(ref.watch(dioProvider)),
    );
