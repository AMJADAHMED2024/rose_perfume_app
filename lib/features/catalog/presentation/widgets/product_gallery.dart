import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/widgets/app_skeleton.dart';

class ProductGallery extends StatefulWidget {
  const ProductGallery({super.key, required this.images, required this.label});
  final List<String> images;
  final String label;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  late final PageController _pageController;
  var _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select(int index) {
    setState(() => _activeIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    if (images.isEmpty) {
      return const _EmptyGallery();
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) =>
                        setState(() => _activeIndex = index),
                    itemBuilder: (_, index) => InteractiveViewer(
                      minScale: 1,
                      maxScale: 3,
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: _url(images[index]),
                          fit: BoxFit.contain,
                          placeholder: (_, _) => const AppSkeleton(
                            child: SizedBox(
                              width: 220,
                              height: 220,
                              child: SkeletonBox(height: 220, radius: 20),
                            ),
                          ),
                          errorWidget: (_, _, _) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: 72,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (images.length > 1)
                    PositionedDirectional(
                      bottom: 10,
                      end: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Text(
                            '${_activeIndex + 1} / ${images.length}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (images.length > 1) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 68,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final selected = index == _activeIndex;
                    return Semantics(
                      button: true,
                      selected: selected,
                      label: '${widget.label}، الصورة ${index + 1}',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _select(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 68,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: _url(images[index]),
                            fit: BoxFit.contain,
                            errorWidget: (_, _, _) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) => Card(
    child: Center(
      child: Icon(
        Icons.image_outlined,
        size: 80,
        color: Theme.of(context).colorScheme.outline,
      ),
    ),
  );
}

String _url(String path) =>
    path.startsWith('http') ? path : '${AppConfig.apiBaseUrl}$path';
