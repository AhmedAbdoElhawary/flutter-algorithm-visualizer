import 'package:flutter/material.dart';

class VerticalAnimationHeroPage extends StatefulWidget {
  const VerticalAnimationHeroPage({
    required this.onSwipe,
    required this.child,
    super.key,
  });
  final VoidCallback onSwipe;
  final Widget child;
  @override
  State<VerticalAnimationHeroPage> createState() =>
      _VerticalAnimationHeroPageState();
}

class _VerticalAnimationHeroPageState extends State<VerticalAnimationHeroPage> {
  final ScrollController controller = ScrollController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (event) {
        double offset = controller.offset;
        if (offset < 0) offset = offset * -1;
        if (offset > 50) widget.onSwipe();
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        controller: controller,
        slivers: [
          SliverFillRemaining(child: widget.child),
          const SliverToBoxAdapter(child: SizedBox(height: 1)),
        ],
      ),
    );
  }
}
