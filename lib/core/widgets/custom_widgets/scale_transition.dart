import 'package:flutter/material.dart';

class CustomScaleTransition extends StatefulWidget {
  const CustomScaleTransition({
    required this.remove,
    required this.child,
    super.key,
  });
  final Widget child;
  final bool remove;
  @override
  State<CustomScaleTransition> createState() => _CustomScaleTransitionState();
}

class _CustomScaleTransitionState extends State<CustomScaleTransition>
    with TickerProviderStateMixin {
  bool remove = false;

  @override
  void didUpdateWidget(covariant CustomScaleTransition oldWidget) {
    if (oldWidget == widget || remove == widget.remove) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        remove = widget.remove;
      });
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: remove ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      child: widget.child,
    );
  }
}
