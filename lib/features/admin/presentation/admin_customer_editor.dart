import 'package:flutter/material.dart';

import '../data/admin_customers_repository.dart';

/// A single responsive editor used by both the list (create) and profile
/// screen (edit), so the API contract and validation stay consistent.
Future<AdminCustomerDraft?> showAdminCustomerEditor(
  BuildContext context, {
  AdminCustomer? customer,
}) => showDialog<AdminCustomerDraft>(
  context: context,
  builder: (_) => _AdminCustomerEditor(customer: customer),
);

class _AdminCustomerEditor extends StatefulWidget {
  const _AdminCustomerEditor({this.customer});
  final AdminCustomer? customer;
  @override
  State<_AdminCustomerEditor> createState() => _AdminCustomerEditorState();
}

class _AdminCustomerEditorState extends State<_AdminCustomerEditor> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController email;
  late final TextEditingController phone;
  late final TextEditingController password;

  bool get isNew => widget.customer == null;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    name = TextEditingController(text: customer?.name ?? '');
    email = TextEditingController(text: customer?.email ?? '');
    phone = TextEditingController(text: customer?.phone ?? '');
    password = TextEditingController();
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(isNew ? 'إضافة عميل' : 'تعديل بيانات العميل'),
    content: SizedBox(
      width: 440,
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'اسم العميل',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => (value?.trim().length ?? 0) < 2
                    ? 'أدخل اسمًا صحيحًا.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: (value) => (value?.contains('@') ?? false)
                    ? null
                    : 'أدخل بريدًا إلكترونيًا صحيحًا.',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف (اختياري)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              if (isNew) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  textDirection: TextDirection.ltr,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور المؤقتة',
                    helperText: 'يُفضّل أن يغيّرها العميل بعد أول دخول.',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) => (value?.trim().length ?? 0) < 8
                      ? 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.'
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton.icon(
        onPressed: _submit,
        icon: Icon(isNew ? Icons.person_add_alt_1 : Icons.save_outlined),
        label: Text(isNew ? 'إنشاء العميل' : 'حفظ التعديلات'),
      ),
    ],
  );

  void _submit() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      AdminCustomerDraft(
        name: name.text.trim(),
        email: email.text.trim(),
        phone: phone.text.trim(),
        password: isNew ? password.text : null,
      ),
    );
  }
}
