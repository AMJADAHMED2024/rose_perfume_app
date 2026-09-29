import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../data/admin_storefront_repository.dart';

final _branchesProvider = FutureProvider.autoDispose<List<AdminBranch>>(
  (ref) => ref.watch(adminStorefrontRepositoryProvider).fetchBranches(),
);
final _bannersProvider = FutureProvider.autoDispose<List<AdminBanner>>(
  (ref) => ref.watch(adminStorefrontRepositoryProvider).fetchBanners(),
);
final _slidersProvider = FutureProvider.autoDispose<List<AdminSlider>>(
  (ref) => ref.watch(adminStorefrontRepositoryProvider).fetchSliders(),
);
final _testimonialsProvider =
    FutureProvider.autoDispose<List<AdminTestimonial>>(
      (ref) => ref.watch(adminStorefrontRepositoryProvider).fetchTestimonials(),
    );

class AdminStorefrontPage extends StatelessWidget {
  const AdminStorefrontPage({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('واجهة المتجر'),
        actions: [
          IconButton(
            tooltip: 'لوحة التحكم',
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
        ],
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.storefront_outlined), text: 'الفروع'),
            Tab(icon: Icon(Icons.image_outlined), text: 'البنرات'),
            Tab(icon: Icon(Icons.view_carousel_outlined), text: 'السلايدرات'),
            Tab(icon: Icon(Icons.format_quote_outlined), text: 'الشهادات'),
          ],
        ),
      ),
      body: const TabBarView(
        children: [
          _BranchesPanel(),
          _BannersPanel(),
          _SlidersPanel(),
          _TestimonialsPanel(),
        ],
      ),
    ),
  );
}

class _BranchesPanel extends ConsumerWidget {
  const _BranchesPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) => _AsyncPanel<AdminBranch>(
    value: ref.watch(_branchesProvider),
    empty: 'لا توجد فروع بعد.',
    addLabel: 'إضافة فرع',
    onRefresh: () => ref.invalidate(_branchesProvider),
    onAdd: () => _saveBranch(context, ref),
    itemBuilder: (branch) => Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.location_on_outlined)),
        title: Text(branch.nameAr.isEmpty ? branch.nameEn : branch.nameAr),
        subtitle: Text(
          '${branch.phone.isEmpty ? 'بدون هاتف' : branch.phone}\n${branch.latitude.toStringAsFixed(5)}, ${branch.longitude.toStringAsFixed(5)}',
        ),
        isThreeLine: true,
        trailing: _Actions(
          onEdit: () => _saveBranch(context, ref, existing: branch),
          onDelete: () => _delete(
            context,
            () => ref
                .read(adminStorefrontRepositoryProvider)
                .deleteBranch(branch.id),
            () => ref.invalidate(_branchesProvider),
          ),
        ),
      ),
    ),
  );
}

class _BannersPanel extends ConsumerWidget {
  const _BannersPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) => _AsyncPanel<AdminBanner>(
    value: ref.watch(_bannersProvider),
    empty: 'لا توجد بنرات منشورة.',
    addLabel: 'إضافة بنر',
    onRefresh: () => ref.invalidate(_bannersProvider),
    onAdd: () => _saveBanner(context, ref),
    itemBuilder: (banner) => Card(
      child: ListTile(
        leading: _NetworkThumb(url: banner.imageUrl),
        title: Text(banner.title.isEmpty ? 'بنر #${banner.id}' : banner.title),
        subtitle: Text(
          'الموضع: ${banner.position.isEmpty ? 'غير محدد' : banner.position}',
        ),
        trailing: _Actions(
          onEdit: () => _saveBanner(context, ref, existing: banner),
          onDelete: () => _delete(
            context,
            () => ref
                .read(adminStorefrontRepositoryProvider)
                .deleteBanner(banner.id),
            () => ref.invalidate(_bannersProvider),
          ),
        ),
      ),
    ),
  );
}

class _SlidersPanel extends ConsumerWidget {
  const _SlidersPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) => _AsyncPanel<AdminSlider>(
    value: ref.watch(_slidersProvider),
    empty: 'لا توجد سلايدرات.',
    addLabel: 'إضافة سلايدر',
    onRefresh: () => ref.invalidate(_slidersProvider),
    onAdd: () => _saveSlider(context, ref),
    itemBuilder: (slider) => Card(
      child: ListTile(
        leading: _NetworkThumb(url: slider.mobileImageUrl),
        title: Text(slider.name.isEmpty ? 'سلايدر #${slider.id}' : slider.name),
        subtitle: Text(slider.isPublished ? 'منشور الآن' : 'مخفي عن المتجر'),
        trailing: Wrap(
          spacing: 0,
          children: [
            IconButton(
              tooltip: slider.isPublished ? 'إخفاء' : 'نشر',
              onPressed: () async {
                await _run(
                  context,
                  () => ref
                      .read(adminStorefrontRepositoryProvider)
                      .toggleSlider(slider.id),
                );
                ref.invalidate(_slidersProvider);
              },
              icon: Icon(
                slider.isPublished
                    ? Icons.visibility_off_outlined
                    : Icons.publish_outlined,
              ),
            ),
            _Actions(
              onEdit: () => _saveSlider(context, ref, existing: slider),
              onDelete: () => _delete(
                context,
                () => ref
                    .read(adminStorefrontRepositoryProvider)
                    .deleteSlider(slider.id),
                () => ref.invalidate(_slidersProvider),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TestimonialsPanel extends ConsumerWidget {
  const _TestimonialsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _AsyncPanel<AdminTestimonial>(
        value: ref.watch(_testimonialsProvider),
        empty: 'لا توجد شهادات عملاء.',
        addLabel: 'إضافة شهادة',
        onRefresh: () => ref.invalidate(_testimonialsProvider),
        onAdd: () => _saveTestimonial(context, ref),
        itemBuilder: (item) => Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.format_quote_outlined),
            ),
            title: Text(item.nameAr.isEmpty ? item.nameEn : item.nameAr),
            subtitle: Text(
              item.reviewAr.isEmpty ? item.reviewEn : item.reviewAr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: _Actions(
              onEdit: () => _saveTestimonial(context, ref, existing: item),
              onDelete: () => _delete(
                context,
                () => ref
                    .read(adminStorefrontRepositoryProvider)
                    .deleteTestimonial(item.id),
                () => ref.invalidate(_testimonialsProvider),
              ),
            ),
          ),
        ),
      );
}

class _AsyncPanel<T> extends StatelessWidget {
  const _AsyncPanel({
    required this.value,
    required this.empty,
    required this.addLabel,
    required this.onRefresh,
    required this.onAdd,
    required this.itemBuilder,
  });
  final AsyncValue<List<T>> value;
  final String empty;
  final String addLabel;
  final VoidCallback onRefresh;
  final VoidCallback onAdd;
  final Widget Function(T item) itemBuilder;

  @override
  Widget build(BuildContext context) => value.when(
    loading: () => const SkeletonPage(layout: SkeletonLayout.form),
    error: (_, _) => Center(
      child: FilledButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh),
        label: const Text('إعادة المحاولة'),
      ),
    ),
    data: (items) => RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        children: [
          _PanelHeader(label: addLabel, onAdd: onAdd),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(empty)),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: itemBuilder(item),
              ),
            ),
        ],
      ),
    ),
  );
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.label, required this.onAdd});
  final String label;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Expanded(child: Text('التغييرات تُنشر من الخادم لكل المنصات.')),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(label),
          ),
        ],
      ),
    ),
  );
}

class _Actions extends StatelessWidget {
  const _Actions({required this.onEdit, required this.onDelete});
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Wrap(
    children: [
      IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
      IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
    ],
  );
}

class _NetworkThumb extends StatelessWidget {
  const _NetworkThumb({required this.url});
  final String url;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: SizedBox(
      width: 48,
      height: 48,
      child: url.isEmpty
          ? const ColoredBox(
              color: Color(0xFFEDE7EA),
              child: Icon(Icons.image_outlined),
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.broken_image_outlined),
            ),
    ),
  );
}

Future<void> _saveBranch(
  BuildContext context,
  WidgetRef ref, {
  AdminBranch? existing,
}) async {
  final draft = await showDialog<AdminBranchDraft>(
    context: context,
    builder: (_) => _BranchDialog(existing: existing),
  );
  if (draft == null) return;
  if (!context.mounted) return;
  await _run(
    context,
    () => ref
        .read(adminStorefrontRepositoryProvider)
        .saveBranch(draft, id: existing?.id),
  );
  ref.invalidate(_branchesProvider);
}

Future<void> _saveBanner(
  BuildContext context,
  WidgetRef ref, {
  AdminBanner? existing,
}) async {
  final result = await showDialog<_BannerEdit>(
    context: context,
    builder: (_) => _BannerDialog(existing: existing),
  );
  if (result == null) return;
  if (!context.mounted) return;
  await _run(
    context,
    () => ref
        .read(adminStorefrontRepositoryProvider)
        .saveBanner(result.draft, id: existing?.id, image: result.image),
  );
  ref.invalidate(_bannersProvider);
}

Future<void> _saveSlider(
  BuildContext context,
  WidgetRef ref, {
  AdminSlider? existing,
}) async {
  final result = await showDialog<_SliderEdit>(
    context: context,
    builder: (_) => _SliderDialog(existing: existing),
  );
  if (result == null) return;
  if (!context.mounted) return;
  final repository = ref.read(adminStorefrontRepositoryProvider);
  await _run(context, () async {
    final id = existing?.id ?? await repository.createSlider(result.draft);
    if (existing != null) {
      await repository.updateSlider(id, result.draft);
    }
    if (result.mobile != null) {
      await repository.uploadSliderImage(
        sliderId: id,
        image: result.mobile!,
        desktop: false,
      );
    }
    if (result.desktop != null) {
      await repository.uploadSliderImage(
        sliderId: id,
        image: result.desktop!,
        desktop: true,
      );
    }
  });
  ref.invalidate(_slidersProvider);
}

Future<void> _saveTestimonial(
  BuildContext context,
  WidgetRef ref, {
  AdminTestimonial? existing,
}) async {
  final draft = await showDialog<AdminTestimonialDraft>(
    context: context,
    builder: (_) => _TestimonialDialog(existing: existing),
  );
  if (draft == null) return;
  if (!context.mounted) return;
  await _run(
    context,
    () => ref
        .read(adminStorefrontRepositoryProvider)
        .saveTestimonial(draft, id: existing?.id),
  );
  ref.invalidate(_testimonialsProvider);
}

Future<void> _delete(
  BuildContext context,
  Future<void> Function() action,
  VoidCallback refresh,
) async {
  final approved = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('حذف العنصر؟'),
      content: const Text('لا يمكن التراجع عن هذا الإجراء من التطبيق.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('حذف'),
        ),
      ],
    ),
  );
  if (approved != true) return;
  if (!context.mounted) return;
  await _run(context, action);
  refresh();
}

Future<void> _run(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح.')));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تنفيذ العملية. تحقق من صلاحية المدير والاتصال.'),
        ),
      );
    }
  }
}

class _BranchDialog extends StatefulWidget {
  const _BranchDialog({this.existing});
  final AdminBranch? existing;
  @override
  State<_BranchDialog> createState() => _BranchDialogState();
}

class _BranchDialogState extends State<_BranchDialog> {
  late final nameAr = TextEditingController(text: widget.existing?.nameAr);
  late final nameEn = TextEditingController(text: widget.existing?.nameEn);
  late final phone = TextEditingController(text: widget.existing?.phone);
  late final descriptionAr = TextEditingController(
    text: widget.existing?.descriptionAr,
  );
  late final descriptionEn = TextEditingController(
    text: widget.existing?.descriptionEn,
  );
  late final latitude = TextEditingController(
    text: '${widget.existing?.latitude ?? 0}',
  );
  late final longitude = TextEditingController(
    text: '${widget.existing?.longitude ?? 0}',
  );
  @override
  void dispose() {
    for (final c in [
      nameAr,
      nameEn,
      phone,
      descriptionAr,
      descriptionEn,
      latitude,
      longitude,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _DialogFrame(
    title: widget.existing == null ? 'إضافة فرع' : 'تعديل الفرع',
    onSave: () {
      if (nameAr.text.trim().isEmpty || nameEn.text.trim().isEmpty) return;
      Navigator.pop(
        context,
        AdminBranchDraft(
          nameAr: nameAr.text.trim(),
          nameEn: nameEn.text.trim(),
          descriptionAr: descriptionAr.text.trim(),
          descriptionEn: descriptionEn.text.trim(),
          phone: phone.text.trim(),
          latitude: double.tryParse(latitude.text) ?? 0,
          longitude: double.tryParse(longitude.text) ?? 0,
        ),
      );
    },
    children: [
      _field(nameAr, 'الاسم بالعربية', required: true),
      _field(nameEn, 'الاسم بالإنجليزية', required: true),
      _field(phone, 'الهاتف'),
      _field(descriptionAr, 'الوصف بالعربية', lines: 3),
      _field(descriptionEn, 'الوصف بالإنجليزية', lines: 3),
      _field(latitude, 'خط العرض', numeric: true),
      _field(longitude, 'خط الطول', numeric: true),
    ],
  );
}

class _BannerEdit {
  const _BannerEdit(this.draft, this.image);
  final AdminBannerDraft draft;
  final PlatformFile? image;
}

class _BannerDialog extends StatefulWidget {
  const _BannerDialog({this.existing});
  final AdminBanner? existing;
  @override
  State<_BannerDialog> createState() => _BannerDialogState();
}

class _BannerDialogState extends State<_BannerDialog> {
  late final title = TextEditingController(text: widget.existing?.title);
  late final description = TextEditingController(
    text: widget.existing?.description,
  );
  late final link = TextEditingController(text: widget.existing?.link);
  late final position = TextEditingController(text: widget.existing?.position);
  PlatformFile? image;
  @override
  void dispose() {
    for (final c in [title, description, link, position]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _DialogFrame(
    title: widget.existing == null ? 'إضافة بنر' : 'تعديل البنر',
    onSave: () {
      if (position.text.trim().isEmpty) return;
      Navigator.pop(
        context,
        _BannerEdit(
          AdminBannerDraft(
            title: title.text.trim(),
            description: description.text.trim(),
            link: link.text.trim(),
            position: position.text.trim(),
          ),
          image,
        ),
      );
    },
    children: [
      _field(title, 'العنوان'),
      _field(description, 'الوصف', lines: 3),
      _field(link, 'الرابط عند الضغط'),
      _field(position, 'موضع البنر', required: true),
      _FileField(
        label: image?.name ?? 'اختيار صورة البنر',
        onPick: () async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            withData: true,
          );
          if (result?.files.singleOrNull case final file?) {
            setState(() => image = file);
          }
        },
      ),
    ],
  );
}

class _SliderEdit {
  const _SliderEdit(this.draft, {this.mobile, this.desktop});
  final AdminSliderDraft draft;
  final PlatformFile? mobile;
  final PlatformFile? desktop;
}

class _SliderDialog extends StatefulWidget {
  const _SliderDialog({this.existing});
  final AdminSlider? existing;
  @override
  State<_SliderDialog> createState() => _SliderDialogState();
}

class _SliderDialogState extends State<_SliderDialog> {
  late final name = TextEditingController(text: widget.existing?.name);
  late final link = TextEditingController(text: widget.existing?.link);
  late bool published = widget.existing?.isPublished ?? true;
  PlatformFile? mobile;
  PlatformFile? desktop;
  @override
  void dispose() {
    name.dispose();
    link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _DialogFrame(
    title: widget.existing == null ? 'إضافة سلايدر' : 'تعديل السلايدر',
    onSave: () {
      if (name.text.trim().isEmpty) return;
      Navigator.pop(
        context,
        _SliderEdit(
          AdminSliderDraft(
            name: name.text.trim(),
            link: link.text.trim(),
            isPublished: published,
          ),
          mobile: mobile,
          desktop: desktop,
        ),
      );
    },
    children: [
      _field(name, 'اسم السلايدر', required: true),
      _field(link, 'الرابط عند الضغط'),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('منشور'),
        value: published,
        onChanged: (v) => setState(() => published = v),
      ),
      _FileField(
        label: mobile?.name ?? 'صورة الجوال',
        onPick: () async {
          final r = await FilePicker.platform.pickFiles(
            type: FileType.image,
            withData: true,
          );
          if (r?.files.singleOrNull case final f?) {
            setState(() => mobile = f);
          }
        },
      ),
      _FileField(
        label: desktop?.name ?? 'صورة سطح المكتب',
        onPick: () async {
          final r = await FilePicker.platform.pickFiles(
            type: FileType.image,
            withData: true,
          );
          if (r?.files.singleOrNull case final f?) {
            setState(() => desktop = f);
          }
        },
      ),
    ],
  );
}

class _TestimonialDialog extends StatefulWidget {
  const _TestimonialDialog({this.existing});
  final AdminTestimonial? existing;
  @override
  State<_TestimonialDialog> createState() => _TestimonialDialogState();
}

class _TestimonialDialogState extends State<_TestimonialDialog> {
  late final nameAr = TextEditingController(text: widget.existing?.nameAr);
  late final nameEn = TextEditingController(text: widget.existing?.nameEn);
  late final reviewAr = TextEditingController(text: widget.existing?.reviewAr);
  late final reviewEn = TextEditingController(text: widget.existing?.reviewEn);
  late final jobAr = TextEditingController(text: widget.existing?.jobAr);
  late final jobEn = TextEditingController(text: widget.existing?.jobEn);
  @override
  void dispose() {
    for (final c in [nameAr, nameEn, reviewAr, reviewEn, jobAr, jobEn]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _DialogFrame(
    title: widget.existing == null ? 'إضافة شهادة' : 'تعديل الشهادة',
    onSave: () {
      if (nameAr.text.trim().isEmpty || reviewAr.text.trim().isEmpty) return;
      Navigator.pop(
        context,
        AdminTestimonialDraft(
          nameAr: nameAr.text.trim(),
          nameEn: nameEn.text.trim(),
          reviewAr: reviewAr.text.trim(),
          reviewEn: reviewEn.text.trim(),
          jobAr: jobAr.text.trim(),
          jobEn: jobEn.text.trim(),
        ),
      );
    },
    children: [
      _field(nameAr, 'اسم العميل بالعربية', required: true),
      _field(nameEn, 'اسم العميل بالإنجليزية'),
      _field(reviewAr, 'التقييم بالعربية', required: true, lines: 4),
      _field(reviewEn, 'التقييم بالإنجليزية', lines: 4),
      _field(jobAr, 'المسمى بالعربية'),
      _field(jobEn, 'المسمى بالإنجليزية'),
    ],
  );
}

class _DialogFrame extends StatelessWidget {
  const _DialogFrame({
    required this.title,
    required this.children,
    required this.onSave,
  });
  final String title;
  final List<Widget> children;
  final VoidCallback onSave;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children
              .map(
                (w) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: w,
                ),
              )
              .toList(),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(onPressed: onSave, child: const Text('حفظ')),
    ],
  );
}

TextField _field(
  TextEditingController controller,
  String label, {
  bool required = false,
  int lines = 1,
  bool numeric = false,
}) => TextField(
  controller: controller,
  minLines: lines,
  maxLines: lines,
  keyboardType: numeric
      ? const TextInputType.numberWithOptions(decimal: true)
      : TextInputType.text,
  decoration: InputDecoration(
    labelText: required ? '$label *' : label,
    border: const OutlineInputBorder(),
  ),
);

class _FileField extends StatelessWidget {
  const _FileField({required this.label, required this.onPick});
  final String label;
  final VoidCallback onPick;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPick,
    icon: const Icon(Icons.upload_file_outlined),
    label: Text(label, overflow: TextOverflow.ellipsis),
  );
}
