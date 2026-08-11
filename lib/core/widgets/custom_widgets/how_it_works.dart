import 'dart:ui' show ImageFilter;

import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HowItWorksPopup extends StatefulWidget {
  const HowItWorksPopup({super.key});

  @override
  State<HowItWorksPopup> createState() => _HowItWorksPopupState();
}

class _HowItWorksPopupState extends State<HowItWorksPopup> with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlay;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  void _togglePopup() {
    if (_overlay != null) {
      _removePopup();
    } else {
      _showPopup();
    }
  }

  void _showPopup() {
    _overlay = OverlayEntry(
      builder: (context) {
        final width = MediaQuery.sizeOf(context).width * 0.89;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removePopup,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) {
                    final value = Curves.easeOut.transform(_controller.value);

                    return BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: value * 12,
                        sigmaY: value * 12,
                      ),
                      child: Container(
                        color: Colors.black.withValues(alpha: value * 0.18),
                      ),
                    );
                  },
                ),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(-width, -120.r),
              child: FadeTransition(
                opacity: _opacity,
                child: SlideTransition(
                  position: _offset,
                  child: ScaleTransition(
                    scale: _scale,
                    alignment: Alignment.topRight,
                    child: const Material(
                      color: Colors.transparent,
                      child: _HowItWorks(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
    _controller.forward(from: 0);
  }

  void _removePopup() async {
    if (_overlay == null) return;

    await _controller.reverse();

    _overlay?.remove();
    _overlay = null;
  }

  @override
  void initState() {
    super.initState();

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _scale = Tween(
      begin: 0.15,
      end: 1.0,
    ).animate(curve);

    _opacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(curve);

    _offset = Tween(
      begin: const Offset(0.08, -0.08),
      end: Offset.zero,
    ).animate(curve);
  }

  @override
  void dispose() {
    _removePopup();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _togglePopup,
        child: Icon(
          Icons.lightbulb,
          size: 16.r,
          color: const Color.fromRGBO(213, 209, 17, 1),
        ),
      ),
    );
  }
}

class _HowItWorks extends ConsumerWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.getColor(ThemeEnum.howItWorksColor),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.getColor(ThemeEnum.borderAccent)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '💡 How it works',
                  style: GoogleFonts.inter(
                    color: context.getColor(ThemeEnum.accent),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adjacent elements are compared and swapped if out of order. Each pass bubbles the largest element to the end.',
                  style: GoogleFonts.inter(
                    color: context.textMuted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        PositionedDirectional(
          end: 25.r, // move left/right until it's under the bulb
          bottom: -14.r,
          child: CustomPaint(
            size: Size(26.r, 14.r),
            painter: _PopupArrowPainter(
              fillColor: context.getColor(ThemeEnum.accentBg),
              borderColor: context.getColor(ThemeEnum.borderAccent),
            ),
          ),
        ),
      ],
    );
  }
}

class _PopupArrowPainter extends CustomPainter {
  const _PopupArrowPainter({
    required this.fillColor,
    required this.borderColor,
  });

  final Color fillColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    // Fill
    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // Border
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
