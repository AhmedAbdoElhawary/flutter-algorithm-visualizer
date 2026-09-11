import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The one dashed-border block in the app — 1px dashed `border`, radius 14,
/// padding `22 x 18`, centred title over a secondary caption.
class EmptyStateQuiet extends StatelessWidget {
  final String title;
  final String? caption;

  const EmptyStateQuiet({super.key, required this.title, this.caption});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: context.getColor(ThemeEnum.border), radius: 14.r),
      child: Container(
        width: double.infinity,
        padding: REdgeInsets.symmetric(horizontal: 22, vertical: 18),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemiBoldText(title, fontSize: 12.5, color: ThemeEnum.textBody, textAlign: TextAlign.center),
            if (caption != null) ...[
              const RSizedBox(height: 6),
              RegularText(
                caption!,
                fontSize: 11,
                color: ThemeEnum.textSecond,
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dashWidth = 4.0;
    const dashGap = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color || old.radius != radius;
}
