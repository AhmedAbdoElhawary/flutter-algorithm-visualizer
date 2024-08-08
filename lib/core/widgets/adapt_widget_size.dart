import 'package:flutter/material.dart';

class AdaptWidgetSize extends StatelessWidget {
  const AdaptWidgetSize({required this.builder, super.key});
  final Widget Function(double adaptSize) builder;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth > constraints.maxHeight
            ? constraints.maxHeight
            : constraints.maxWidth;

        final newSize = size * 0.35;
        final adapt = newSize > 50 ? 80.0 : newSize;

        return builder(adapt);
      },
    );
  }
}
