import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../application/admin_categories_controller.dart';
import '../data/admin_categories_repository.dart';

class AdminCategoriesPage extends ConsumerStatefulWidget {
  const AdminCategoriesPage({super.key});
  @override
  ConsumerState<AdminCategoriesPage> createState() =>
      _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends ConsumerState<AdminCategoriesPage> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(adminCategoriesControllerProvider.notifier).search(value);
    });
  }

  Future<void> _edit([AdminCategory? category]) async {
    final draft = await showDialog<AdminCategoryDraft>(
      context: context,
      builder: (_) => _CategoryDialog(category: category),
    );
    if (draft == null || !mounted) return;
    try {
      await ref
          .read(adminCategoriesControllerProvider.notifier)
          .save(category: category, draft: draft);
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    }
  }

  Future<void> _delete(AdminCategory category) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف القسم؟'),
        content: Text(
          'سيُحذف القسم “${category.nameAr}”. لا يمكن حذف قسم مرتبط بمنتجات من الخادم.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    try {
      await ref
          .read(adminCategoriesControllerProvider.notifier)
          .delete(category);
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCategoriesControllerProvider);
    final controller = ref.read(adminCategoriesControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأقسام'),
        actions: [
          IconButton(
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
          IconButton(
            onPressed: state.isLoading ? null : controller.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _edit,
        icon: const Icon(Icons.add),
        label: const Text('قسم جديد'),
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          children: [
            TextField(
              controller: _search,
              onChanged: _onSearch,
              decoration: const InputDecoration(
                labelText: 'ابحث باسم القسم',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 14),
            if (state.errorMessage case final message?)
              _ErrorCard(message: message),
            if (state.isLoading && state.items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 56),
                child: SkeletonList(),
              )
            else if (state.items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 56),
                child: Center(child: Text('لا توجد أقسام مطابقة.')),
              )
            else
              Card(
                child: Column(
                  children: state.items
                      .map(
                        (category) => ListTile(
                          leading: CircleAvatar(child: Text('${category.id}')),
                          title: Text(category.nameAr),
                          subtitle: Text(
                            category.descriptionAr.isEmpty
                                ? category.nameEn
                                : category.descriptionAr,
                          ),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                onPressed: () => _edit(category),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () => _delete(category),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.category});
  final AdminCategory? category;
  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nameAr;
  late final TextEditingController _nameEn;
  late final TextEditingController _descriptionAr;
  late final TextEditingController _descriptionEn;

  @override
  void initState() {
    super.initState();
    final source = widget.category;
    _nameAr = TextEditingController(text: source?.nameAr);
    _nameEn = TextEditingController(text: source?.nameEn);
    _descriptionAr = TextEditingController(text: source?.descriptionAr);
    _descriptionEn = TextEditingController(text: source?.descriptionEn);
  }

  @override
  void dispose() {
    _nameAr.dispose();
    _nameEn.dispose();
    _descriptionAr.dispose();
    _descriptionEn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.category == null ? 'إضافة قسم' : 'تعديل القسم'),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_nameAr, 'الاسم العربي', required: true),
            _field(_nameEn, 'الاسم الإنجليزي', required: true),
            _field(_descriptionAr, 'الوصف العربي', lines: 3),
            _field(_descriptionEn, 'الوصف الإنجليزي', lines: 3),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        onPressed: () {
          if (!(_form.currentState?.validate() ?? false)) return;
          Navigator.pop(
            context,
            AdminCategoryDraft(
              nameAr: _nameAr.text.trim(),
              nameEn: _nameEn.text.trim(),
              descriptionAr: _descriptionAr.text.trim(),
              descriptionEn: _descriptionEn.text.trim(),
            ),
          );
        },
        child: const Text('حفظ'),
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      maxLines: lines,
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          required && value?.trim().isEmpty == true ? 'هذا الحقل مطلوب' : null,
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Padding(padding: const EdgeInsets.all(14), child: Text(message)),
  );
}
