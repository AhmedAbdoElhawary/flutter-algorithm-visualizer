import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChallengesLoadingState extends StatelessWidget {
  const ChallengesLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.fromLTRB(16, 0, 16, 0),
      child: ListView.builder(itemCount: 20, itemBuilder: (ctx, i) => const ProblemTileShimmer()),
    );
  }
}

class ProblemTileShimmer extends StatelessWidget {
  const ProblemTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.only(bottom: 6),
      child: Container(
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.surface),
          borderRadius: BorderRadius.circular(CdRadius.medium.r),
          border: Border.all(color: context.getColor(ThemeEnum.hairline)),
        ),
        clipBehavior: Clip.hardEdge,
        child: _MainRowShimmer(),
      ),
    );
  }
}

class _MainRowShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(horizontal: 14, vertical: 15),
      child: const Row(
        children: [
          _ShimmerBox(width: 16, height: 16),
          RSizedBox(width: 8),
          _ShimmerBox(width: 20, height: 13),
          RSizedBox(width: 6),
          Expanded(child: _ShimmerBox(height: 15)),
          RSizedBox(width: 6),
          _ShimmerBox(width: 40, height: 13),
          RSizedBox(width: 6),
          _ShimmerBox(width: 16, height: 16),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;

  const _ShimmerBox({this.width, this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    // No gradient sweep — a flat glass fill that breathes in opacity. Aurora
    // rule: skeletons carry meaning through fill and opacity only.
    _animation = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    /// The reduce-motion dim is baked into the fill colour rather than layered
    /// on with an [Opacity]. A skeleton screen builds twenty of these at once,
    /// so that wrapper was twenty off-screen buffers for a flat grey box —
    /// and unlike the [FadeTransition] below it never animated, it was just a
    /// dimmer shade that had been written the expensive way.
    final box = Container(
      width: widget.width?.r,
      height: widget.height?.r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CdRadius.tiny.r),
        color: context.getColor(ThemeEnum.hairline).withValues(alpha: reduceMotion ? 0.65 : 1),
      ),
    );

    if (reduceMotion) return box;

    return FadeTransition(opacity: _animation, child: box);
  }
}
