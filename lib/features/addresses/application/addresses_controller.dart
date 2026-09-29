import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/delivery_address.dart';
import '../data/addresses_repository.dart';

class AddressesState {
  const AddressesState({
    this.isLoading = true,
    this.isSaving = false,
    this.items = const [],
    this.errorMessage,
  });
  final bool isLoading;
  final bool isSaving;
  final List<DeliveryAddress> items;
  final String? errorMessage;

  AddressesState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<DeliveryAddress>? items,
    String? errorMessage,
  }) => AddressesState(
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    items: items ?? this.items,
    errorMessage: errorMessage,
  );
}

final addressesControllerProvider =
    StateNotifierProvider.autoDispose<AddressesController, AddressesState>(
      (ref) => AddressesController(ref.watch(addressesRepositoryProvider)),
    );

class AddressesController extends StateNotifier<AddressesState> {
  AddressesController(this._repository) : super(const AddressesState()) {
    load();
  }
  final AddressesRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      state = AddressesState(
        isLoading: false,
        items: await _repository.fetchMine(),
      );
    } on DioException {
      state = const AddressesState(
        isLoading: false,
        errorMessage: 'تعذر تحميل العناوين. تحقق من الاتصال ثم أعد المحاولة.',
      );
    }
  }

  Future<bool> save({
    DeliveryAddress? existing,
    required String title,
    required String street,
    required String city,
    required String country,
    required String? countryCode,
    required String? nationalAddressShortCode,
    required double latitude,
    required double longitude,
    required bool isPrimary,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      if (existing == null) {
        await _repository.create(
          title: title,
          street: street,
          city: city,
          country: country,
          countryCode: countryCode,
          nationalAddressShortCode: nationalAddressShortCode,
          latitude: latitude,
          longitude: longitude,
          isPrimary: isPrimary,
        );
      } else {
        await _repository.update(
          address: existing,
          title: title,
          street: street,
          city: city,
          country: country,
          countryCode: countryCode,
          nationalAddressShortCode: nationalAddressShortCode,
          latitude: latitude,
          longitude: longitude,
          isPrimary: isPrimary,
        );
      }
      await load();
      return true;
    } on AddressException catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.message);
      return false;
    } on DioException {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'تعذر حفظ العنوان. حاول مرة أخرى.',
      );
      return false;
    }
  }

  Future<void> setPrimary(int id) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.setPrimary(id);
      await load();
    } on DioException {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'تعذر تعيين العنوان الافتراضي.',
      );
    }
  }

  Future<void> delete(int id) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.delete(id);
      await load();
    } on DioException {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'تعذر حذف العنوان.',
      );
    }
  }
}
