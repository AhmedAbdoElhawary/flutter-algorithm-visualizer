import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/search_role.dart';
import 'package:flutter/material.dart';

class PFGridPainter extends CustomPainter {
  final List<List<bool>> walls;
  final PFStep? step;
  final bool isDark;

  /// Resolved theme colours — the painter has no BuildContext, so the caller
  /// resolves these via `context.getColor(ThemeEnum.x)` and passes them in.
  final Color wallColor;
  final Color pathColor;
  final Color searcherColor;
  final Color searcherFinishedColor;
  final Color gridLineColor;

  final Map<int, double> wallAnimations;
  final Map<int, double> frontierAnimations;
  final Map<int, double> visitedAnimations;
  final Map<int, double> pathAnimations;

  PFGridPainter({
    required this.walls,
    required this.step,
    required this.isDark,
    required this.wallColor,
    required this.pathColor,
    required this.searcherColor,
    required this.searcherFinishedColor,
    required this.gridLineColor,
    required this.wallAnimations,
    required this.frontierAnimations,
    required this.visitedAnimations,
    required this.pathAnimations,
    required Listenable repaint,
  }) : super(repaint: repaint);

  /// One fill paint, reused for every cell.
  ///
  /// `_drawSearcherCell` and `_drawElasticCell` used to allocate a fresh
  /// `Paint` each — on a 24x30 grid that was up to 720 short-lived objects per
  /// frame, and this painter runs at frame rate for the length of a search.
  /// The colour is the only thing that varied, and a colour is a field.
  final Paint _cellPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    /// Wall-clock, not the ticker's value, because the animation stamps in the
    /// four maps are wall-clock too. The ticker is now stopped between
    /// animations, so its own value would stall while these timestamps keep
    /// ageing — reading the clock keeps a repaint triggered by something else
    /// (a theme change, a rebuild) drawing the settled state rather than a
    /// frozen mid-animation one.
    final double now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final cellW = size.width / kPFCols;
    final cellH = size.height / kPFRows;

    final path = step?.path;
    final pathIndex = <int, int>{
      if (path != null)
        for (int i = 0; i < path.length; i++) path[i]: i,
    };

    final gridPaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int row = 0; row < kPFRows; row++) {
      for (int col = 0; col < kPFCols; col++) {
        final rect = Rect.fromLTWH(col * cellW, row * cellH, cellW, cellH);
        canvas.drawRect(rect, gridPaint);

        final encoded = pfEncode(row, col);
        final role = _roleFor(encoded, walls[row][col]);
        if (role == null) continue;

        switch (role) {
          case SearchRole.path:
            // The path draws itself out from start to end: each cell waits its
            // ordered turn before its own 500 ms pop begins.
            final startT = (pathAnimations[encoded] ?? now) + pathIndex[encoded]! * kPathStaggerMs;
            if (now < startT) continue;
            _drawElasticCell(canvas, rect, (now - startT) / 500.0, pathColor);
          case SearchRole.visited:
            final startT = visitedAnimations[encoded];
            final t = startT != null ? ((now - startT) / 1500.0) : 1.0;
            _drawSearcherCell(canvas, rect, t, isFinalVisited: true);
          case SearchRole.frontier:
            final startT = frontierAnimations[encoded];
            final t = startT != null ? ((now - startT) / 1500.0) : 1.0;
            _drawSearcherCell(canvas, rect, t, isFinalVisited: false);
          case SearchRole.wall:
            final startT = wallAnimations[encoded];
            final t = startT != null ? ((now - startT) / 500.0) : 1.0;
            _drawElasticCell(canvas, rect, t, wallColor);
          case SearchRole.start:
          case SearchRole.end:
            break; // drawn as marker widgets above the canvas
        }
      }
    }
  }

  /// The role this cell paints as. [SearchRole.path] always wins, regardless
  /// of its position in [kSearchRolePriority] (that list only orders the
  /// legend) — so a path cell paints as path even though it is also visited.
  /// Every other role falls back to list order.
  SearchRole? _roleFor(int encoded, bool isWall) {
    if (step?.path?.contains(encoded) == true) return SearchRole.path;

    for (final role in kSearchRolePriority) {
      final present = switch (role) {
        SearchRole.path => false,
        SearchRole.frontier => step?.frontier.contains(encoded) == true,
        SearchRole.visited => step?.visited.contains(encoded) == true,
        SearchRole.wall => isWall,
        SearchRole.start || SearchRole.end => false,
      };
      if (present) return role;
    }
    return null;
  }

  void _drawSearcherCell(Canvas canvas, Rect rect, double t, {required bool isFinalVisited}) {
    t = t.clamp(0.0, 1.0);

    double scale;
    if (t < 0.6) {
      scale = 0.1 + (1.4 - 0.1) * Curves.easeInOut.transform(t / 0.6);
    } else {
      scale = 1.4 + (1.0 - 1.4) * Curves.easeInOut.transform((t - 0.6) / 0.4);
    }

    double shape = 0.0;
    if (t <= 0.1) {
      shape = 1.0;
    } else if (t >= 0.65) {
      shape = 0.0;
    } else {
      shape = 1.0 - Curves.easeInOut.transform((t - 0.1) / 0.55);
    }
    Color color;
    if (t < 0.4) {
      color = Color.lerp(searcherColor.withValues(alpha: 0), searcherColor, t / 0.4)!;
    } else if (t <= 0.5) {
      double localT = (t - 0.3) / 0.2;
      color = Color.lerp(searcherColor, searcherColor, localT)!;
    } else if (t <= 0.8) {
      double localT = (t - 0.5) / 0.3;
      color = Color.lerp(searcherColor, isFinalVisited ? searcherFinishedColor : searcherColor, localT)!;
    } else {
      color = isFinalVisited ? searcherFinishedColor : searcherColor;
    }

    final center = rect.center;
    final width = rect.width * scale;
    final height = rect.height * scale;
    final scaledRect = Rect.fromCenter(center: center, width: width, height: height);

    final radius = shape * (width / 2);
    final rrect = RRect.fromRectAndRadius(scaledRect.deflate(0.5), Radius.circular(radius));

    canvas.drawRRect(rrect, _cellPaint..color = color);
  }

  void _drawElasticCell(Canvas canvas, Rect rect, double t, Color color) {
    t = t.clamp(0.0, 1.0);
    double scale = 0.1 + 0.9 * Curves.elasticOut.transform(t);

    final center = rect.center;
    final width = rect.width * scale;
    final height = rect.height * scale;
    final scaledRect = Rect.fromCenter(center: center, width: width, height: height);

    canvas.drawRect(scaledRect.deflate(0.5), _cellPaint..color = color);
  }

  /// Stays `true`, deliberately.
  ///
  /// The four animation maps are mutable and handed in by reference, so the
  /// old delegate holds *the same* map objects as the new one — a field
  /// comparison could never see a change in them and would wrongly skip
  /// repaints. What made the old code wasteful was not this returning `true`,
  /// it was the 365-day controller on the other end of `repaint` calling it
  /// sixty times a second forever. That ticker now stops when the grid
  /// settles, so this only runs when the widget actually rebuilds.
  @override
  bool shouldRepaint(covariant PFGridPainter oldDelegate) => true;
}
