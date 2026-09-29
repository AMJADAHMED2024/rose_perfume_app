import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/delivery_address.dart';
import '../../../core/network/api_client.dart';
import '../../../core/state/cart_controller.dart';
import '../data/checkout_repository.dart';

class CheckoutState {
  const CheckoutState({
    this.isLoading = true,
    this.isProcessing = false,
    this.addresses = const [],
    this.gateways = const [],
    this.shippingOptions = const [],
    this.profile,
    this.selectedAddress,
    this.selectedGateway,
    this.selectedShipping,
    this.coupon,
    this.isApplyingCoupon = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isProcessing;
  final List<DeliveryAddress> addresses;
  final List<PaymentGateway> gateways;
  final List<ShippingOption> shippingOptions;
  final CustomerProfile? profile;
  final DeliveryAddress? selectedAddress;
  final PaymentGateway? selectedGateway;
  final ShippingOption? selectedShipping;
  final CheckoutCoupon? coupon;
  final bool isApplyingCoupon;
  final String? errorMessage;

  CheckoutState copyWith({
    bool? isLoading,
    bool? isProcessing,
    List<DeliveryAddress>? addresses,
    List<PaymentGateway>? gateways,
    List<ShippingOption>? shippingOptions,
    CustomerProfile? profile,
    DeliveryAddress? selectedAddress,
    PaymentGateway? selectedGateway,
    ShippingOption? selectedShipping,
    CheckoutCoupon? coupon,
    bool clearCoupon = false,
    bool? isApplyingCoupon,
    bool clearSelectedShipping = false,
    String? errorMessage,
  }) => CheckoutState(
    isLoading: isLoading ?? this.isLoading,
    isProcessing: isProcessing ?? this.isProcessing,
    addresses: addresses ?? this.addresses,
    gateways: gateways ?? this.gateways,
    shippingOptions: shippingOptions ?? this.shippingOptions,
    profile: profile ?? this.profile,
    selectedAddress: selectedAddress ?? this.selectedAddress,
    selectedGateway: selectedGateway ?? this.selectedGateway,
    selectedShipping: clearSelectedShipping
        ? null
        : selectedShipping ?? this.selectedShipping,
    coupon: clearCoupon ? null : coupon ?? this.coupon,
    isApplyingCoupon: isApplyingCoupon ?? this.isApplyingCoupon,
    errorMessage: errorMessage,
  );
}

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (ref) => CheckoutRepository(ref.watch(dioProvider)),
);

final checkoutControllerProvider = StateNotifierProvider.autoDispose
    .family<CheckoutController, CheckoutState, CartController>(
      (ref, cart) =>
          CheckoutController(ref.watch(checkoutRepositoryProvider), cart),
    );

class CheckoutController extends StateNotifier<CheckoutState> {
  CheckoutController(this._repository, this._cart)
    : super(const CheckoutState()) {
    load();
  }

  final CheckoutRepository _repository;
  final CartController _cart;

  Future<void> load() async {
    state = const CheckoutState();
    try {
      final results = await Future.wait([
        _repository.addresses(),
        _repository.paymentGateways(),
        _repository.profile(),
      ]);
      final addresses = results[0] as List<DeliveryAddress>;
      final gateways = results[1] as List<PaymentGateway>;
      state = CheckoutState(
        isLoading: false,
        addresses: addresses,
        gateways: gateways,
        profile: results[2] as CustomerProfile,
        selectedGateway: gateways.isEmpty ? null : gateways.first,
      );
      if (addresses.isNotEmpty) {
        await selectAddress(
          addresses.firstWhere(
            (address) => address.isPrimary,
            orElse: () => addresses.first,
          ),
        );
      }
    } on DioException catch (error) {
      state = CheckoutState(
        isLoading: false,
        errorMessage: error.response?.data is Map
            ? (error.response!.data as Map)['message']?.toString()
            : 'تعذر تحميل بيانات إتمام الطلب.',
      );
    } catch (_) {
      state = const CheckoutState(
        isLoading: false,
        errorMessage: 'تعذر تحميل بيانات إتمام الطلب.',
      );
    }
  }

  Future<void> selectAddress(DeliveryAddress address) async {
    state = state.copyWith(
      selectedAddress: address,
      shippingOptions: const [],
      clearSelectedShipping: true,
      errorMessage: null,
    );
    try {
      final options = await _repository.shippingOptions(
        addressId: address.id,
        amount: _discountedMerchandiseTotal,
        weightKg: _cart.totalWeightKg,
      );
      state = state.copyWith(
        shippingOptions: options,
        selectedShipping: options.isEmpty ? null : options.first,
      );
    } on CheckoutException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    } on DioException catch (error) {
      state = state.copyWith(
        errorMessage: error.response?.data is Map
            ? (error.response!.data as Map)['message']?.toString()
            : 'تعذر احتساب الشحن لهذا العنوان.',
      );
    }
  }

  void selectGateway(PaymentGateway gateway) =>
      state = state.copyWith(selectedGateway: gateway, errorMessage: null);

  void selectShipping(ShippingOption option) =>
      state = state.copyWith(selectedShipping: option, errorMessage: null);

  double get _discountedMerchandiseTotal =>
      _cart.subtotal - (state.coupon?.discountFor(_cart.subtotal) ?? 0);

  Future<void> applyCoupon(String value) async {
    final code = value.trim();
    if (code.isEmpty) {
      state = state.copyWith(errorMessage: 'أدخل رمز الخصم أولًا.');
      return;
    }
    state = state.copyWith(isApplyingCoupon: true, errorMessage: null);
    try {
      final coupon = await _repository.validateCoupon(code);
      state = state.copyWith(coupon: coupon, isApplyingCoupon: false);
      if (state.selectedAddress case final address?) {
        await selectAddress(address);
      }
    } on CheckoutException catch (error) {
      state = state.copyWith(
        isApplyingCoupon: false,
        errorMessage: error.message,
      );
    } on DioException catch (error) {
      state = state.copyWith(
        isApplyingCoupon: false,
        errorMessage: error.response?.data is Map
            ? (error.response!.data as Map)['message']?.toString()
            : 'تعذر التحقق من رمز الخصم. حاول لاحقًا.',
      );
    }
  }

  Future<void> removeCoupon() async {
    state = state.copyWith(clearCoupon: true, errorMessage: null);
    if (state.selectedAddress case final address?) {
      await selectAddress(address);
    }
  }

  Future<DeliveryAddress?> addAddress({
    required String title,
    required String street,
    required String city,
    required String country,
    String? nationalAddressShortCode,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final address = await _repository.createAddress(
        title: title,
        street: street,
        city: city,
        country: country,
        countryCode: _shippingCountryCode(country),
        nationalAddressShortCode: nationalAddressShortCode,
        latitude: latitude,
        longitude: longitude,
      );
      state = state.copyWith(addresses: [...state.addresses, address]);
      await selectAddress(address);
      return address;
    } on CheckoutException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return null;
    } on DioException {
      state = state.copyWith(errorMessage: 'تعذر حفظ العنوان. حاول مرة أخرى.');
      return null;
    }
  }

  Future<CreatedOrder?> submit(String phoneNumber) async {
    final address = state.selectedAddress;
    final shipping = state.selectedShipping;
    final gateway = state.selectedGateway;
    final profile = state.profile;
    if (address == null ||
        shipping == null ||
        gateway == null ||
        profile == null) {
      state = state.copyWith(
        errorMessage: 'أكمل العنوان والشحن وطريقة الدفع أولًا.',
      );
      return null;
    }
    state = state.copyWith(isProcessing: true, errorMessage: null);
    try {
      final order = await _repository.createOrder(
        cart: _cart,
        address: address,
        shipping: shipping,
        gateway: gateway,
        profile: profile,
        phoneNumber: phoneNumber,
        coupon: state.coupon,
      );
      state = state.copyWith(isProcessing: false);
      return order;
    } on CheckoutException catch (error) {
      state = state.copyWith(isProcessing: false, errorMessage: error.message);
      return null;
    } on DioException catch (error) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: error.response?.data is Map
            ? (error.response!.data as Map)['message']?.toString()
            : 'تعذر إنشاء الطلب. تحقق من الاتصال وحاول مرة أخرى.',
      );
      return null;
    }
  }
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
