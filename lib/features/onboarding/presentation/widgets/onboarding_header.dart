import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/onboarding_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Brand mark on the leading edge, Skip on the trailing edge. Fixed 44 px tall
/// and present on every page — Skip must never disappear (spec §1).
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({required this.onSkip, super.key});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AlgoDiveMark(),
          // 44 x 44 minimum target, so the tappable box is sized before the
          // label is centred inside it.
          InkResponse(
            onTap: onSkip,
            radius: 44.r / 2,
            child: SizedBox(
              width: 44.w,
              height: 44.h,
              child: const Center(
                child: MonoText(StringsManager.onboardingSkip, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The AlgoDive mark at header size: a filled cell, two diamond rings and the
/// green destination cell.
class AlgoDiveMark extends StatelessWidget {
  const AlgoDiveMark({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26.r,
      height: 26.r,
      child: CustomPaint(
        painter: _MarkPainter(
          ink: context.getColor(ThemeEnum.inkPrimary),
          green: context.getColor(ThemeEnum.dataEasy),
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.ink, required this.green});

  final Color ink;
  final Color green;

  Path _diamond(Offset c, double r) => Path()
    ..moveTo(c.dx, c.dy - r)
    ..lineTo(c.dx + r, c.dy)
    ..lineTo(c.dx, c.dy + r)
    ..lineTo(c.dx - r, c.dy)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    // Authored on the 512 grid of the brand SVG, then scaled to fit.
    canvas.scale(size.width / 512);
    const c = Offset(256, 256);

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(228, 228, 56, 56), const Radius.circular(8)),
      Paint()..color = ink,
    );
    canvas.drawPath(
      _diamond(c, 104),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 30
        ..strokeJoin = StrokeJoin.round
        ..color = ink,
    );
    canvas.drawPath(
      _diamond(c, 180),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeJoin = StrokeJoin.round
        ..color = ink.withValues(alpha: 0.55),
    );
    // The destination cell — always green, the same "path found" colour the
    // visualizer uses.
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(398, 228, 56, 56), const Radius.circular(8)),
      Paint()..color = green,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.ink != ink || old.green != green;
}
