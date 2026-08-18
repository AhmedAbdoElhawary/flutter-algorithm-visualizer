import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/widgets/pf_grid.dart';
import 'package:flutter/material.dart';

class PFGridPainter extends CustomPainter {
  final List<List<bool>> walls;
  final PFStep? step;
  final bool isDark;

  final Map<int, double> wallAnims;
  final Map<int, double> frontierAnims;
  final Map<int, double> visitedAnims;
  final Map<int, double> pathAnims;

  PFGridPainter({
    required this.walls,
    required this.step,
    required this.isDark,
    required this.wallAnims,
    required this.frontierAnims,
    required this.visitedAnims,
    required this.pathAnims,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final double now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final cellW = size.width / kPFCells;
    final cellH = size.height / kPFCells;

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.07)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int row = 0; row < kPFCells; row++) {
      for (int col = 0; col < kPFCells; col++) {
        final left = col * cellW;
        final top = row * cellH;
        final rect = Rect.fromLTWH(left, top, cellW, cellH);

        final encoded = pfEncode(row, col);
        final isWall = walls[row][col];
        final isPath = step?.path?.contains(encoded) == true;
        final isFrontier = step?.frontier.contains(encoded) == true;
        final isVisited = step?.visited.contains(encoded) == true;

        canvas.drawRect(rect, gridPaint);

        if (isPath) {
          final startT = pathAnims[encoded];
          final t = startT != null ? ((now - startT) / 500.0) : 1.0;
          _drawElasticCell(canvas, rect, t, kPathGridColor);
        } else if (isVisited) {
          final startT = visitedAnims[encoded];
          final t = startT != null ? ((now - startT) / 1500.0) : 1.0;
          _drawSearcherCell(canvas, rect, t, isFinalVisited: true);
        } else if (isFrontier) {
          final startT = frontierAnims[encoded];
          final t = startT != null ? ((now - startT) / 1500.0) : 1.0;
          _drawSearcherCell(canvas, rect, t, isFinalVisited: false);
        } else if (isWall) {
          final startT = wallAnims[encoded];
          final t = startT != null ? ((now - startT) / 500.0) : 1.0;
          _drawElasticCell(canvas, rect, t, kWallGridColor);
        }
      }
    }
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
      color = Color.lerp(ColorManager.transparent, kSearcherStartColor, t / 0.4)!;
    } else if (t <= 0.5) {
      double localT = (t - 0.3) / 0.2;
      color = Color.lerp(kSearcherStartColor, kSearcherMediumColor, localT)!;
    } else if (t <= 0.8) {
      double localT = (t - 0.5) / 0.3;
      color = Color.lerp(
          kSearcherMediumColor, isFinalVisited ? kSearcherFinishedColor : kSearcherMediumColor, localT)!;
    } else {
      color = isFinalVisited ? kSearcherFinishedColor : kSearcherMediumColor;
    }

    final center = rect.center;
    final width = rect.width * scale;
    final height = rect.height * scale;
    final scaledRect = Rect.fromCenter(center: center, width: width, height: height);

    final radius = shape * (width / 2);
    final rrect = RRect.fromRectAndRadius(scaledRect.deflate(0.5), Radius.circular(radius));

    canvas.drawRRect(rrect, Paint()..color = color);
  }

  void _drawElasticCell(Canvas canvas, Rect rect, double t, Color color) {
    t = t.clamp(0.0, 1.0);
    double scale = 0.1 + 0.9 * Curves.elasticOut.transform(t);

    final center = rect.center;
    final width = rect.width * scale;
    final height = rect.height * scale;
    final scaledRect = Rect.fromCenter(center: center, width: width, height: height);

    canvas.drawRect(scaledRect.deflate(0.5), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant PFGridPainter oldDelegate) => true;
}
