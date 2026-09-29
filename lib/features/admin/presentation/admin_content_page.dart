import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../../content/data/store_content_repository.dart';

class AdminContentPage extends ConsumerStatefulWidget {
  const AdminContentPage({super.key});

  @override
  ConsumerState<AdminContentPage> createState() => _AdminContentPageState();
}

class _AdminContentPageState extends ConsumerState<AdminContentPage> {
  static const _sections = [
    _ContentSection('About', 'من نحن', Icons.auto_awesome_outlined),
    _ContentSection('Privacy', 'سياسة الخصوصية', Icons.privacy_tip_outlined),
    _ContentSection(
      'Return',
      'سياسة الاسترجاع',
      Icons.assignment_return_outlined,
    ),
    _ContentSection('Terms', 'الشروط والأحكام', Icons.gavel_outlined),
  ];

  final _controllers = <String, TextEditingController>{
    for (final section in _sections) section.type: TextEditingController(),
  };
  final _saving = <String>{};
  bool _initialized = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _populate(List<StoreContentDocument> documents) {
    if (_initialized) return;
    for (final document in documents) {
      final controller = _controllers[document.type];
      if (controller != null) controller.text = document.content;
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(storeContentProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('محتوى المتجر'),
        actions: [
          IconButton(
            tooltip: 'لوحة التحكم',
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
          IconButton(
            tooltip: 'تحديث',
            onPressed: () {
              _initialized = false;
              ref.invalidate(storeContentProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: documents.when(
        loading: () => const SkeletonPage(layout: SkeletonLayout.form),
        error: (_, _) =>
            _ErrorState(onRetry: () => ref.invalidate(storeContentProvider)),
        data: (items) {
          _populate(items);
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const _IntroCard(),
              const SizedBox(height: 16),
              ..._sections.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _EditorCard(
                    section: section,
                    controller: _controllers[section.type]!,
                    isSaving: _saving.contains(section.type),
                    onSave: () => _save(section),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save(_ContentSection section) async {
    setState(() => _saving.add(section.type));
    try {
      await ref
          .read(storeContentRepositoryProvider)
          .save(type: section.type, content: _controllers[section.type]!.text);
      ref.invalidate(storeContentProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم نشر «${section.title}» في المتجر.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر حفظ المحتوى. تأكد من صلاحية المدير والاتصال.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving.remove(section.type));
    }
  }
}

class _ContentSection {
  const _ContentSection(this.type, this.title, this.icon);
  final String type;
  final String title;
  final IconData icon;
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: const Padding(
      padding: EdgeInsets.all(18),
      child: Text(
        'هذه الوثائق مشتركة مع لوحة React وواجهة المتجر. اكتب نصًا واضحًا، ويمكن إبقاء المحتوى فارغًا للعودة إلى النص الاحتياطي داخل التطبيق عند عدم الاتصال.',
        style: TextStyle(height: 1.6),
      ),
    ),
  );
}

class _EditorCard extends StatelessWidget {
  const _EditorCard({
    required this.section,
    required this.controller,
    required this.isSaving,
    required this.onSave,
  });
  final _ContentSection section;
  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(section.icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            minLines: 8,
            maxLines: 16,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
              hintText: 'اكتب المحتوى المنشور هنا…',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SkeletonInline()
                  : const Icon(Icons.publish_outlined),
              label: Text(isSaving ? 'جارٍ الحفظ' : 'نشر التعديل'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 46),
          const SizedBox(height: 12),
          const Text('تعذر تحميل محتوى المتجر.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    ),
  );
}
