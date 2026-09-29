import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/app_page_components.dart';
import '../../auth/application/auth_controller.dart';
import '../application/profile_controller.dart';
import '../data/profile_repository.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppCopy.of(context);
    if (!ref.watch(authControllerProvider).isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(copy.pair('الملف الشخصي', 'My profile'))),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/account'),
            child: Text(
              copy.pair(
                'سجّل الدخول لإدارة حسابك',
                'Sign in to manage your account',
              ),
            ),
          ),
        ),
      );
    }
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(copy.pair('الملف الشخصي', 'My profile'))),
      body: state.isLoading
          ? const SkeletonPage(layout: SkeletonLayout.form)
          : state.profile == null
          ? _LoadError(message: state.errorMessage, onRetry: controller.load)
          : _ProfileForm(
              profile: state.profile!,
              state: state,
              controller: controller,
            ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({
    required this.profile,
    required this.state,
    required this.controller,
  });
  final CustomerProfileData profile;
  final ProfileState state;
  final ProfileController controller;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _email = TextEditingController(text: widget.profile.email);
  late final _phone = TextEditingController(text: widget.profile.phone);
  late final _nationality = TextEditingController(
    text: widget.profile.nationality,
  );
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmNewPassword = TextEditingController();
  var _isChangingPassword = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _nationality.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmNewPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 32),
          children: [
            AppPageHeader(
              title: copy.pair('الملف الشخصي', 'My profile'),
              subtitle: copy.pair(
                'حدّث بياناتك لتجربة شراء وتوصيل أفضل.',
                'Keep your details current for a better shopping and delivery experience.',
              ),
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 22),
            Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSectionCard(
                    title: copy.pair('بياناتي الشخصية', 'Personal details'),
                    icon: Icons.badge_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.state.errorMessage case final message?)
                          _Error(message: message),
                        _field(
                          _name,
                          copy.pair('الاسم الكامل', 'Full name'),
                          Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _email,
                          copy.pair('البريد الإلكتروني', 'Email address'),
                          Icons.email_outlined,
                          keyboard: TextInputType.emailAddress,
                          validator: (value) => value?.contains('@') == true
                              ? null
                              : copy.pair(
                                  'أدخل بريدًا إلكترونيًا صحيحًا',
                                  'Enter a valid email address',
                                ),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _phone,
                          copy.pair('رقم الجوال', 'Mobile number'),
                          Icons.phone_outlined,
                          keyboard: TextInputType.phone,
                          optional: true,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _nationality,
                          copy.pair('الجنسية', 'Nationality'),
                          Icons.public_outlined,
                          optional: true,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: widget.state.isSaving ? null : _save,
                            child: Text(
                              widget.state.isSaving
                                  ? copy.pair('جارٍ الحفظ...', 'Saving...')
                                  : copy.pair('حفظ التعديلات', 'Save changes'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppSectionCard(
                    title: copy.pair('أمان الحساب', 'Account security'),
                    icon: Icons.lock_outline_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _field(
                          _currentPassword,
                          copy.pair('كلمة المرور الحالية', 'Current password'),
                          Icons.lock_outline,
                          obscure: true,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _newPassword,
                          copy.pair('كلمة المرور الجديدة', 'New password'),
                          Icons.lock_reset_outlined,
                          obscure: true,
                          validator: (value) =>
                              value != null && value.length >= 8
                              ? null
                              : copy.pair(
                                  'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
                                  'Password must be at least 8 characters',
                                ),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _confirmNewPassword,
                          copy.pair(
                            'تأكيد كلمة المرور الجديدة',
                            'Confirm new password',
                          ),
                          Icons.lock_reset_outlined,
                          obscure: true,
                          validator: (value) => value == _newPassword.text
                              ? null
                              : copy.pair(
                                  'كلمتا المرور غير متطابقتين',
                                  'Passwords do not match',
                                ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _isChangingPassword
                                ? null
                                : _changePassword,
                            child: Text(
                              _isChangingPassword
                                  ? copy.pair(
                                      'جارٍ تغيير كلمة المرور...',
                                      'Changing password...',
                                    )
                                  : copy.pair(
                                      'تغيير كلمة المرور',
                                      'Change password',
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final copy = AppCopy.of(context);
    if (!(_key.currentState?.validate() ?? false)) return;
    final success = await widget.controller.save(
      CustomerProfileData(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _nullable(_phone.text),
        nationality: _nullable(_nationality.text),
      ),
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.lastSaveWasQueued
                ? copy.pair(
                    'تم حفظ التعديلات على الجهاز وستتم مزامنتها عند عودة الإنترنت.',
                    'Changes were saved on this device and will sync when you are online.',
                  )
                : copy.pair(
                    'تم حفظ بيانات الحساب.',
                    'Your account details were saved.',
                  ),
          ),
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    final copy = AppCopy.of(context);
    if (_currentPassword.text.isEmpty || _newPassword.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.pair(
              'أكمل بيانات كلمة المرور بصورة صحيحة.',
              'Complete the password details correctly.',
            ),
          ),
        ),
      );
      return;
    }
    if (_newPassword.text != _confirmNewPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.pair('كلمتا المرور غير متطابقتين.', 'Passwords do not match.'),
          ),
        ),
      );
      return;
    }
    setState(() => _isChangingPassword = true);
    final error = await ref
        .read(authControllerProvider.notifier)
        .changePassword(
          oldPassword: _currentPassword.text,
          newPassword: _newPassword.text,
        );
    if (!mounted) return;
    setState(() => _isChangingPassword = false);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    _currentPassword.clear();
    _newPassword.clear();
    _confirmNewPassword.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          copy.pair(
            'تم تغيير كلمة المرور بنجاح.',
            'Your password was changed.',
          ),
        ),
      ),
    );
  }

  String? _nullable(String value) => value.trim().isEmpty ? null : value.trim();

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    bool obscure = false,
    bool optional = false,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboard,
    validator:
        validator ??
        (optional
            ? null
            : (value) => value?.trim().isNotEmpty == true
                  ? null
                  : AppCopy.of(
                      context,
                    ).pair('هذا الحقل مطلوب', 'This field is required')),
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({this.message, required this.onRetry});
  final String? message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56),
            const SizedBox(height: 12),
            Text(
              message ??
                  copy.pair('تعذر تحميل الحساب.', 'Could not load account.'),
            ),
            TextButton(
              onPressed: onRetry,
              child: Text(copy.pair('إعادة المحاولة', 'Try again')),
            ),
          ],
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AppFeedbackBanner(message: message, tone: AppBannerTone.error),
  );
}
