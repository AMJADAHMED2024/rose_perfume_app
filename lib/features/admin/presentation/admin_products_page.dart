import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/security/secure_session_store.dart';
import '../../../core/security/session_identity.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../application/admin_products_controller.dart';
import '../data/admin_products_repository.dart';

class AdminProductsPage extends ConsumerStatefulWidget {
  const AdminProductsPage({super.key});

  @override
  ConsumerState<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends ConsumerState<AdminProductsPage> {
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
        return const Scaffold(body: SkeletonPage(layout: SkeletonLayout.grid));
      }
      if (snapshot.data != true) {
        return Scaffold(
          appBar: AppBar(title: const Text('إدارة المنتجات')),
          body: Center(
            child: FilledButton(
              onPressed: () => context.go('/account'),
              child: const Text('العودة إلى الحساب'),
            ),
          ),
        );
      }
      return const _ProductsView();
    },
  );
}

class _ProductsView extends ConsumerStatefulWidget {
  const _ProductsView();

  @override
  ConsumerState<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends ConsumerState<_ProductsView> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _searchProducts(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(adminProductsControllerProvider.notifier).search(value);
    });
  }

  Future<void> _openEditor([AdminProduct? product]) async {
    final state = ref.read(adminProductsControllerProvider);
    final draft = await showDialog<AdminProductDraft>(
      context: context,
      builder: (_) =>
          _ProductEditorDialog(product: product, categories: state.categories),
    );
    if (draft == null || !mounted) return;
    try {
      await ref
          .read(adminProductsControllerProvider.notifier)
          .save(product: product, draft: draft);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              product == null ? 'تمت إضافة المنتج.' : 'تم تحديث المنتج.',
            ),
          ),
        );
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    }
  }

  Future<void> _delete(AdminProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج؟'),
        content: Text('سيُحذف “${product.nameAr}” نهائيًا من المتجر.'),
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
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(adminProductsControllerProvider.notifier).delete(product);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حذف المنتج.')));
      }
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
    final state = ref.watch(adminProductsControllerProvider);
    final notifier = ref.read(adminProductsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        actions: [
          IconButton(
            tooltip: 'لوحة التحكم',
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
          IconButton(
            tooltip: 'تحديث',
            onPressed: state.isLoading ? null : notifier.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.categories.isEmpty ? null : () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('منتج جديد'),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          children: [
            TextField(
              controller: _search,
              onChanged: _searchProducts,
              onSubmitted: notifier.search,
              decoration: const InputDecoration(
                labelText: 'ابحث باسم المنتج',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 14),
            if (state.errorMessage case final message?)
              _ErrorCard(message: message),
            if (state.errorMessage != null) const SizedBox(height: 14),
            if (state.isLoading && state.data == null)
              const Padding(
                padding: EdgeInsets.only(top: 56),
                child: SkeletonGrid(),
              )
            else if (state.data?.items.isEmpty ?? true)
              const Padding(
                padding: EdgeInsets.only(top: 56),
                child: Center(child: Text('لا توجد منتجات مطابقة.')),
              )
            else ...[
              _ProductsTable(
                products: state.data!.items,
                onEdit: _openEditor,
                onDelete: _delete,
              ),
              const SizedBox(height: 14),
              _Pagination(
                data: state.data!,
                isLoading: state.isLoading,
                onPage: notifier.goToPage,
              ),
            ],
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}

class _ProductsTable extends StatelessWidget {
  const _ProductsTable({
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });
  final List<AdminProduct> products;
  final ValueChanged<AdminProduct> onEdit;
  final ValueChanged<AdminProduct> onDelete;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('المنتج')),
          DataColumn(label: Text('القسم')),
          DataColumn(label: Text('السعر')),
          DataColumn(label: Text('المخزون')),
          DataColumn(label: Text('إجراءات')),
        ],
        rows: products
            .map(
              (product) => DataRow(
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ProductThumbnail(imageUrl: product.imageUrl),
                        const SizedBox(width: 8),
                        SizedBox(width: 160, child: Text(product.nameAr)),
                      ],
                    ),
                  ),
                  DataCell(Text(product.categoryName)),
                  DataCell(Text('${_money(product.price)} ر.س')),
                  DataCell(
                    Text(
                      '${product.stockQuantity}',
                      style: TextStyle(
                        color: product.stockQuantity == 0
                            ? Theme.of(context).colorScheme.error
                            : null,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'تعديل',
                          onPressed: () => onEdit(product),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'إدارة الصور',
                          onPressed: () => context.go(
                            '/admin/products/${product.id}/images',
                          ),
                          icon: const Icon(Icons.photo_library_outlined),
                        ),
                        IconButton(
                          tooltip: 'حذف',
                          onPressed: () => onDelete(product),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    ),
  );
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: imageUrl == null || imageUrl!.isEmpty
        ? Container(
            width: 38,
            height: 38,
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Icon(Icons.image_not_supported_outlined, size: 20),
          )
        : Image.network(
            imageUrl!,
            width: 38,
            height: 38,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 38,
              height: 38,
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: const Icon(Icons.broken_image_outlined, size: 20),
            ),
          ),
  );
}

class _ProductEditorDialog extends StatefulWidget {
  const _ProductEditorDialog({required this.product, required this.categories});
  final AdminProduct? product;
  final List<AdminCategoryOption> categories;

  @override
  State<_ProductEditorDialog> createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<_ProductEditorDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nameAr;
  late final TextEditingController _nameEn;
  late final TextEditingController _price;
  late final TextEditingController _discount;
  late final TextEditingController _stock;
  late final TextEditingController _weight;
  late final TextEditingController _descriptionAr;
  late final TextEditingController _descriptionEn;
  late int _categoryId;
  late bool _isDiscounted;
  late bool _isFeatured;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameAr = TextEditingController(text: product?.nameAr);
    _nameEn = TextEditingController(text: product?.nameEn);
    _price = TextEditingController(text: product?.price.toString());
    _discount = TextEditingController(
      text: product?.discount.toString() ?? '0',
    );
    _stock = TextEditingController(
      text: product?.stockQuantity.toString() ?? '0',
    );
    _weight = TextEditingController(text: product?.weight.toString() ?? '0');
    _descriptionAr = TextEditingController(text: product?.descriptionAr);
    _descriptionEn = TextEditingController(text: product?.descriptionEn);
    _categoryId = product?.categoryId ?? widget.categories.first.id;
    _isDiscounted = product?.isDiscounted ?? false;
    _isFeatured = product?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameAr.dispose();
    _nameEn.dispose();
    _price.dispose();
    _discount.dispose();
    _stock.dispose();
    _weight.dispose();
    _descriptionAr.dispose();
    _descriptionEn.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      AdminProductDraft(
        nameAr: _nameAr.text.trim(),
        nameEn: _nameEn.text.trim(),
        price: _number(_price.text),
        discount: _number(_discount.text),
        stockQuantity: _integer(_stock.text),
        categoryId: _categoryId,
        isDiscounted: _isDiscounted,
        isFeatured: _isFeatured,
        weight: _number(_weight.text),
        descriptionAr: _descriptionAr.text.trim(),
        descriptionEn: _descriptionEn.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.product == null ? 'إضافة منتج' : 'تعديل المنتج'),
    content: SizedBox(
      width: 560,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_nameAr, 'الاسم العربي'),
              _field(_nameEn, 'الاسم الإنجليزي'),
              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'القسم'),
                items: widget.categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _categoryId = value ?? _categoryId),
              ),
              _field(_price, 'السعر', numeric: true),
              if (_isDiscounted) _field(_discount, 'قيمة الخصم', numeric: true),
              _field(_stock, 'الكمية في المخزون', numeric: true, integer: true),
              _field(_weight, 'الوزن بالكيلوغرام', numeric: true),
              _field(_descriptionAr, 'الوصف العربي', required: false, lines: 3),
              _field(
                _descriptionEn,
                'الوصف الإنجليزي',
                required: false,
                lines: 3,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('يوجد خصم'),
                value: _isDiscounted,
                onChanged: (value) => setState(() => _isDiscounted = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('منتج مميز'),
                value: _isFeatured,
                onChanged: (value) => setState(() => _isFeatured = value),
              ),
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
      FilledButton(onPressed: _submit, child: const Text('حفظ')),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool numeric = false,
    bool integer = false,
    bool required = true,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      maxLines: lines,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (required && value?.trim().isEmpty == true) {
          return 'هذا الحقل مطلوب';
        }
        if (numeric && value?.trim().isNotEmpty == true) {
          final parsed = integer
              ? int.tryParse(value!.trim())
              : double.tryParse(value!.trim());
          if (parsed == null || parsed < 0) {
            return 'أدخل قيمة صحيحة';
          }
        }
        return null;
      },
    ),
  );
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.data,
    required this.isLoading,
    required this.onPage,
  });
  final AdminProductsPageData data;
  final bool isLoading;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text('${data.totalCount} منتجًا')),
      IconButton(
        tooltip: 'الصفحة السابقة',
        onPressed: isLoading || data.pageNumber <= 1
            ? null
            : () => onPage(data.pageNumber - 1),
        icon: const Icon(Icons.chevron_right),
      ),
      Text('${data.pageNumber} / ${data.totalPages}'),
      IconButton(
        tooltip: 'الصفحة التالية',
        onPressed: isLoading || data.pageNumber >= data.totalPages
            ? null
            : () => onPage(data.pageNumber + 1),
        icon: const Icon(Icons.chevron_left),
      ),
    ],
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

double _number(String value) => double.tryParse(value.trim()) ?? 0;
int _integer(String value) => int.tryParse(value.trim()) ?? 0;
String _money(num value) =>
    value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
