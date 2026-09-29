import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/security/secure_session_store.dart';
import '../../../core/security/session_identity.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/adaptive_layout.dart';
import '../application/auth_controller.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key, this.onLogout});
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    return switch (state.status) {
      AuthStatus.checking => const SkeletonPage(layout: SkeletonLayout.form),
      AuthStatus.signedIn => _SignedInCard(
        onLogout: onLogout ?? ref.read(authControllerProvider.notifier).logout,
      ),
      _ => _AuthForm(state: state),
    };
  }
}

class _SignedInCard extends ConsumerWidget {
  const _SignedInCard({required this.onLogout});
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppCopy.of(context);
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              const _AccountHero(),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.space_dashboard_rounded),
                label: Text(
                  copy.pair('فتح لوحة الحساب', 'Open account dashboard'),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                copy.pair('إدارة حسابك', 'Manage your account'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              AdaptiveGrid(
                minimumTileWidth: 125,
                childAspectRatio: 1.05,
                spacing: 12,
                children: [
                  _AccountShortcut(
                    icon: Icons.person_outline_rounded,
                    label: copy.pair('بياناتي', 'My profile'),
                    onTap: () => context.go('/profile'),
                  ),
                  _AccountShortcut(
                    icon: Icons.location_on_outlined,
                    label: copy.pair('عناويني', 'My addresses'),
                    onTap: () => context.go('/addresses'),
                  ),
                  _AccountShortcut(
                    icon: Icons.inventory_2_outlined,
                    label: copy.orders,
                    onTap: () => context.go('/orders'),
                  ),
                  _AccountShortcut(
                    icon: Icons.notifications_none_rounded,
                    label: copy.pair('الإشعارات', 'Notifications'),
                    onTap: () => context.go('/notifications'),
                  ),
                ],
              ),
              FutureBuilder<bool>(
                future: SessionIdentity.isAdmin(ref.read(sessionStoreProvider)),
                builder: (context, snapshot) => snapshot.data == true
                    ? Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            leading: const _RoundIcon(
                              icon: Icons.admin_panel_settings_outlined,
                            ),
                            title: Text(
                              copy.pair('لوحة تحكم الإدارة', 'Admin dashboard'),
                            ),
                            subtitle: Text(
                              copy.pair(
                                'إدارة المتجر والمحتوى والطلبات',
                                'Manage the store, content and orders',
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_left_rounded),
                            onTap: () => context.go('/admin'),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 14),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: const _RoundIcon(
                    icon: Icons.local_shipping_outlined,
                  ),
                  title: Text(
                    copy.pair('متابعة الدفع والشحنة', 'Payment & shipment'),
                  ),
                  subtitle: Text(
                    copy.pair(
                      'اطّلع على آخر حالة لطلبك',
                      'See your latest order status',
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => context.go('/payment-status'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded),
                label: Text(copy.pair('تسجيل الخروج', 'Sign out')),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  minimumSize: const Size(0, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero();

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF321426), Color(0xFF6A3556)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0x24FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFFF5D895),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.pair('أهلًا بك مجددًا', 'Welcome back'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  copy.pair(
                    'كل تفاصيل طلباتك وعناوينك في مكان واحد.',
                    'Your orders and addresses, all in one place.',
                  ),
                  style: const TextStyle(color: Color(0xE6FFFFFF), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountShortcut extends StatelessWidget {
  const _AccountShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _RoundIcon(icon: icon),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    ),
  );
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: Theme.of(context).colorScheme.primary),
  );
}

class _AuthForm extends ConsumerStatefulWidget {
  const _AuthForm({required this.state});
  final AuthState state;

  @override
  ConsumerState<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<_AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _resetCode = TextEditingController();
  var _isRegistering = false;
  var _isResettingPassword = false;
  var _resetCodeSent = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _resetCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = ref.read(authControllerProvider.notifier);
    if (_isRegistering) {
      await controller.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phoneNumber: _phone.text.trim(),
        password: _password.text,
      );
    } else {
      await controller.login(
        email: _email.text.trim(),
        password: _password.text,
      );
    }
  }

  Future<void> _requestReset() async {
    final copy = AppCopy.of(context);
    if (!_email.text.trim().contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.pair(
              'أدخل بريدًا إلكترونيًا صحيحًا أولًا.',
              'Enter a valid email address first.',
            ),
          ),
        ),
      );
      return;
    }
    final sent = await ref
        .read(authControllerProvider.notifier)
        .requestPasswordReset(email: _email.text.trim());
    if (sent && mounted) {
      setState(() => _resetCodeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.pair(
              'أرسلنا رمز الاستعادة إلى بريدك الإلكتروني.',
              'A recovery code was sent to your email.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    final copy = AppCopy.of(context);
    if (_resetCode.text.trim().isEmpty || _password.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.pair(
              'أدخل الرمز وكلمة مرور من 8 أحرف على الأقل.',
              'Enter the code and a password of at least 8 characters.',
            ),
          ),
        ),
      );
      return;
    }
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.pair('كلمتا المرور غير متطابقتين.', 'Passwords do not match.'),
          ),
        ),
      );
      return;
    }
    final reset = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(token: _resetCode.text, newPassword: _password.text);
    if (reset && mounted) {
      setState(() {
        _isResettingPassword = false;
        _resetCodeSent = false;
        _resetCode.clear();
        _password.clear();
        _confirmPassword.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.pair(
              'تمت إعادة تعيين كلمة المرور. يمكنك تسجيل الدخول الآن.',
              'Your password was reset. You can sign in now.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final isSubmitting = widget.state.status == AuthStatus.submitting;
    if (_isResettingPassword) {
      return _PasswordResetForm(
        email: _email,
        code: _resetCode,
        password: _password,
        confirmPassword: _confirmPassword,
        codeSent: _resetCodeSent,
        errorMessage: widget.state.errorMessage,
        onRequestCode: _requestReset,
        onReset: _resetPassword,
        onCancel: () => setState(() {
          _isResettingPassword = false;
          _resetCodeSent = false;
        }),
      );
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isRegistering
                          ? copy.pair('إنشاء حساب جديد', 'Create a new account')
                          : copy.pair('تسجيل الدخول', 'Sign in'),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (widget.state.errorMessage case final message?) ...[
                      _ErrorMessage(message: message),
                      const SizedBox(height: 12),
                    ],
                    if (_isRegistering) ...[
                      _field(
                        controller: _name,
                        label: copy.pair('الاسم الكامل', 'Full name'),
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _field(
                      controller: _email,
                      label: copy.pair('البريد الإلكتروني', 'Email address'),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value != null && value.contains('@')
                          ? null
                          : copy.pair(
                              'أدخل بريدًا إلكترونيًا صحيحًا',
                              'Enter a valid email address',
                            ),
                    ),
                    if (_isRegistering) ...[
                      const SizedBox(height: 12),
                      _field(
                        controller: _phone,
                        label: copy.pair('رقم الجوال', 'Mobile number'),
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _field(
                      controller: _password,
                      label: copy.pair('كلمة المرور', 'Password'),
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) => value != null && value.length >= 6
                          ? null
                          : copy.pair(
                              'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                              'Password must be at least 6 characters',
                            ),
                    ),
                    if (_isRegistering) ...[
                      const SizedBox(height: 12),
                      _field(
                        controller: _confirmPassword,
                        label: copy.pair(
                          'تأكيد كلمة المرور',
                          'Confirm password',
                        ),
                        icon: Icons.lock_reset_outlined,
                        obscureText: true,
                        validator: (value) => value == _password.text
                            ? null
                            : copy.pair(
                                'كلمتا المرور غير متطابقتين',
                                'Passwords do not match',
                              ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: isSubmitting ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: isSubmitting
                            ? const SkeletonInline(size: 22)
                            : Text(
                                _isRegistering
                                    ? copy.pair(
                                        'إنشاء الحساب',
                                        'Create account',
                                      )
                                    : copy.pair('دخول', 'Sign in'),
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => setState(
                              () => _isRegistering = !_isRegistering,
                            ),
                      child: Text(
                        _isRegistering
                            ? copy.pair(
                                'لديك حساب؟ سجّل الدخول',
                                'Already have an account? Sign in',
                              )
                            : copy.pair(
                                'ليس لديك حساب؟ أنشئ حسابًا',
                                'New here? Create an account',
                              ),
                      ),
                    ),
                    if (!_isRegistering)
                      TextButton(
                        onPressed: isSubmitting
                            ? null
                            : () => setState(() => _isResettingPassword = true),
                        child: Text(
                          copy.pair('نسيت كلمة المرور؟', 'Forgot password?'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    validator:
        validator ??
        (value) => value?.trim().isNotEmpty == true
            ? null
            : AppCopy.of(
                context,
              ).pair('هذا الحقل مطلوب', 'This field is required'),
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
  );
}

class _PasswordResetForm extends StatelessWidget {
  const _PasswordResetForm({
    required this.email,
    required this.code,
    required this.password,
    required this.confirmPassword,
    required this.codeSent,
    required this.errorMessage,
    required this.onRequestCode,
    required this.onReset,
    required this.onCancel,
  });
  final TextEditingController email;
  final TextEditingController code;
  final TextEditingController password;
  final TextEditingController confirmPassword;
  final bool codeSent;
  final String? errorMessage;
  final Future<void> Function() onRequestCode;
  final Future<void> Function() onReset;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    copy.pair('استعادة كلمة المرور', 'Reset password'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    codeSent
                        ? copy.pair(
                            'أدخل الرمز الذي وصل إلى بريدك ثم اختر كلمة مرور جديدة.',
                            'Enter the code from your email and choose a new password.',
                          )
                        : copy.pair(
                            'سنرسل لك رمزًا مؤقتًا إلى بريدك الإلكتروني.',
                            'We will send a temporary code to your email.',
                          ),
                  ),
                  const SizedBox(height: 18),
                  if (errorMessage case final message?) ...[
                    _ErrorMessage(message: message),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: email,
                    enabled: !codeSent,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: copy.pair(
                        'البريد الإلكتروني',
                        'Email address',
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  if (codeSent) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: code,
                      decoration: InputDecoration(
                        labelText: copy.pair('رمز الاستعادة', 'Recovery code'),
                        prefixIcon: const Icon(Icons.password_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: copy.pair(
                          'كلمة المرور الجديدة',
                          'New password',
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: copy.pair(
                          'تأكيد كلمة المرور الجديدة',
                          'Confirm new password',
                        ),
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: codeSent ? onReset : onRequestCode,
                    child: Text(
                      codeSent
                          ? copy.pair(
                              'إعادة تعيين كلمة المرور',
                              'Reset password',
                            )
                          : copy.pair('إرسال الرمز', 'Send code'),
                    ),
                  ),
                  TextButton(
                    onPressed: onCancel,
                    child: Text(
                      copy.pair('العودة لتسجيل الدخول', 'Back to sign in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
    ),
  );
}
