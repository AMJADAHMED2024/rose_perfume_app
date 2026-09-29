import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';

class StoreContentDocument {
  const StoreContentDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
  });

  final String id;
  final String title;
  final String type;
  final String content;

  factory StoreContentDocument.fromJson(Map<String, dynamic> json) =>
      StoreContentDocument(
        id: _text(json['id']),
        title: _text(json['title']),
        type: _text(json['type']),
        content: _text(json['content']),
      );
}

class StoreContentRepository {
  const StoreContentRepository(this._dio, this._database);
  static const _cacheId = 'store-content-v1';

  final Dio _dio;
  final AppDatabase _database;

  Future<List<StoreContentDocument>> fetch() async {
    try {
      final response = await _dio.get<dynamic>('/api/Content/get-all');
      final documents = _list(
        _map(response.data)['data'],
      ).map(StoreContentDocument.fromJson).toList();
      await _cache(documents);
      return documents;
    } on DioException {
      return _readCache();
    }
  }

  Future<void> save({required String type, required String content}) async {
    await _dio.post<dynamic>(
      '/api/Content/save',
      data: {'type': type, 'content': content},
    );
  }

  Future<void> _cache(List<StoreContentDocument> documents) => _database
      .into(_database.storefrontCache)
      .insertOnConflictUpdate(
        StorefrontCacheCompanion.insert(
          id: _cacheId,
          payload: jsonEncode(
            documents
                .map(
                  (document) => {
                    'id': document.id,
                    'title': document.title,
                    'type': document.type,
                    'content': document.content,
                  },
                )
                .toList(),
          ),
          updatedAt: DateTime.now(),
        ),
      );

  Future<List<StoreContentDocument>> _readCache() async {
    final row = await (_database.select(
      _database.storefrontCache,
    )..where((table) => table.id.equals(_cacheId))).getSingleOrNull();
    if (row == null) return const [];
    try {
      return _list(
        jsonDecode(row.payload),
      ).map(StoreContentDocument.fromJson).toList();
    } on FormatException {
      return const [];
    }
  }
}

final storeContentRepositoryProvider = Provider<StoreContentRepository>(
  (ref) => StoreContentRepository(
    ref.watch(dioProvider),
    ref.watch(appDatabaseProvider),
  ),
);

final storeContentProvider =
    FutureProvider.autoDispose<List<StoreContentDocument>>(
      (ref) => ref.watch(storeContentRepositoryProvider).fetch(),
    );

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

List<Map<String, dynamic>> _list(dynamic value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
    : const [];

String _text(dynamic value) => value?.toString().trim() ?? '';
