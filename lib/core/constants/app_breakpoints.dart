abstract final class AppBreakpoints {
  static const compact = 600.0;
  static const tablet = 720.0;
  static const medium = 1024.0;
  static const expanded = 1440.0;

  /// Chooses stable grid density for phones, tablets and desktop windows.
  static int gridColumns(
    double width, {
    double minimumTileWidth = 156,
    int maximumColumns = 4,
    double gap = 0,
  }) {
    // Account for the gaps between tiles as well. Without this, a row can
    // select an extra column whose cards no longer fit at the breakpoint.
    final columns = ((width + gap) / (minimumTileWidth + gap)).floor();
    return columns.clamp(1, maximumColumns);
  }
}
