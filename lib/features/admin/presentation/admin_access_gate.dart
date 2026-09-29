import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/security/secure_session_store.dart';
import '../../../core/security/session_identity.dart';
import '../../../core/widgets/app_skeleton.dart';

/// One reusable server-aligned gate for every administrative route.
/// The API remains the authority, while this prevents exposing management
/// controls briefly to a non-administrator in the client UI.
class AdminAccessGate extends ConsumerStatefulWidget {
  const AdminAccessGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AdminAccessGate> createState() => _AdminAccessGateState();
}

class _AdminAccessGateState extends ConsumerState<AdminAccessGate> {
  late final Future<bool> _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = SessionIdentity.isAdmin(ref.read(sessionStoreProvider));
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _isAdmin,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(
          body: SkeletonPage(layout: SkeletonLayout.dashboard),
        );
      }
      if (snapshot.data == true) return widget.child;
      return Scaffold(
        appBar: AppBar(title: const Text('وصول محمي')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 52,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'هذه الصفحة مخصّصة للإدارة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'سجّل الدخول بحساب مدير للوصول إلى أدوات المتجر.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () => context.go('/account'),
                        child: const Text('العودة إلى الحساب'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
