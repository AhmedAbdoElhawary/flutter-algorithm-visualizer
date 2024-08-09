import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/grid/view_model/grid_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gridNotifierProvider =
    StateNotifierProvider<GridNotifierCubit, GridNotifierState>(
  (ref) => GridNotifierCubit(),
);

class GridPage extends StatelessWidget {
  const GridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid Page'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              return TextButton(
                onPressed: () {
                  ref.read(gridNotifierProvider.notifier).clearTheGrid();
                },
                child: const RegularText(StringsManager.clear),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return _BuildLayout(constraints);
          },
        ),
      ),
    );
  }
}

class _BuildLayout extends ConsumerStatefulWidget {
  const _BuildLayout(this.constraints);
  final BoxConstraints constraints;

  @override
  ConsumerState<_BuildLayout> createState() => _BuildLayoutState();
}

class _BuildLayoutState extends ConsumerState<_BuildLayout> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _updateLayout());
  }

  @override
  void didUpdateWidget(covariant _BuildLayout oldWidget) {
    if (oldWidget.constraints != widget.constraints) {
      Future.microtask(() => _updateLayout());
    }
    super.didUpdateWidget(oldWidget);
  }

  void _updateLayout() {
    ref
        .read(gridNotifierProvider.notifier)
        .updateGridLayout(widget.constraints);
  }

  @override
  Widget build(BuildContext context) {
    return const _BuildGridItems();
  }
}

class _BuildGridItems extends ConsumerWidget {
  const _BuildGridItems();

  @override
  Widget build(BuildContext context, ref) {
    final gridCount =
        ref.watch(gridNotifierProvider.select((it) => it.gridCount));
    final watchColumnCrossAxisCount =
        ref.watch(gridNotifierProvider.select((it) => it.columnCrossAxisCount));

    if (gridCount == 0) {
      return const Center(
          child: MediumText(StringsManager.notInitializeGridYet));
    }

    final read = ref.read(gridNotifierProvider.notifier);

    return Listener(
      onPointerDown: read.onPointerDownOnGrid,
      onPointerMove: read.onFingerMoveOnGrid,
      onPointerUp: read.onPointerUpOnGrid,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: watchColumnCrossAxisCount,
          childAspectRatio: 1.0, // Ensures squares
        ),
        itemBuilder: (context, index) {
          return _Square(index: index);
        },
        itemCount: gridCount,
      ),
    );
  }
}

class _Square extends ConsumerStatefulWidget {
  const _Square({required this.index});
  final int index;
  @override
  _SquareState createState() => _SquareState();
}

class _SquareState extends ConsumerState<_Square> {
  @override
  Widget build(BuildContext context) {
    final isSelected = ref
        .watch(gridNotifierProvider.select((it) => it.gridData[widget.index]));

    final isColored = isSelected != GridStatus.empty;

    return Container(
      decoration: BoxDecoration(
        border: isColored ? _thineVerticalBorder() : _allBorder(),
      ),
      child: AnimatedScale(
        scale: isColored ? 1.0 : 0.1,
        duration: const Duration(milliseconds: 700),
        curve: Curves.elasticOut,
        child: Builder(
          builder: (context) {
            switch (isSelected) {
              case GridStatus.wall:
                return const _WallGrid();
              case GridStatus.startPoint:
                return const _StartPointGrid();
              case GridStatus.targetPoint:
                return const _TargetPointGrid();
              case GridStatus.searcher:
                return const _SearcherGrid();
              default:
                return const _DefaultGrid();
            }
          },
        ),
      ),
    );
  }

  Border _allBorder() =>
      Border.all(color: ColorManager.grey.withOpacity(0.5), width: 0.5);

  Border _thineVerticalBorder() {
    return Border.symmetric(
        vertical:
            BorderSide(color: ColorManager.grey.withOpacity(0.5), width: 0.3));
  }
}

class _WallGrid extends StatelessWidget {
  const _WallGrid();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final size =
            ref.watch(gridNotifierProvider.select((it) => it.gridSize));

        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(color: ColorManager.black),
        );
      },
    );
  }
}

class _StartPointGrid extends StatelessWidget {
  const _StartPointGrid();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final size =
            ref.watch(gridNotifierProvider.select((it) => it.gridSize));

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              color: ColorManager.yellow.withOpacity(.4),
              shape: BoxShape.circle),
          // padding: REdgeInsets.all(2),
          child: const FittedBox(child: Icon(Icons.arrow_forward)),
        );
      },
    );
  }
}

class _TargetPointGrid extends StatelessWidget {
  const _TargetPointGrid();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final size =
            ref.watch(gridNotifierProvider.select((it) => it.gridSize));

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              color: ColorManager.red.withOpacity(.4), shape: BoxShape.circle),
          // padding: REdgeInsets.all(),
          child: const FittedBox(child: Icon(Icons.control_point_rounded)),
        );
      },
    );
  }
}

class _SearcherGrid extends StatefulWidget {
  const _SearcherGrid();

  @override
  State<_SearcherGrid> createState() => _SearcherGridState();
}

class _SearcherGridState extends State<_SearcherGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _shapeAnimation;

  final startColor = ColorManager.darkBlue;
  final mediumColor = ColorManager.mediumBlue;
  final finishedSearcherColor = ColorManager.finishedSearcherBlue;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration:
          const Duration(milliseconds: 1500), // Total duration of the animation
      vsync: this,
    );

    // Define the scale animation from 0.1 to 1.2 then back to 1.0
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: 1.4), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 40),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Define the color animation
    _colorAnimation = TweenSequence([
      TweenSequenceItem(
          tween: ColorTween(begin: startColor, end: mediumColor), weight: 40),
      TweenSequenceItem(
          tween: ColorTween(begin: mediumColor, end: finishedSearcherColor),
          weight: 60),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
      ),
    );

    //                             (begin => circle, end => rectangle)
    _shapeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.65, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.reverse();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final size = ref.watch(gridNotifierProvider.select((it) => it.gridSize));

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: Border.symmetric(
                    vertical: BorderSide(
                        color: ColorManager.grey.withOpacity(0.5), width: 0.3)),
                borderRadius:
                    BorderRadius.circular(_shapeAnimation.value * (size / 2)),
                color: _controller.value < 0.4
                    ? Color.lerp(ColorManager.transparent, startColor,
                        _controller.value / 0.4)
                    : _colorAnimation.value,
              ),
            ),
          );
        },
      );
    });
  }
}

class _DefaultGrid extends StatelessWidget {
  const _DefaultGrid();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final size =
            ref.watch(gridNotifierProvider.select((it) => it.gridSize));

        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(color: ColorManager.transparent),
        );
      },
    );
  }
}
