import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/search_role.dart';
import 'package:flutter/material.dart';

class PFGridPainter extends CustomPainter {
  final List<List<bool>> walls;
  final PFStep? step;
  final bool isDark;

  final int? searcherCell;

  final int? searcherFrom;
  final double searcherMoveAt;

  final double searcherJumpMs;

  final Color wallColor;
  final Color pathColor;
  final Color searcherColor;
  final Color trail0Color;
  final Color trail1Color;
  final Color visitedColor;
  final Color gridLineColor;

  final Map<int, double> wallAnimations;
  final Map<int, double> visitedAnimations;
  final Map<int, double> pathAnimations;

  PFGridPainter({
    required this.walls,
    required this.step,
    required this.isDark,
    required this.searcherCell,
    required this.searcherFrom,
    required this.searcherMoveAt,
    required this.searcherJumpMs,
    required this.wallColor,
    required this.pathColor,
    required this.searcherColor,
    required this.trail0Color,
    required this.trail1Color,
    required this.visitedColor,
    required this.gridLineColor,
    required this.wallAnimations,
    required this.visitedAnimations,
    required this.pathAnimations,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final Paint _cellPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
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
      ..strokeWidth = kGridLineWidth
      ..style = PaintingStyle.stroke;

    final filledGridPaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = kFilledGridLineWidth
      ..style = PaintingStyle.stroke;

    for (int row = 0; row < kPFRows; row++) {
      for (int col = 0; col < kPFCols; col++) {
        final rect = Rect.fromLTWH(col * cellW, row * cellH, cellW, cellH);

        final encoded = pfEncode(row, col);
        final role = _roleFor(encoded, walls[row][col]);
        canvas.drawRect(rect, role == null ? gridPaint : filledGridPaint);
        if (role == null) continue;

        switch (role) {
          case SearchRole.path:
            final released = visitedAnimations[encoded];
            final elapsed = released != null ? now - released : kReleaseTotalMs;

            final startT = (pathAnimations[encoded] ?? now) + pathIndex[encoded]! * kPathStaggerMs;
            final tint = Curves.easeOut.transform(((now - startT) / kPathTintMs).clamp(0.0, 1.0));

            _drawReleasedCell(canvas, rect, elapsed,
                color: Color.lerp(_releaseColor(elapsed), pathColor, tint)!);
          case SearchRole.visited:
            if (encoded == searcherCell) {
              final at = _searcherRect(rect, cellW, cellH, now);
              canvas.drawRect(at.deflate(0.5), _cellPaint..color = searcherColor);
              break;
            }
            final startT = visitedAnimations[encoded];
            _drawReleasedCell(canvas, rect, startT != null ? now - startT : kReleaseTotalMs);
          case SearchRole.wall:
            final startT = wallAnimations[encoded];
            final t = startT != null ? ((now - startT) / kWallPopMs) : 1.0;
            _drawElasticCell(canvas, rect, t, wallColor);
          case SearchRole.searcher:
          case SearchRole.start:
          case SearchRole.end:
            break;
        }
      }
    }
  }

  SearchRole? _roleFor(int encoded, bool isWall) {
    if (step?.path?.contains(encoded) == true) return SearchRole.path;

    for (final role in kSearchRolePriority) {
      final present = switch (role) {
        SearchRole.path => false,
        SearchRole.searcher => false,
        SearchRole.visited => step?.visited.contains(encoded) == true,
        SearchRole.wall => isWall,
        SearchRole.start || SearchRole.end => false,
      };
      if (present) return role;
    }
    return null;
  }

  Rect _searcherRect(Rect target, double cellW, double cellH, double now) {
    final from = searcherFrom;
    if (from == null || searcherJumpMs <= 0) return target;

    final t = (now - searcherMoveAt) / searcherJumpMs;
    if (t >= 1) return target;

    final origin = Rect.fromLTWH(
      pfDecodeCol(from) * cellW,
      pfDecodeRow(from) * cellH,
      cellW,
      cellH,
    );
    return Rect.lerp(origin, target, Curves.easeOut.transform(t.clamp(0.0, 1.0)))!;
  }

  Color _releaseColor(double elapsed) {
    if (elapsed < kReleaseTrailMs) {
      return Color.lerp(trail0Color, trail1Color, Curves.easeInCubic.transform(elapsed / kReleaseTrailMs))!;
    }
    final settling = (elapsed - kReleaseTrailMs) / kReleaseVisitedMs;
    if (settling >= 1) return visitedColor;
    return Color.lerp(trail1Color, visitedColor, Curves.easeInOut.transform(settling))!;
  }

  double _releaseScale(double elapsed) {
    if (elapsed < kReleaseGrowMs) {
      final t = Curves.easeOut.transform(elapsed / kReleaseGrowMs);
      return kReleaseStartScale + (kReleaseOvershootScale - kReleaseStartScale) * t;
    }
    final settling = (elapsed - kReleaseGrowMs) / kReleaseSettleMs;
    if (settling >= 1) return 1.0;
    return kReleaseOvershootScale + (1.0 - kReleaseOvershootScale) * Curves.easeInOut.transform(settling);
  }

  void _drawReleasedCell(Canvas canvas, Rect rect, double elapsed, {Color? color}) {
    final scale = _releaseScale(elapsed);
    final width = rect.width * scale;
    final height = rect.height * scale;
    final scaledRect = Rect.fromCenter(center: rect.center, width: width, height: height);

    final square = Curves.easeOut.transform((elapsed / kReleaseGrowMs).clamp(0.0, 1.0));
    final rrect = RRect.fromRectAndRadius(
      scaledRect.deflate(0.5),
      Radius.circular((1 - square) * (width / 2)),
    );

    canvas.drawRRect(rrect, _cellPaint..color = color ?? _releaseColor(elapsed));
  }

  void _drawElasticCell(Canvas canvas, Rect rect, double t, Color color) {
    t = t.clamp(0.0, 1.0);
    final scale = kPopStartScale + (1 - kPopStartScale) * Curves.elasticOut.transform(t);

    final center = rect.center;
    final width = rect.width * scale;
    final height = rect.height * scale;
    final scaledRect = Rect.fromCenter(center: center, width: width, height: height);

    canvas.drawRect(scaledRect.deflate(0.5), _cellPaint..color = color);
  }

  @override
  bool shouldRepaint(covariant PFGridPainter oldDelegate) => true;
}
