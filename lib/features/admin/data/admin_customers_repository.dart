import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class AdminCustomer {
  const AdminCustomer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.createdAt,
    required this.role,
  });
  final int id;
  final String name;
  final String email;
  final String phone;
  final bool status;
  final DateTime? createdAt;
  final String role;
  factory AdminCustomer.fromJson(Map<String, dynamic> j) => AdminCustomer(
    id: _int(j['id']),
    name: '${j['name'] ?? ''}',
    email: '${j['email'] ?? ''}',
    phone: '${j['phone'] ?? j['phoneNumber'] ?? ''}',
    status: j['status'] == true,
    createdAt: DateTime.tryParse('${j['createdAt'] ?? ''}')?.toLocal(),
    role: _role(j['role']),
  );
}

/// The editable subset of a customer profile. Password is deliberately only
/// accepted when an administrator creates an account; changing passwords is a
/// separate, audited security flow rather than an ordinary profile edit.
class AdminCustomerDraft {
  const AdminCustomerDraft({
    required this.name,
    required this.email,
    required this.phone,
    this.password,
  });

  final String name;
  final String email;
  final String phone;
  final String? password;

  Map<String, dynamic> toJson({required bool isNew}) => {
    'name': name,
    'email': email,
    'phone': phone.isEmpty ? null : phone,
    if (isNew) 'password': password,
  };
}

class AdminCustomersPageData {
  const AdminCustomersPageData({
    required this.items,
    required this.page,
    required this.pages,
    required this.total,
  });
  final List<AdminCustomer> items;
  final int page;
  final int pages;
  final int total;
  factory AdminCustomersPageData.fromJson(Map<String, dynamic> j) =>
      AdminCustomersPageData(
        items: _list(j['items']).map(AdminCustomer.fromJson).toList(),
        page: _int(j['pageNumber'], 1),
        pages: _int(j['totalPages'], 1),
        total: _int(j['totalCount'] ?? j['totalItems']),
      );
}

class AdminCustomersRepository {
  const AdminCustomersRepository(this._dio);
  final Dio _dio;
  Future<AdminCustomersPageData> fetch({
    required int page,
    required String search,
  }) async {
    final r = await _dio.post<dynamic>(
      '/api/User/get-all-users',
      data: {'pageNumber': page, 'pageSize': 20, 'search': search},
    );
    return AdminCustomersPageData.fromJson(_map(_map(r.data)['data']));
  }

  Future<void> setStatus(AdminCustomer customer, bool active) =>
      _dio.get<dynamic>(
        '/api/User/${active ? 'Active-user' : 'block-user'}',
        queryParameters: {'id': customer.id},
      );

  Future<AdminCustomer> fetchById(int id) async {
    final response = await _dio.get<dynamic>(
      '/api/User/get-user-by-id',
      queryParameters: {'id': id},
    );
    return AdminCustomer.fromJson(_map(_map(response.data)['data']));
  }

  Future<void> create(AdminCustomerDraft draft) => _dio.post<dynamic>(
    '/api/User/create-user',
    data: draft.toJson(isNew: true),
  );

  Future<void> update(int id, AdminCustomerDraft draft) => _dio.put<dynamic>(
    '/api/User/update-user-by-id',
    queryParameters: {'id': id},
    data: draft.toJson(isNew: false),
  );

  Future<void> delete(int id) => _dio.delete<dynamic>(
    '/api/User/delete-user',
    queryParameters: {'id': id},
  );
}

final adminCustomersRepositoryProvider = Provider<AdminCustomersRepository>(
  (ref) => AdminCustomersRepository(ref.watch(dioProvider)),
);
Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : const {};
List<Map<String, dynamic>> _list(dynamic v) => v is List
    ? v.whereType<Map>().map((x) => Map<String, dynamic>.from(x)).toList()
    : const [];
int _int(dynamic v, [int fallback = 0]) =>
    v is int ? v : int.tryParse('$v') ?? fallback;

String _role(dynamic value) => switch (value) {
  0 => 'عميل',
  1 => 'مدير',
  _ => '${value ?? 'عميل'}',
};
