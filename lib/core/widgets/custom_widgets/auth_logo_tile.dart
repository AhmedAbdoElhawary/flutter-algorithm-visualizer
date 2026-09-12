import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 60px logo tile — CoreDive screen 11, the three-strata mark in ink on the
/// shared [CdSurface.main] card. The mark is a symbol: it never mirrors in RTL.
class AuthLogoTile extends StatelessWidget {
  const AuthLogoTile({super.key});

  @override
  Widget build(BuildContext context) {
    final side = 60.r;
    return CardContainer(
      surface: CdSurface.main,
      radius: CdRadius.lg,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: side,
        height: side,
        child: Center(
          child: CustomPaint(
            size: Size(32.r, 32.r),
            painter: _CoreDiveLogoMark(color: context.getColor(ThemeEnum.textPrimary)),
          ),
        ),
      ),
    );
  }
}

/// 56px tinted tile with a recovery glyph — CoreDive screen 12.
class AuthRecoveryTile extends StatelessWidget {
  const AuthRecoveryTile({super.key});

  @override
  Widget build(BuildContext context) {
    final side = 56.r;
    return Container(
      width: side,
      height: side,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.primaryTint),
        borderRadius: BorderRadius.circular(CdRadius.lg.r),
        border: Border.all(color: context.getColor(ThemeEnum.borderAccent)),
      ),
      child: const CustomIcon(
        Icons.key_rounded,
        size: 26,
        color: ThemeEnum.primaryHover,
      ),
    );
  }
}

class _CoreDiveLogoMark extends CustomPainter {
  const _CoreDiveLogoMark({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2 * unit
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Three horizontal strata: y 6.5 / 12 / 17.5, widths 16 / 11 / 6.
    canvas.drawLine(Offset(4 * unit, 6.5 * unit), Offset(20 * unit, 6.5 * unit), paint);
    canvas.drawLine(Offset(6.5 * unit, 12 * unit), Offset(17.5 * unit, 12 * unit), paint);
    canvas.drawLine(Offset(9 * unit, 17.5 * unit), Offset(15 * unit, 17.5 * unit), paint);
  }

  @override
  bool shouldRepaint(_CoreDiveLogoMark oldDelegate) => oldDelegate.color != color;
}
