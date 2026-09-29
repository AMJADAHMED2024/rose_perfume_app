import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../application/admin_variants_controller.dart';
import '../data/admin_variants_repository.dart';

class AdminVariantsPage extends ConsumerWidget {
  const AdminVariantsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminVariantsControllerProvider);
    final controller = ref.read(adminVariantsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('متغيرات المنتجات'),
        actions: [
          IconButton(
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
          IconButton(
            onPressed: controller.loadProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: state.selectedProductId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _edit(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('متغير جديد'),
            ),
      body: state.loading && state.products.isEmpty
          ? const SkeletonPage(layout: SkeletonLayout.list)
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                if (state.error case final error?) _ErrorCard(error),
                if (state.products.isNotEmpty)
                  DropdownButtonFormField<int>(
                    initialValue: state.selectedProductId,
                    decoration: const InputDecoration(labelText: 'المنتج'),
                    items: state.products
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      if (id != null) controller.selectProduct(id);
                    },
                  ),
                const SizedBox(height: 16),
                if (state.loading)
                  const AppSkeleton(child: SkeletonBox(height: 140, radius: 20))
                else if (state.selectedProductId == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text('أضف منتجًا أولًا.'),
                    ),
                  )
                else if (state.variants.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text('لا توجد متغيرات لهذا المنتج.'),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: state.variants
                          .map(
                            (variant) => ListTile(
                              leading: const Icon(Icons.scale_outlined),
                              title: Text(variant.name),
                              subtitle: Text(
                                '${variant.weightInGram.toStringAsFixed(0)} غرام · ${variant.price.toStringAsFixed(2)} ر.س',
                              ),
                              trailing: Wrap(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _edit(context, ref, variant),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _delete(context, ref, variant),
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
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    AdminProductVariant? variant,
  ]) async {
    final draft = await showDialog<AdminVariantDraft>(
      context: context,
      builder: (_) => _VariantDialog(variant: variant),
    );
    if (draft == null) return;
    try {
      await ref
          .read(adminVariantsControllerProvider.notifier)
          .save(variant: variant, draft: draft);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر حفظ المتغير.')));
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AdminProductVariant variant,
  ) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المتغير؟'),
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
    if (yes != true) return;
    try {
      await ref.read(adminVariantsControllerProvider.notifier).delete(variant);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر حذف المتغير.')));
      }
    }
  }
}

class _VariantDialog extends StatefulWidget {
  const _VariantDialog({this.variant});
  final AdminProductVariant? variant;
  @override
  State<_VariantDialog> createState() => _VariantDialogState();
}

class _VariantDialogState extends State<_VariantDialog> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController weight;
  late final TextEditingController price;
  @override
  void initState() {
    super.initState();
    final v = widget.variant;
    name = TextEditingController(text: v?.name);
    weight = TextEditingController(text: v?.weightInGram.toString());
    price = TextEditingController(text: v?.price.toString());
  }

  @override
  void dispose() {
    name.dispose();
    weight.dispose();
    price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.variant == null ? 'متغير جديد' : 'تعديل المتغير'),
    content: Form(
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _field(name, 'الاسم، مثل 100 مل'),
          _field(weight, 'الوزن بالجرام', number: true),
          _field(price, 'السعر', number: true),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        onPressed: () {
          if (!(form.currentState?.validate() ?? false)) return;
          Navigator.pop(
            context,
            AdminVariantDraft(
              name: name.text.trim(),
              weightInGram: double.parse(weight.text),
              price: double.parse(price.text),
            ),
          );
        },
        child: const Text('حفظ'),
      ),
    ],
  );
  Widget _field(TextEditingController c, String label, {bool number = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true)
              : null,
          decoration: InputDecoration(labelText: label),
          validator: (v) =>
              v?.trim().isEmpty == true ||
                  (number && double.tryParse(v!) == null)
              ? 'أدخل قيمة صحيحة'
              : null,
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Padding(padding: const EdgeInsets.all(14), child: Text(message)),
  );
}
