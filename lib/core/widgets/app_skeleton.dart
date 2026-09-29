import 'package:flutter/material.dart';

import 'adaptive_layout.dart';

/// A small, dependency-free loading system shared by every feature.
///
/// Use [SkeletonPage] for initial page loads and [SkeletonBox] when a feature
/// needs a placeholder that mirrors a specific control. Keeping the motion and
/// colours here gives the application one predictable loading language.
enum SkeletonLayout { list, form, dashboard, grid, details }

class SkeletonPage extends StatelessWidget {
  const SkeletonPage({super.key, this.layout = SkeletonLayout.list});

  final SkeletonLayout layout;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: AppSkeleton(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: switch (layout) {
          SkeletonLayout.list => const [_ListSkeleton()],
          SkeletonLayout.form => const [_FormSkeleton()],
          SkeletonLayout.dashboard => const [_DashboardSkeleton()],
          SkeletonLayout.grid => const [_GridSkeleton()],
          SkeletonLayout.details => const [_DetailsSkeleton()],
        },
      ),
    ),
  );
}

class AppSkeleton extends StatefulWidget {
  const AppSkeleton({super.key, required this.child});
  final Widget child;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFFECE4E1),
            Color(0xFFFFFBF8),
            Color(0xFFECE4E1),
          ],
          stops: const [0.15, 0.5, 0.85],
          transform: _SkeletonGradientTransform(_controller.value),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 12,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFECE4E1),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Small placeholder for an in-place action, such as saving or refreshing.
class SkeletonInline extends StatelessWidget {
  const SkeletonInline({super.key, this.size = 18});
  final double size;

  @override
  Widget build(BuildContext context) => AppSkeleton(
    child: SizedBox(
      width: size,
      height: size,
      child: SkeletonBox(height: size, radius: size / 3),
    ),
  );
}

/// Compact list placeholder for loading content inside an existing scroll view.
/// Unlike [SkeletonPage], it never creates its own viewport.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 4});
  final int count;

  @override
  Widget build(BuildContext context) => AppSkeleton(
    child: Column(
      children: [
        for (var index = 0; index < count; index++) ...[
          const _ListTileSkeleton(),
          if (index != count - 1) const SizedBox(height: 12),
        ],
      ],
    ),
  );
}

/// Compact product/card grid placeholder for an existing scroll view.
class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({super.key, this.count = 4});
  final int count;

  @override
  Widget build(BuildContext context) => AppSkeleton(
    child: AdaptiveGrid(
      minimumTileWidth: 150,
      childAspectRatio: .61,
      spacing: 14,
      children: List.generate(
        count,
        (_) => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: 170, radius: 20),
            SizedBox(height: 12),
            SkeletonBox(width: 105, height: 14, radius: 6),
            SizedBox(height: 8),
            SkeletonBox(width: 72, height: 12, radius: 6),
          ],
        ),
      ),
    ),
  );
}

class _SkeletonGradientTransform extends GradientTransform {
  const _SkeletonGradientTransform(this.progress);
  final double progress;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(
        -bounds.width + (bounds.width * 2 * progress),
        0,
        0,
      );
}

class _SkeletonHeading extends StatelessWidget {
  const _SkeletonHeading();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SkeletonBox(width: 156, height: 26, radius: 8),
      SizedBox(height: 10),
      SkeletonBox(width: 230, height: 14, radius: 6),
    ],
  );
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SkeletonHeading(),
      const SizedBox(height: 24),
      for (var index = 0; index < 5; index++) ...[
        const _ListTileSkeleton(),
        const SizedBox(height: 12),
      ],
    ],
  );
}

class _ListTileSkeleton extends StatelessWidget {
  const _ListTileSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    height: 92,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFECE4E1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      children: [
        SkeletonBox(width: 54, height: 54, radius: 16),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonBox(width: 150, height: 15, radius: 6),
              SizedBox(height: 9),
              SkeletonBox(width: 105, height: 12, radius: 6),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FormSkeleton extends StatelessWidget {
  const _FormSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SkeletonHeading(),
      const SizedBox(height: 30),
      for (var index = 0; index < 4; index++) ...[
        const SkeletonBox(height: 58, radius: 16),
        const SizedBox(height: 14),
      ],
      const SizedBox(height: 8),
      const SkeletonBox(height: 54, radius: 16),
    ],
  );
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SkeletonBox(height: 152, radius: 26),
      const SizedBox(height: 20),
      AdaptiveGrid(
        minimumTileWidth: 150,
        childAspectRatio: 1.35,
        children: List.generate(
          4,
          (_) => const SkeletonBox(height: 100, radius: 20),
        ),
      ),
      const SizedBox(height: 24),
      const _SkeletonHeading(),
      const SizedBox(height: 16),
      const _ListTileSkeleton(),
    ],
  );
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SkeletonHeading(),
      const SizedBox(height: 24),
      const SkeletonGrid(count: 6),
    ],
  );
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SkeletonBox(height: 300, radius: 24),
      SizedBox(height: 24),
      SkeletonBox(width: 190, height: 26, radius: 8),
      SizedBox(height: 12),
      SkeletonBox(width: 100, height: 18, radius: 7),
      SizedBox(height: 20),
      SkeletonBox(height: 14, radius: 6),
      SizedBox(height: 8),
      SkeletonBox(width: 250, height: 14, radius: 6),
      SizedBox(height: 28),
      SkeletonBox(height: 54, radius: 16),
    ],
  );
}
