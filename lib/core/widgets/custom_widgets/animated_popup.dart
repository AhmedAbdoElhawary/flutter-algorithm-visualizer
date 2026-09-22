import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../resources/theme_manager.dart';

typedef PopupBuilder = Widget Function(VoidCallback removeOverlay);

class AnimatedPopup extends StatefulWidget {
  const AnimatedPopup({super.key, required this.child, required this.builder});

  final Widget child;
  final PopupBuilder builder;

  /// Opens the same popup without a [child] to tap.
  ///
  /// For flows that decide whether to ask at all, such as confirming a login
  /// only once the form is valid and there is guest data to lose.
  static void show(BuildContext context, {required PopupBuilder builder}) {
    final rootOverlay = Navigator.of(context, rootNavigator: true).overlay;
    if (rootOverlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _AnimatedPopupOverlay(
        builder: builder,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );

    rootOverlay.insert(entry);
  }

  @override
  State<AnimatedPopup> createState() => _AnimatedPopupState();
}

class _AnimatedPopupState extends State<AnimatedPopup> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AnimatedPopup.show(context, builder: widget.builder),
      child: widget.child,
    );
  }
}

/// The blurred barrier and the entrance animation shared by every popup.
class _AnimatedPopupOverlay extends StatefulWidget {
  const _AnimatedPopupOverlay({required this.builder, required this.onDismiss});

  final PopupBuilder builder;
  final VoidCallback onDismiss;

  @override
  State<_AnimatedPopupOverlay> createState() => _AnimatedPopupOverlayState();
}

class _AnimatedPopupOverlayState extends State<_AnimatedPopupOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _scale = Tween(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic),
    );
    _opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 1.0, curve: Curves.easeOut)),
    );
    _offset = Tween(begin: const Offset(0.0, 0.04), end: Offset.zero).animate(curve);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The height actually left for the dialog once the keyboard has taken its
  /// share of the screen.
  double _availableHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    return media.size.height - media.viewInsets.bottom;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The scrim, and nothing else. It is painted, never tapped — the
        // layer above covers it completely and owns the dismiss gesture.
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              final value = Curves.easeOut.transform(_controller.value);
              // Blur, tint and grid all ride the same value, so the backdrop
              // resolves into focus with the dialog instead of snapping.
              return RepaintBoundary(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: value * 8, sigmaY: value * 8),
                  child: ColoredBox(
                    color: context.getColor(ThemeEnum.ground).withValues(alpha: value * 0.35),
                    child: CustomPaint(
                      painter: _PixelGridPainter(
                        color: context.getColor(ThemeEnum.hairline).withValues(alpha: 0.1),
                        cell: 8.r,
                        opacity: value,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: _availableHeight(context)),
                  child: Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: FadeTransition(
                        opacity: _opacity,
                        child: SlideTransition(
                          position: _offset,
                          child: ScaleTransition(
                            scale: _scale,
                            alignment: Alignment.center,
                            child: Material(
                              color: context.getColor(ThemeEnum.transparentColor),
                              child: widget.builder(widget.onDismiss),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PixelGridPainter extends CustomPainter {
  const _PixelGridPainter({required this.color, required this.cell, required this.opacity});

  final Color color;
  final double cell;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: color.a * opacity * 0.5)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_PixelGridPainter old) =>
      old.opacity != opacity || old.color != color || old.cell != cell;
}
