import 'package:flutter/material.dart';

import '../constants/app_breakpoints.dart';

/// Keeps desktop and web pages comfortably readable instead of stretching
/// mobile content edge to edge. It is intentionally composable with ListView,
/// CustomScrollView and regular columns.
class AdaptivePage extends StatelessWidget {
  const AdaptivePage({super.key, required this.child, this.maxWidth = 960});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

/// A non-scrolling grid that changes its column count with the available
/// content width. Use this inside a scroll view or a page section.
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.minimumTileWidth = 156,
    this.maximumColumns = 4,
    this.childAspectRatio = 1,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double minimumTileWidth;
  final int maximumColumns;
  final double childAspectRatio;
  final double spacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: AppBreakpoints.gridColumns(
        constraints.maxWidth,
        minimumTileWidth: minimumTileWidth,
        maximumColumns: maximumColumns,
        gap: spacing,
      ),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: children,
    ),
  );
}
