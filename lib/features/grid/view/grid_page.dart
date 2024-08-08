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
      onPointerMove: read.onPointerMoveOnGrid,
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

    final isBlack = isSelected;

    return Container(
      decoration: BoxDecoration(
        border: isBlack
            ? Border.symmetric(
                vertical:
                    BorderSide(color: Colors.grey.withOpacity(0.5), width: 0.3))
            : Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
      ),
      child: AnimatedScale(
        scale: isBlack ? 1.0 : 0.1,
        duration: const Duration(milliseconds: 700),
        curve: Curves.elasticOut,
        child: Consumer(
          builder: (context, ref, _) {
            final size =
                ref.watch(gridNotifierProvider.select((it) => it.gridSize));

            return Container(
              width: size,
              height: size,
              color: isBlack ? Colors.black : Colors.transparent,
            );
          },
        ),
      ),
    );
  }
}
