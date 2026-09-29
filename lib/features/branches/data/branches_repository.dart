import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class StoreBranch {
  const StoreBranch({
    required this.id,
    required this.name,
    required this.description,
    required this.phone,
    required this.latitude,
    required this.longitude,
  });
  final int id;
  final String name;
  final String description;
  final String phone;
  final double latitude;
  final double longitude;

  factory StoreBranch.fromJson(Map<String, dynamic> json) {
    final nameAr = _text(json['nameAr']);
    final descriptionAr = _text(json['descriptionAr']);
    return StoreBranch(
      id: _int(json['id']),
      name: nameAr.isEmpty ? _text(json['nameEn']) : nameAr,
      description: descriptionAr.isEmpty
          ? _text(json['descriptionEn'])
          : descriptionAr,
      phone: _text(json['phone']),
      latitude: _number(json['late']),
      longitude: _number(json['lang']),
    );
  }
}

class BranchesRepository {
  const BranchesRepository(this._dio);
  final Dio _dio;

  Future<List<StoreBranch>> fetch() async {
    final response = await _dio.get<dynamic>('/api/Branche/get-all');
    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : const <String, dynamic>{};
    final data = body['data'];
    final raw = data is Map ? data['items'] : data;
    return raw is List
        ? raw
              .whereType<Map>()
              .map(
                (item) => StoreBranch.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const [];
  }
}

final branchesRepositoryProvider = Provider<BranchesRepository>(
  (ref) => BranchesRepository(ref.watch(dioProvider)),
);
final branchesProvider = FutureProvider.autoDispose<List<StoreBranch>>(
  (ref) => ref.watch(branchesRepositoryProvider).fetch(),
);

int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
double _number(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
String _text(dynamic value) => value?.toString().trim() ?? '';
