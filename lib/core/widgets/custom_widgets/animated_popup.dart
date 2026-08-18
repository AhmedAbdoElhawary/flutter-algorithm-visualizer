import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimatedPopup extends ConsumerStatefulWidget {
  const AnimatedPopup({super.key, required this.child, required this.builder});

  final Widget child;
  final Widget Function(VoidCallback removeOverlay) builder;
  @override
  ConsumerState<AnimatedPopup> createState() => _CodeEditorLangBarState();
}

class _CodeEditorLangBarState extends ConsumerState<AnimatedPopup> with SingleTickerProviderStateMixin {
  OverlayEntry? _overlay;
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
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    if (_overlay == null) return;
    _controller.reverse();
    _overlay?.remove();
    _overlay = null;
  }

  void _showResetPopup() {
    _overlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeOverlay,
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
                      child: widget.builder(_removeOverlay),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    final rootOverlay = Navigator.of(context, rootNavigator: true).overlay!;
    rootOverlay.insert(_overlay!);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showResetPopup(),
      child: widget.child,
    );
  }
}
