import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SliverChallengesLoadingState extends StatelessWidget {
  const SliverChallengesLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: REdgeInsets.fromLTRB(16, 0, 16, 60),
      sliver: SliverList.builder(itemCount: 20, itemBuilder: (ctx, i) => const ProblemTileShimmer()),
    );
  }
}

class ChallengesLoadingState extends StatelessWidget {
  const ChallengesLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.fromLTRB(16, 0, 16, 60),
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
          color: context.getColor(ThemeEnum.card),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.getColor(ThemeEnum.border)),
          boxShadow: context.cardShadow,
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
      child: Row(
        children: [
          _ShimmerBox(width: 16, height: 16),
          const RSizedBox(width: 8),
          _ShimmerBox(width: 20, height: 13),
          const RSizedBox(width: 6),
          Expanded(child: _ShimmerBox(height: 15)),
          const RSizedBox(width: 6),
          _ShimmerBox(width: 40, height: 13),
          const RSizedBox(width: 6),
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
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width?.r,
          height: widget.height?.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                context.getColor(ThemeEnum.hover).withValues(alpha: 0.05),
                context.getColor(ThemeEnum.hover).withValues(alpha: 0.1),
                context.getColor(ThemeEnum.hover).withValues(alpha: 0.05),
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ],
            ),
          ),
        );
      },
    );
  }
}
