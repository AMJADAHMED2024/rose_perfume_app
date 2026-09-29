import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_skeleton.dart';
import '../data/admin_product_images_repository.dart';

final adminProductImagesProvider = FutureProvider.autoDispose
    .family<List<AdminProductImage>, int>(
      (ref, id) => ref.watch(adminProductImagesRepositoryProvider).fetch(id),
    );

class AdminProductImagesPage extends ConsumerWidget {
  const AdminProductImagesPage({super.key, required this.productId});
  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(adminProductImagesProvider(productId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('صور المنتج'),
        actions: [
          IconButton(
            onPressed: () =>
                ref.invalidate(adminProductImagesProvider(productId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickAndUpload(context, ref),
        icon: const Icon(Icons.upload_outlined),
        label: const Text('رفع صورة'),
      ),
      body: images.when(
        loading: () => const SkeletonPage(layout: SkeletonLayout.grid),
        error: (_, _) => const Center(child: Text('تعذر تحميل صور المنتج.')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('لا توجد صور بعد.'))
            : GridView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final image = items[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          image.url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.bottomEnd,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () => _pickAndUpload(
                                  context,
                                  ref,
                                  replace: image,
                                ),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () => _delete(context, ref, image),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _pickAndUpload(
    BuildContext context,
    WidgetRef ref, {
    AdminProductImage? replace,
  }) async {
    final selection = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = selection?.files.singleOrNull;
    if (file == null) {
      return;
    }
    try {
      final repo = ref.read(adminProductImagesRepositoryProvider);
      if (replace == null) {
        await repo.upload(productId: productId, file: file);
      } else {
        await repo.replace(
          imageId: replace.id,
          productId: productId,
          file: file,
        );
      }
      ref.invalidate(adminProductImagesProvider(productId));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر حفظ الصورة.')));
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AdminProductImage image,
  ) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الصورة؟'),
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
    if (yes != true) {
      return;
    }
    try {
      await ref.read(adminProductImagesRepositoryProvider).delete(image.id);
      ref.invalidate(adminProductImagesProvider(productId));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر حذف الصورة.')));
      }
    }
  }
}
