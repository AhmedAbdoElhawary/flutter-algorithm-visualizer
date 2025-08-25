import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/searching/view_model/grid_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
part '../widgets/searcher_grid.dart';

final _gridNotifierProvider = StateNotifierProvider<SearchingNotifier, GridNotifierState>(
  (ref) => SearchingNotifier(),
);

BorderSide _borderSide([bool isWhite = false]) =>
    BorderSide(color: isWhite ? ColorManager.white : ColorManager.dividerBlue, width: isWhite ? 0.25.r : 1.r);

BorderDirectional _allBorder() => BorderDirectional(top: _borderSide(), start: _borderSide());

BorderDirectional _thineVerticalBorder() => BorderDirectional(
      top: _borderSide(true),
      start: _borderSide(true),
      end: _borderSide(true),
      bottom: _borderSide(true),
    );

class SearchingPage extends StatelessWidget {
  const SearchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer(builder: (context, ref, _) {
          return Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  width: double.infinity,
                  height: 40.r,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: PopupMenuButton<String>(
                        position: PopupMenuPosition.under,
                        onSelected: (value) {
                          if (value == StringsManager.recursiveBacktrackerMaze) {
                            ref.read(_gridNotifierProvider.notifier).generateRecursiveBacktrackerMaze();
                          } else if (value == StringsManager.recursiveDivisionMaze) {
                            ref.read(_gridNotifierProvider.notifier).generateRecursiveDivisionMaze();
                          }
                        },
                        itemBuilder: (context) => [
                          buildPopupMenuItem(StringsManager.recursiveBacktrackerMaze),
                          buildPopupMenuItem(StringsManager.recursiveDivisionMaze),
                        ],
                        icon: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MediumText(StringsManager.maze, fontSize: 12),
                            CustomIcon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                            ),
                          ],
                        ), // 3-dot menu
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: SizedBox(
                  width: double.infinity,
                  height: 40.r,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Center(
                      child: PopupMenuButton<String>(
                        position: PopupMenuPosition.under,
                        style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(ColorManager.finishedSearcherBlue)),
                        onSelected: (value) {
                          if (value == StringsManager.dijkstra) {
                            ref.read(_gridNotifierProvider.notifier).performDijkstra();
                          } else if (value == StringsManager.aStarSearch) {
                            ref.read(_gridNotifierProvider.notifier).performAStar();
                          } else if (value == StringsManager.bFS) {
                            ref.read(_gridNotifierProvider.notifier).performBFS();
                          }
                        },
                        itemBuilder: (context) => [
                          buildPopupMenuItem(StringsManager.dijkstra),
                          buildPopupMenuItem(StringsManager.aStarSearch),
                          buildPopupMenuItem(StringsManager.bFS),
                        ],
                        icon: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MediumText(StringsManager.visualize, fontSize: 12),
                            CustomIcon(Icons.keyboard_arrow_down_rounded, size: 16),
                          ],
                        ), // 3-dot menu
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: SizedBox(
                  width: double.infinity,
                  height: 40.r,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Center(
                      child: PopupMenuButton<String>(
                        position: PopupMenuPosition.under,
                        onSelected: (value) {
                          if (value == StringsManager.clearPath) {
                            ref.read(_gridNotifierProvider.notifier).clearTheGrid(keepWall: true);
                          } else if (value == StringsManager.clearAll) {
                            ref.read(_gridNotifierProvider.notifier).clearTheGrid();
                          }
                        },
                        itemBuilder: (context) => [
                          buildPopupMenuItem(StringsManager.clearPath, ThemeEnum.redColor),
                          buildPopupMenuItem(StringsManager.clearAll, ThemeEnum.redColor),
                        ],
                        icon: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MediumText(StringsManager.clear, fontSize: 12, color: ThemeEnum.redColor),
                            CustomIcon(Icons.keyboard_arrow_down_rounded, size: 16, color: ColorManager.red),
                          ],
                        ), // 3-dot menu
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return _BuildLayout(constraints.biggest);
          },
        ),
      ),
    );
  }

  PopupMenuItem<String> buildPopupMenuItem(String value, [ThemeEnum? color]) {
    return PopupMenuItem(value: value, child: RegularText(value, fontSize: 12, color: color));
  }
}

class _BuildLayout extends ConsumerStatefulWidget {
  const _BuildLayout(this.size);
  final Size size;

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
    if (oldWidget.size != widget.size) {
      Future.microtask(() => _updateLayout());
    }
    super.didUpdateWidget(oldWidget);
  }

  void _updateLayout() {
    ref.read(_gridNotifierProvider.notifier).updateGridLayout(widget.size);
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
    final gridCount = ref.watch(_gridNotifierProvider.select((it) => it.gridCount));
    final watchColumnCrossAxisCount =
        ref.watch(_gridNotifierProvider.select((it) => it.columnCrossAxisCount));

    if (gridCount == 0) {
      return const Center(child: MediumText(StringsManager.notInitializeGridYet));
    }

    final read = ref.read(_gridNotifierProvider.notifier);

    return Listener(
      onPointerDown: read.onPointerDownOnGrid,
      onPointerMove: read.onFingerMoveOnGrid,
      onPointerUp: read.onPointerUpOnGrid,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
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
    final isSelected = ref.watch(_gridNotifierProvider.select((it) => it.gridData[widget.index]));

    final isColored = isSelected != GridStatus.empty;
    final showBorder = isSelected != GridStatus.empty &&
        isSelected != GridStatus.startPoint &&
        isSelected != GridStatus.targetPoint;

    return Container(
      key: ValueKey(widget.index),
      decoration: BoxDecoration(
        border: showBorder ? _thineVerticalBorder() : _allBorder(),
      ),
      child: AnimatedScale(
        scale: isColored ? 1.0 : 0.1,
        duration: SearchingNotifier.scaleAppearDurationForWall,
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
              case GridStatus.path:
                return const _PathGrid();
              default:
                return const _DefaultGrid();
            }
          },
        ),
      ),
    );
  }
}

class _PathGrid extends StatelessWidget {
  const _PathGrid();

  @override
  Widget build(BuildContext context) {
    return const _WidgetSize(
      decoration: BoxDecoration(color: ColorManager.light2Yellow),
    );
  }
}

class _WallGrid extends StatelessWidget {
  const _WallGrid();

  @override
  Widget build(BuildContext context) {
    return const _WidgetSize(
      decoration: BoxDecoration(color: ColorManager.wallBlack),
    );
  }
}

class _StartPointGrid extends StatelessWidget {
  const _StartPointGrid();

  @override
  Widget build(BuildContext context) {
    return const _WidgetSize(
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: FittedBox(
        child: CustomIcon(
          Icons.arrow_forward_ios_rounded,
          size: 50,
          color: ColorManager.darkPurple,
        ),
      ),
    );
  }
}

class _TargetPointGrid extends StatelessWidget {
  const _TargetPointGrid();

  @override
  Widget build(BuildContext context) {
    return const _WidgetSize(
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: FittedBox(
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
    return const _WidgetSize(
      decoration: BoxDecoration(color: ColorManager.transparent),
    );
  }
}

class _WidgetSize extends ConsumerWidget {
  const _WidgetSize({this.child, this.decoration});
  final Widget? child;
  final Decoration? decoration;
  @override
  Widget build(BuildContext context, ref) {
    final size = ref.watch(_gridNotifierProvider.select((it) => it.gridSize));

    return Container(
      width: size,
      height: size,
      decoration: decoration,
      child: child,
    );
  }
}
