import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

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

class _AnimatedPopupOverlayState extends State<_AnimatedPopupOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
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
    _scale = Tween(begin: 0.8, end: 1.0).animate(curve);
    _opacity = Tween(begin: 0.0, end: 1.0).animate(curve);
    _offset = Tween(begin: const Offset(0.0, -0.06), end: Offset.zero).animate(curve);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                final value = Curves.easeOut.transform(_controller.value);
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: value * 12, sigmaY: value * 12),
                  child: Container(color: Colors.black.withValues(alpha: value * 0.2)),
                );
              },
            ),
          ),
        ),
        Center(
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _offset,
              child: ScaleTransition(
                scale: _scale,
                alignment: Alignment.center,
                child: Material(
                  color: Colors.transparent,
                  child: widget.builder(widget.onDismiss),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
