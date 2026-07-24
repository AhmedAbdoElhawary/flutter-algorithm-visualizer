import 'package:flutter/material.dart';

import '../models/pf_constants.dart';
import '../models/pf_step.dart';

class PFGridPainter extends CustomPainter {
  final List<List<bool>> walls;
  final PFStep? step;
  final bool isDark;
  final Color accent;
  final Color accentGreen;
  final Color accentYellow;
  final Color accentBlue;
  final Color accentRed;

  const PFGridPainter({
    required this.walls,
    required this.step,
    required this.isDark,
    required this.accent,
    required this.accentGreen,
    required this.accentYellow,
    required this.accentBlue,
    required this.accentRed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / kPFCols;
    final cellH = size.height / kPFRows;

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.07)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final wallColor = isDark ? const Color(0xFF1E2D4A) : const Color(0xFF334155);
    final pathGlow = Paint()
      ..color = accent.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int row = 0; row < kPFRows; row++) {
      for (int col = 0; col < kPFCols; col++) {
        final left = col * cellW;
        final top = row * cellH;
        final rect = Rect.fromLTWH(left, top, cellW, cellH);
        final inner = rect.deflate(0.5);

        final encoded = pfEncode(row, col);
        final isStart = row == kPFStartRow && col == kPFStartCol;
        final isEnd = row == kPFEndRow && col == kPFEndCol;
        final isWall = walls[row][col];
        final isPath = step?.path?.contains(encoded) == true;
        final isFrontier = step?.frontier.contains(encoded) == true;
        final isVisited = step?.visited.contains(encoded) == true;

        final fill = _fillFor(
          isStart: isStart,
          isEnd: isEnd,
          isWall: isWall,
          isPath: isPath,
          isFrontier: isFrontier,
          isVisited: isVisited,
          wallColor: wallColor,
        );

        if (fill != null) {
          if (isPath && !isStart && !isEnd) {
            canvas.drawRect(inner.inflate(0.5), pathGlow);
          }
          canvas.drawRect(inner, Paint()..color = fill);
        }

        canvas.drawRect(rect, gridPaint);

        if (isStart || isEnd) {
          _paintLabel(canvas, isStart ? 'S' : 'E', left, top, cellW, cellH);
        }
      }
    }
  }

  Color? _fillFor({
    required bool isStart,
    required bool isEnd,
    required bool isWall,
    required bool isPath,
    required bool isFrontier,
    required bool isVisited,
    required Color wallColor,
  }) {
    if (isStart) return accentGreen;
    if (isEnd) return accentRed;
    if (isWall) return wallColor;
    if (isPath) return accent;
    if (isFrontier) return accentBlue.withValues(alpha: 0.65);
    if (isVisited) return accentYellow.withValues(alpha: 0.40);
    return null;
  }

  void _paintLabel(Canvas canvas, String label, double left, double top, double cellW, double cellH) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: cellW * 0.48,
          fontWeight: FontWeight.w800,
          fontFamily: 'JetBrains Mono',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(left + (cellW - textPainter.width) / 2, top + (cellH - textPainter.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant PFGridPainter oldDelegate) => true;
}
