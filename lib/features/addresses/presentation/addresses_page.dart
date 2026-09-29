import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/app_page_components.dart';
import '../../../core/models/delivery_address.dart';
import '../../auth/application/auth_controller.dart';
import '../application/addresses_controller.dart';
import 'location_picker_sheet.dart';

class AddressesPage extends ConsumerWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppCopy.of(context);
    if (!ref.watch(authControllerProvider).isSignedIn) {
      return Scaffold(
        appBar: AppBar(
          title: Text(copy.pair('عناوين التوصيل', 'Delivery addresses')),
        ),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/account'),
            child: Text(
              copy.pair(
                'سجّل الدخول لإدارة عناوينك',
                'Sign in to manage your addresses',
              ),
            ),
          ),
        ),
      );
    }
    final state = ref.watch(addressesControllerProvider);
    final controller = ref.read(addressesControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(copy.pair('عناوين التوصيل', 'Delivery addresses')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isSaving
            ? null
            : () => _showAddressForm(context, controller),
        icon: const Icon(Icons.add),
        label: Text(copy.pair('إضافة عنوان', 'Add address')),
      ),
      body: state.isLoading
          ? const SkeletonPage()
          : RefreshIndicator(
              onRefresh: controller.load,
              child: state.items.isEmpty
                  ? const _EmptyAddresses()
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 92),
                      children: [
                        AppPageHeader(
                          title: copy.pair(
                            'عناوين التوصيل',
                            'Delivery addresses',
                          ),
                          subtitle: copy.pair(
                            'أضف عنوانك لتجربة توصيل أسرع.',
                            'Add an address for a faster delivery experience.',
                          ),
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 20),
                        if (state.errorMessage case final message?)
                          _ErrorBanner(message: message),
                        for (final address in state.items) ...[
                          _AddressCard(
                            address: address,
                            busy: state.isSaving,
                            onEdit: () => _showAddressForm(
                              context,
                              controller,
                              existing: address,
                            ),
                            onMakePrimary: () =>
                                controller.setPrimary(address.id),
                            onDelete: () =>
                                _confirmDelete(context, controller, address),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
            ),
    );
  }

  Future<void> _showAddressForm(
    BuildContext context,
    AddressesController controller, {
    DeliveryAddress? existing,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AddressForm(controller: controller, existing: existing),
  );

  Future<void> _confirmDelete(
    BuildContext context,
    AddressesController controller,
    DeliveryAddress address,
  ) async {
    final copy = AppCopy.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(copy.pair('حذف العنوان؟', 'Delete address?')),
        content: Text(
          copy.pair(
            'سيُحذف عنوان «${address.title}» من حسابك.',
            '“${address.title}” will be removed from your account.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(copy.pair('إلغاء', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(copy.pair('حذف', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.delete(address.id);
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.busy,
    required this.onEdit,
    required this.onMakePrimary,
    required this.onDelete,
  });
  final DeliveryAddress address;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onMakePrimary;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  address.isPrimary ? Icons.home : Icons.location_on_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    address.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (address.isPrimary)
                  Chip(label: Text(copy.pair('افتراضي', 'Primary'))),
              ],
            ),
            const SizedBox(height: 8),
            Text('${address.street}، ${address.city}، ${address.country}'),
            if (address.latitude != null && address.longitude != null) ...[
              const SizedBox(height: 4),
              Text(
                copy.pair('الموقع محفوظ على الخريطة', 'Location saved on map'),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: [
                TextButton(
                  onPressed: busy ? null : onEdit,
                  child: Text(copy.pair('تعديل', 'Edit')),
                ),
                if (!address.isPrimary)
                  TextButton(
                    onPressed: busy ? null : onMakePrimary,
                    child: Text(copy.pair('تعيين افتراضي', 'Make primary')),
                  ),
                TextButton(
                  onPressed: busy ? null : onDelete,
                  child: Text(copy.pair('حذف', 'Delete')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressForm extends ConsumerStatefulWidget {
  const _AddressForm({required this.controller, this.existing});
  final AddressesController controller;
  final DeliveryAddress? existing;

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  final _key = GlobalKey<FormState>();
  late final _title = TextEditingController(
    text: widget.existing?.title ?? 'المنزل',
  );
  late final _street = TextEditingController(text: widget.existing?.street);
  late final _city = TextEditingController(text: widget.existing?.city);
  late final _country = TextEditingController(
    text: widget.existing?.country ?? 'Saudi Arabia',
  );
  late final _nationalAddressShortCode = TextEditingController(
    text: widget.existing?.nationalAddressShortCode,
  );
  late bool _primary = widget.existing?.isPrimary ?? false;
  late double? _latitude = widget.existing?.latitude;
  late double? _longitude = widget.existing?.longitude;

  bool get _isSaudiAddress =>
      widget.existing?.countryCode?.toUpperCase() == 'SA' ||
      _isSaudiCountry(_country.text);

  @override
  void dispose() {
    _title.dispose();
    _street.dispose();
    _city.dispose();
    _country.dispose();
    _nationalAddressShortCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final saving = ref.watch(addressesControllerProvider).isSaving;
    final error = ref.watch(addressesControllerProvider).errorMessage;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null
                    ? copy.pair('إضافة عنوان', 'Add address')
                    : copy.pair('تعديل العنوان', 'Edit address'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (error case final message?) _ErrorBanner(message: message),
              _field(_title, copy.pair('اسم العنوان', 'Address name')),
              const SizedBox(height: 10),
              _field(
                _street,
                copy.pair(
                  'الشارع والعنوان التفصيلي',
                  'Street and address details',
                ),
              ),
              const SizedBox(height: 10),
              _field(_city, copy.pair('المدينة', 'City')),
              const SizedBox(height: 10),
              _field(
                _country,
                copy.pair('الدولة', 'Country'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              LocationPickerButton(
                latitude: _latitude,
                longitude: _longitude,
                onChanged: (location) => setState(() {
                  _latitude = location.latitude;
                  _longitude = location.longitude;
                }),
              ),
              if (_latitude == null || _longitude == null)
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    copy.pair(
                      'تحديد الموقع على الخريطة مطلوب لاحتساب الشحن بدقة.',
                      'A map location is required to calculate shipping accurately.',
                    ),
                  ),
                ),
              if (_isSaudiAddress) ...[
                const SizedBox(height: 10),
                _field(
                  _nationalAddressShortCode,
                  copy.pair('العنوان الوطني المختصر', 'National short address'),
                  hintText: copy.pair('مثال: RFFA7218', 'Example: RFFA7218'),
                  validator: (value) =>
                      _validateNationalAddressShortCode(value, copy: copy),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    copy.pair(
                      'أدخله كما يظهر في سبل؛ وهو مطلوب للعناوين داخل السعودية.',
                      'Enter it exactly as shown in SPL; it is required for Saudi addresses.',
                    ),
                  ),
                ),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(copy.pair('العنوان الافتراضي', 'Primary address')),
                value: _primary,
                onChanged: saving
                    ? null
                    : (value) => setState(() => _primary = value),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: saving ? null : _save,
                child: Text(
                  saving
                      ? copy.pair('جارٍ الحفظ...', 'Saving...')
                      : copy.pair('حفظ العنوان', 'Save address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final copy = AppCopy.of(context);
    if (!(_key.currentState?.validate() ?? false)) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.pair(
              'حدد موقع التوصيل على الخريطة أولًا.',
              'Select the delivery point on the map first.',
            ),
          ),
        ),
      );
      return;
    }
    final success = await widget.controller.save(
      existing: widget.existing,
      title: _title.text.trim(),
      street: _street.text.trim(),
      city: _city.text.trim(),
      country: _country.text.trim(),
      countryCode: _isSaudiCountry(_country.text) ? 'SA' : null,
      nationalAddressShortCode: _isSaudiAddress
          ? _nationalAddressShortCode.text.trim()
          : null,
      latitude: _latitude!,
      longitude: _longitude!,
      isPrimary: _primary,
    );
    if (success && mounted) Navigator.pop(context);
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hintText,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) => TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label, hintText: hintText),
    onChanged: onChanged,
    validator:
        validator ??
        (value) => value?.trim().isNotEmpty == true
            ? null
            : AppCopy.of(
                context,
              ).pair('هذا الحقل مطلوب', 'This field is required'),
  );
}

bool _isSaudiCountry(String country) {
  switch (country.trim().toLowerCase()) {
    case 'saudi arabia':
    case 'kingdom of saudi arabia':
    case 'السعودية':
    case 'المملكة العربية السعودية':
      return true;
    default:
      return false;
  }
}

String? _validateNationalAddressShortCode(
  String? value, {
  required AppCopy copy,
}) {
  final normalized = (value ?? '').replaceAll(RegExp(r'\s+'), '').toUpperCase();
  return RegExp(r'^[A-Z]{4}\d{4}$').hasMatch(normalized)
      ? null
      : copy.pair(
          'أدخل 4 أحرف إنجليزية ثم 4 أرقام، مثل RFFA7218',
          'Enter 4 English letters then 4 digits, e.g. RFFA7218',
        );
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses();
  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return AppEmptyState(
      icon: Icons.location_off_outlined,
      title: copy.pair('لا توجد عناوين محفوظة', 'No saved addresses'),
      message: copy.pair(
        'أضف عنوان التوصيل الذي تفضله للبدء.',
        'Add your preferred delivery address to get started.',
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AppFeedbackBanner(message: message, tone: AppBannerTone.error),
  );
}
