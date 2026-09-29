import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/app_page_components.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/models/delivery_address.dart';
import '../../../core/state/cart_controller.dart';
import '../../auth/application/auth_controller.dart';
import '../../payment/data/payment_status_repository.dart';
import '../../addresses/presentation/location_picker_sheet.dart';
import '../application/checkout_controller.dart';
import '../data/checkout_repository.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key, required this.cart, required this.onBack});
  final CartController cart;
  final VoidCallback onBack;

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _phone = TextEditingController();
  final _coupon = TextEditingController();
  bool _seededPhone = false;

  @override
  void dispose() {
    _phone.dispose();
    _coupon.dispose();
    super.dispose();
  }

  Future<void> _submit(CheckoutController controller) async {
    final copy = AppCopy.of(context);
    if (_phone.text.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.pair(
              'أدخل رقم جوال صحيح لإتمام الشحن.',
              'Enter a valid mobile number to continue shipping.',
            ),
          ),
        ),
      );
      return;
    }
    final order = await controller.submit(_phone.text.trim());
    if (!mounted || order == null) return;
    await ref.read(paymentStatusRepositoryProvider).saveCreatedOrder(order);
    await widget.cart.clear();
    if (!mounted) return;
    final invoiceId = order.invoiceId;
    if (invoiceId != null && invoiceId.isNotEmpty) {
      context.go('/payment-status/${Uri.encodeComponent(invoiceId)}');
    }
    final url = order.invoiceUrl;
    if (url != null && url.isNotEmpty) {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              copy.pair(
                'تعذر فتح بوابة الدفع. يمكنك المحاولة من شاشة المتابعة.',
                'Could not open the payment gateway. Try again from order tracking.',
              ),
            ),
          ),
        );
      }
    } else {
      _showOrderCreated(order.orderId, null);
    }
  }

  void _showOrderCreated(int orderId, String? invoiceUrl) {
    final copy = AppCopy.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(copy.pair('تم إنشاء الطلب', 'Order created')),
        content: Text(
          invoiceUrl == null
              ? copy.pair(
                  'رقم طلبك #$orderId. سنرسل لك تحديثات حالة الطلب.',
                  'Your order is #$orderId. We will send you order updates.',
                )
              : copy.pair(
                  'رقم طلبك #$orderId. افتح رابط الدفع الظاهر أدناه لإتمامه:\n$invoiceUrl',
                  'Your order is #$orderId. Open the payment link below to complete it:\n$invoiceUrl',
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onBack();
            },
            child: Text(copy.pair('العودة للسلة', 'Back to cart')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final auth = ref.watch(authControllerProvider);
    if (!auth.isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(copy.pair('إتمام الطلب', 'Checkout'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 58),
                const SizedBox(height: 16),
                Text(
                  copy.pair(
                    'سجّل الدخول قبل إتمام الطلب',
                    'Sign in before checkout',
                  ),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.go('/account'),
                  child: Text(copy.pair('تسجيل الدخول', 'Sign in')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final state = ref.watch(checkoutControllerProvider(widget.cart));
    final controller = ref.read(
      checkoutControllerProvider(widget.cart).notifier,
    );
    if (!_seededPhone && state.profile?.phone?.isNotEmpty == true) {
      _seededPhone = true;
      _phone.text = state.profile!.phone!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(copy.pair('إتمام الطلب', 'Checkout')),
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: state.isLoading
          ? const SkeletonPage(layout: SkeletonLayout.form)
          : RefreshIndicator(
              onRefresh: controller.load,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final summary = _OrderSummary(
                    cart: widget.cart,
                    state: state,
                  );
                  final details = _CheckoutDetails(
                    state: state,
                    phone: _phone,
                    onAddressChanged: controller.selectAddress,
                    onGatewayChanged: controller.selectGateway,
                    onShippingChanged: controller.selectShipping,
                    coupon: _coupon,
                    onApplyCoupon: controller.applyCoupon,
                    onRemoveCoupon: controller.removeCoupon,
                    onAddAddress: () => _showAddressSheet(controller),
                    onSubmit: () => _submit(controller),
                  );
                  if (constraints.maxWidth >= 900) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1180),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: details),
                              const SizedBox(width: 24),
                              SizedBox(width: 360, child: summary),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(18),
                    children: [details, const SizedBox(height: 18), summary],
                  );
                },
              ),
            ),
    );
  }

  Future<void> _showAddressSheet(CheckoutController controller) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddressForm(
        onSave:
            (
              title,
              street,
              city,
              country,
              nationalAddressShortCode,
              latitude,
              longitude,
            ) async {
              final address = await controller.addAddress(
                title: title,
                street: street,
                city: city,
                country: country,
                nationalAddressShortCode: nationalAddressShortCode,
                latitude: latitude,
                longitude: longitude,
              );
              if (address != null && context.mounted) {
                Navigator.of(context).pop();
              }
            },
      ),
    );
  }
}

class _CheckoutDetails extends StatelessWidget {
  const _CheckoutDetails({
    required this.state,
    required this.phone,
    required this.onAddressChanged,
    required this.onGatewayChanged,
    required this.onShippingChanged,
    required this.coupon,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
    required this.onAddAddress,
    required this.onSubmit,
  });

  final CheckoutState state;
  final TextEditingController phone;
  final ValueChanged<DeliveryAddress> onAddressChanged;
  final ValueChanged<PaymentGateway> onGatewayChanged;
  final ValueChanged<ShippingOption> onShippingChanged;
  final TextEditingController coupon;
  final Future<void> Function(String) onApplyCoupon;
  final Future<void> Function() onRemoveCoupon;
  final VoidCallback onAddAddress;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPageHeader(
          title: copy.pair('إتمام الطلب', 'Checkout'),
          subtitle: copy.pair(
            'أكمل بياناتك ثم اختر الشحن وطريقة الدفع.',
            'Complete your details, then choose shipping and payment.',
          ),
          icon: Icons.shopping_bag_outlined,
        ),
        const SizedBox(height: 20),
        if (state.errorMessage case final message?)
          _Message(text: message, isError: true),
        _Section(
          title: copy.pair('عنوان التوصيل', 'Delivery address'),
          action: TextButton.icon(
            onPressed: onAddAddress,
            icon: const Icon(Icons.add),
            label: Text(copy.pair('إضافة عنوان', 'Add address')),
          ),
          child: state.addresses.isEmpty
              ? Text(
                  copy.pair(
                    'أضف عنوانًا حتى نتمكن من حساب الشحن.',
                    'Add an address so we can calculate shipping.',
                  ),
                )
              : Column(
                  children: [
                    for (final address in state.addresses)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => onAddressChanged(address),
                        leading: Icon(
                          state.selectedAddress?.id == address.id
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(address.title),
                        subtitle: Text('${address.street}، ${address.city}'),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        _Section(
          title: copy.pair('رمز الخصم', 'Discount code'),
          child: state.coupon != null
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        copy.pair(
                          'تم تطبيق ${state.coupon!.code} بنجاح',
                          '${state.coupon!.code} was applied successfully',
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onRemoveCoupon,
                      child: Text(copy.pair('إزالة', 'Remove')),
                    ),
                  ],
                )
              : TextField(
                  controller: coupon,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: copy.pair(
                      'أدخل رمز الخصم',
                      'Enter discount code',
                    ),
                    suffixIcon: TextButton(
                      onPressed: state.isApplyingCoupon
                          ? null
                          : () => onApplyCoupon(coupon.text),
                      child: state.isApplyingCoupon
                          ? const SkeletonInline()
                          : Text(copy.pair('تطبيق', 'Apply')),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        _Section(
          title: copy.pair('شركة الشحن', 'Shipping'),
          child: state.selectedAddress == null
              ? Text(
                  copy.pair(
                    'اختر عنوان التوصيل أولًا.',
                    'Choose a delivery address first.',
                  ),
                )
              : state.shippingOptions.isEmpty
              ? Text(
                  copy.pair(
                    'لا توجد خيارات شحن متاحة لهذا العنوان حاليًا.',
                    'No shipping options are currently available for this address.',
                  ),
                )
              : Column(
                  children: [
                    for (final option in state.shippingOptions)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => onShippingChanged(option),
                        leading: Icon(
                          state.selectedShipping?.carrier == option.carrier
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(option.carrier),
                        subtitle: Text(
                          '${option.price.toStringAsFixed(0)} ر.س${option.estimatedDelivery.isEmpty ? '' : ' · ${option.estimatedDelivery}'}',
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        _Section(
          title: copy.pair('طريقة الدفع', 'Payment method'),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final gateway in state.gateways)
                ChoiceChip(
                  label: Text(
                    copy.isEnglish || gateway.nameAr.isEmpty
                        ? gateway.nameEn
                        : gateway.nameAr,
                  ),
                  selected:
                      state.selectedGateway?.paymentName == gateway.paymentName,
                  onSelected: (_) => onGatewayChanged(gateway),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          title: copy.pair('بيانات التواصل', 'Contact details'),
          child: TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: copy.pair('رقم الجوال', 'Mobile number'),
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: state.isProcessing ? null : onSubmit,
          icon: state.isProcessing
              ? const SkeletonInline()
              : const Icon(Icons.lock_outline),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Text(
              state.isProcessing
                  ? copy.pair('جارٍ إنشاء الطلب...', 'Creating your order...')
                  : copy.pair(
                      'إنشاء الطلب والانتقال للدفع',
                      'Create order & pay',
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.cart, required this.state});
  final CartController cart;
  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final shipping = state.selectedShipping?.price ?? 0;
    final discount = state.coupon?.discountFor(cart.subtotal) ?? 0;
    return _Section(
      title: copy.pair('ملخص الطلب', 'Order summary'),
      child: Column(
        children: [
          for (final product in cart.products)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                copy.isEnglish || product.nameAr.isEmpty
                    ? product.nameEn
                    : product.nameAr,
              ),
              subtitle: Text(
                copy.pair(
                  '${cart.quantityFor(product)} قطعة',
                  '${cart.quantityFor(product)} item${cart.quantityFor(product) == 1 ? '' : 's'}',
                ),
              ),
              trailing: Text(
                '${(product.salePrice * cart.quantityFor(product)).toStringAsFixed(0)} ر.س',
              ),
            ),
          const Divider(),
          _TotalRow(
            label: copy.pair('المنتجات', 'Products'),
            value: cart.subtotal,
          ),
          if (discount > 0)
            _TotalRow(
              label: copy.pair(
                'خصم ${state.coupon!.code}',
                '${state.coupon!.code} discount',
              ),
              value: -discount,
            ),
          _TotalRow(label: copy.pair('الشحن', 'Shipping'), value: shipping),
          const Divider(),
          _TotalRow(
            label: copy.total,
            value: cart.subtotal - discount + shipping,
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  final String label;
  final double value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: emphasized ? const TextStyle(fontWeight: FontWeight.w700) : null,
      ),
      const Spacer(),
      Text(
        '${value.toStringAsFixed(0)} ر.س',
        style: emphasized
            ? const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)
            : null,
      ),
    ],
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.action});
  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) =>
      AppSectionCard(title: title, action: action, child: child);
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.isError});
  final String text;
  final bool isError;
  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _Section(
        title: isError
            ? copy.pair('تعذر المتابعة', 'Could not continue')
            : copy.pair('معلومة', 'Information'),
        child: Text(text),
      ),
    );
  }
}

class _AddressForm extends StatefulWidget {
  const _AddressForm({required this.onSave});
  final Future<void> Function(
    String title,
    String street,
    String city,
    String country,
    String? nationalAddressShortCode,
    double latitude,
    double longitude,
  )
  onSave;

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController(text: 'المنزل');
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController(text: 'Saudi Arabia');
  final _nationalAddressShortCode = TextEditingController();
  double? _latitude;
  double? _longitude;
  var _saving = false;

  bool get _isSaudiAddress => _isSaudiCountry(_country.text);

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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                copy.pair('إضافة عنوان', 'Add address'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _input(_title, copy.pair('اسم العنوان', 'Address name')),
              const SizedBox(height: 10),
              _input(
                _street,
                copy.pair(
                  'الشارع والعنوان التفصيلي',
                  'Street and address details',
                ),
              ),
              const SizedBox(height: 10),
              _input(_city, copy.pair('المدينة', 'City')),
              const SizedBox(height: 10),
              _input(
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
              if (_isSaudiAddress) ...[
                const SizedBox(height: 10),
                _input(
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
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _saving
                    ? null
                    : () async {
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
                        setState(() => _saving = true);
                        await widget.onSave(
                          _title.text.trim(),
                          _street.text.trim(),
                          _city.text.trim(),
                          _country.text.trim(),
                          _isSaudiAddress
                              ? _nationalAddressShortCode.text.trim()
                              : null,
                          _latitude!,
                          _longitude!,
                        );
                        if (mounted) setState(() => _saving = false);
                      },
                child: Text(
                  _saving
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

  Widget _input(
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
