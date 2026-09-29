import 'package:dio/dio.dart';

import '../../../core/models/delivery_address.dart';
import '../../../core/state/cart_controller.dart';

class PaymentGateway {
  const PaymentGateway({
    required this.nameAr,
    required this.nameEn,
    required this.paymentGateway,
    required this.paymentName,
  });

  final String nameAr;
  final String nameEn;
  final String paymentGateway;
  final String paymentName;

  factory PaymentGateway.fromJson(Map<String, dynamic> json) => PaymentGateway(
    nameAr: json['name_ar']?.toString() ?? '',
    nameEn: json['name_en']?.toString() ?? '',
    paymentGateway: json['paymentGetway']?.toString() ?? '',
    paymentName: json['paymentName']?.toString() ?? '',
  );
}

class ShippingOption {
  const ShippingOption({
    required this.carrier,
    required this.price,
    required this.estimatedDelivery,
    this.isFreeShipping = false,
    this.customerNotice,
  });

  final String carrier;
  final double price;
  final String estimatedDelivery;
  final bool isFreeShipping;
  final String? customerNotice;

  factory ShippingOption.fromJson(Map<String, dynamic> json) => ShippingOption(
    carrier: json['carrier']?.toString() ?? '',
    price: _asDouble(json['price']),
    estimatedDelivery: json['estimatedDelivery']?.toString() ?? '',
    isFreeShipping: json['isFreeShipping'] == true,
    customerNotice: json['customerNotice']?.toString(),
  );
}

class CustomerProfile {
  const CustomerProfile({required this.name, required this.email, this.phone});
  final String name;
  final String email;
  final String? phone;

  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      CustomerProfile(
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
      );
}

class CheckoutCoupon {
  const CheckoutCoupon({
    required this.code,
    required this.discount,
    required this.isPercentage,
    required this.expiryDate,
  });

  final String code;
  final double discount;
  final bool isPercentage;
  final DateTime expiryDate;

  factory CheckoutCoupon.fromJson(Map<String, dynamic> json) => CheckoutCoupon(
    code: json['code']?.toString() ?? '',
    discount: _asDouble(json['discount']),
    isPercentage: json['isPercentage'] == true,
    expiryDate:
        DateTime.tryParse(json['expiryDate']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );

  bool get isExpired => expiryDate.isBefore(DateTime.now());

  double discountFor(double merchandiseSubtotal) {
    final calculated = isPercentage
        ? merchandiseSubtotal * discount / 100
        : discount;
    return calculated.clamp(0, merchandiseSubtotal).toDouble();
  }
}

class CreatedOrder {
  const CreatedOrder({
    required this.orderId,
    this.invoiceId,
    this.paymentType,
    this.invoiceUrl,
  });
  final int orderId;
  final String? invoiceId;
  final String? paymentType;
  final String? invoiceUrl;
}

class CheckoutRepository {
  const CheckoutRepository(this._dio);
  final Dio _dio;

  Future<List<DeliveryAddress>> addresses() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/Address/get-address-by-user-id',
    );
    return _list(_data(response.data)).map(DeliveryAddress.fromJson).toList();
  }

  Future<DeliveryAddress> createAddress({
    required String title,
    required String street,
    required String city,
    required String country,
    String? countryCode,
    String? nationalAddressShortCode,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/Address/create-address',
      data: {
        'title': title,
        'street': street,
        'city': city,
        'country': country,
        'countryCode': countryCode,
        'nationalAddressShortCode': nationalAddressShortCode,
        'latitude': latitude,
        'longitude': longitude,
        'isPrimary': true,
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    if (body['isSuccess'] != true && body['success'] != true) {
      throw CheckoutException(
        body['message']?.toString() ?? 'تعذر حفظ العنوان.',
      );
    }
    return DeliveryAddress.fromJson(_map(_data(body)));
  }

  Future<List<PaymentGateway>> paymentGateways() async {
    final response = await _dio.get<dynamic>('/api/PaymentGateway/list');
    return _list(response.data).map(PaymentGateway.fromJson).toList();
  }

  Future<CheckoutCoupon> validateCoupon(String code) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/coupon/get-coupon-by-code',
      queryParameters: {'code': code.trim()},
    );
    final body = response.data ?? const <String, dynamic>{};
    if (body['isSuccess'] != true && body['success'] != true) {
      throw CheckoutException(
        body['message']?.toString() ?? 'رمز الخصم غير صالح.',
      );
    }
    final coupon = CheckoutCoupon.fromJson(_map(_data(body)));
    if (coupon.code.isEmpty || coupon.discount <= 0 || coupon.isExpired) {
      throw const CheckoutException('رمز الخصم غير صالح أو منتهي الصلاحية.');
    }
    return coupon;
  }

  Future<CustomerProfile> profile() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/User/user-profile',
    );
    return CustomerProfile.fromJson(_map(_data(response.data)));
  }

  Future<List<ShippingOption>> shippingOptions({
    required int addressId,
    required double amount,
    required double weightKg,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/shipping-options',
      data: {
        'addressId': addressId,
        'amount': amount,
        'weight': {'unit': 'KG', 'value': weightKg <= 0 ? 0.1 : weightKg},
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    if (body['isSuccess'] != true && body['success'] != true) {
      throw CheckoutException(
        body['message']?.toString() ?? 'تعذر احتساب تكلفة الشحن.',
      );
    }
    return _list(_data(body)).map(ShippingOption.fromJson).toList();
  }

  Future<CreatedOrder> createOrder({
    required CartController cart,
    required DeliveryAddress address,
    required ShippingOption shipping,
    required PaymentGateway gateway,
    required CustomerProfile profile,
    required String phoneNumber,
    CheckoutCoupon? coupon,
  }) async {
    final totalWeight = cart.totalWeightKg <= 0 ? 0.1 : cart.totalWeightKg;
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/order/create-order',
      data: {
        'totalPrice':
            cart.subtotal -
            (coupon?.discountFor(cart.subtotal) ?? 0) +
            shipping.price,
        'paymentMethod': gateway.paymentName,
        'paymentType': gateway.paymentGateway,
        'mainPrice': cart.subtotal,
        'couponCode': coupon?.code ?? '',
        'isHasCoupon': coupon != null,
        'address': address.id.toString(),
        'phoneNumber': phoneNumber,
        'shippingCompany': shipping.carrier,
        'customerName': profile.name,
        'customerEmail': profile.email,
        'customerMobile': phoneNumber,
        'language': 'Ar',
        'items': [
          for (final product in cart.products)
            {
              'productId': _asInt(product.id),
              if (product.selectedVariantId != null)
                'productVariantId': product.selectedVariantId,
              'quantity': cart.quantityFor(product),
              'price': product.salePrice,
            },
        ],
        'rateCalculatorRequest': {
          'addressId': address.id,
          'amount': cart.subtotal,
          'country': address.country,
          'destinationAddress': {
            'line1': address.street,
            'city': address.city,
            'latitude': address.latitude ?? 0,
            'longitude': address.longitude ?? 0,
            'countryCode':
                address.countryCode ??
                _shippingCountryCode(address.country) ??
                '',
          },
          'weight': {'unit': 'KG', 'value': totalWeight},
        },
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    if (body['isSuccess'] != true && body['success'] != true) {
      throw CheckoutException(
        body['message']?.toString() ?? 'تعذر إنشاء الطلب.',
      );
    }
    final data = _map(_data(body));
    return CreatedOrder(
      orderId: _asInt(data['orderId']),
      invoiceId: data['invoiceId']?.toString(),
      paymentType: data['paymentType']?.toString(),
      invoiceUrl: data['invoiceURL']?.toString(),
    );
  }
}

class CheckoutException implements Exception {
  const CheckoutException(this.message);
  final String message;
  @override
  String toString() => message;
}

String? _shippingCountryCode(String country) {
  switch (country.trim().toLowerCase()) {
    case 'sa':
    case 'sau':
    case 'saudi arabia':
    case 'kingdom of saudi arabia':
    case 'المملكة العربية السعودية':
    case 'السعودية':
      return 'SA';
    case 'ae':
    case 'are':
    case 'united arab emirates':
    case 'uae':
    case 'الإمارات العربية المتحدة':
    case 'الامارات العربية المتحدة':
      return 'AE';
    case 'kw':
    case 'kwt':
    case 'kuwait':
    case 'الكويت':
      return 'KW';
    case 'om':
    case 'omn':
    case 'oman':
    case 'عمان':
    case 'سلطنة عمان':
      return 'OM';
    case 'qa':
    case 'qat':
    case 'qatar':
    case 'قطر':
      return 'QA';
    case 'bh':
    case 'bhr':
    case 'bahrain':
    case 'البحرين':
      return 'BH';
    default:
      return null;
  }
}

dynamic _data(Map<String, dynamic>? body) => body?['data'];
Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};
List<Map<String, dynamic>> _list(dynamic value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
    : const [];
int _asInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
double _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
