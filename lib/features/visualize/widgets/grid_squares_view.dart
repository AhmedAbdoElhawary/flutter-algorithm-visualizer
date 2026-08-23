import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GridSquaresView extends StatelessWidget {
  const GridSquaresView({
    this.makeThemPerfectGrids = true,
    required this.estimatedHeight,
    required this.squareSize,
    required this.child,
    super.key,
  });

  /// if [makeThemPerfectGrids] true,
  ///
  /// the [estimatedHeight] will decreased or increased based on the perfect grid size,
  ///
  /// otherwise the [estimatedHeight] will be used as it is

  final double estimatedHeight;
  final int squareSize;
  final Widget child;
  final bool makeThemPerfectGrids;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, estimatedHeight);
        final perfectSize = makeThemPerfectGrids
            ? GridSquaresPainter.calculateSizeForPerfectGrid(defaultSize: size, squareSize: squareSize)
            : size;

        return SizedBox(
          height: perfectSize.height,
          width: perfectSize.width,
          child: CustomPaint(
            size: perfectSize,
            painter: GridSquaresPainter(
              backgroundColor: context.getColor(ThemeEnum.backgroundForSortingColor),
              borderColor: context.getColor(ThemeEnum.border),
              squareSize: squareSize,
              height: perfectSize.height,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// [GridSquaresPainter] if you want to make it perfect grid, use [calculateSizeForPerfectGrid]
class GridSquaresPainter extends CustomPainter {
  const GridSquaresPainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.height,
    this.circularRadius = 20,
    this.squareSize = 12,
  });

  final Color backgroundColor;
  final Color borderColor;
  final double circularRadius;
  final int squareSize;
  final double height;

  static Size calculateSizeForPerfectGrid({required Size defaultSize, required int squareSize}) {
    final height = defaultSize.height;

    final tempSizeDy = height / squareSize;
    final tempSizeDx = defaultSize.width / squareSize;

    ///determine based on width always, and height changed to fit the perfect square
    final finalSquareSize = tempSizeDx;

    final h = height % finalSquareSize;

    /// height increased by square size if it's smaller than width,
    /// else height decreased by square size if it's larger than width
    final finalHeight = tempSizeDy < tempSizeDx ? (height + (finalSquareSize - h)) : (height - h);

    return Size(defaultSize.width, finalHeight);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final borderWidth = 1.r;
    final squareSize = this.squareSize.r;

    final tempSizeDx = size.width / squareSize;
    final finalSquareSize = tempSizeDx;

    final height = this.height;
    final width = size.width;

    final mainPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // main background and corner radius
    final mainRect =
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, width, height), Radius.circular(circularRadius));

    canvas.drawRRect(mainRect, mainPaint);

    //border
    final borderPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.015)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(mainRect, borderPaint);
    canvas.clipRRect(mainRect);

    // square grid
    final path = Path();

    for (double dy = 0; dy <= height; dy = dy + finalSquareSize) {
      for (double dx = 0; dx <= width; dx = dx + finalSquareSize) {
        final square = Rect.fromLTWH(dx, dy, finalSquareSize, finalSquareSize);

        path.addRect(square);
      }
    }
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant GridSquaresPainter oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor ||
        borderColor != oldDelegate.borderColor ||
        squareSize != oldDelegate.squareSize ||
        circularRadius != oldDelegate.circularRadius ||
        height != oldDelegate.height;
  }
}
