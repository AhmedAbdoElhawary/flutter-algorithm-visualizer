import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/grid/view_model/grid_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
part '../widgets/searcher_grid.dart';

final gridNotifierProvider =
    StateNotifierProvider<GridNotifierCubit, GridNotifierState>(
  (ref) => GridNotifierCubit(),
);

Border _allBorder() =>
    Border.all(color: ColorManager.dividerBlue, width: 0.5.r);

Border _thineVerticalBorder() {
  return Border.symmetric(
      vertical: BorderSide(color: ColorManager.white, width: 0.5.r));
}

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
          decoration: const BoxDecoration(color: ColorManager.wallBlack),
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
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child:  const FittedBox(
            child: CustomIcon(
              Icons.arrow_forward_ios_rounded,
              size: 50,
              color: ColorManager.darkPurple,
            ),
          ),
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
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: const FittedBox(
            child: _Circle(
              radius: 30,
              backgroundColor: ColorManager.darkPurple,
              child: _Circle(
                radius: 20,
                backgroundColor: ColorManager.white,
                child: _Circle(radius: 12, backgroundColor: ColorManager.darkPurple),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({
    this.child,
    required this.radius,
    required this.backgroundColor,
  });
  final Widget? child;
  final double radius;
  final Color backgroundColor;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius.r,
      backgroundColor: backgroundColor,
      child: child,
    );
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
