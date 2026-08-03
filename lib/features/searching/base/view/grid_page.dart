// import 'package:algorithm_visualizer/core/resources/color_manager.dart';
// import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
// import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
// import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
// import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
// import 'package:algorithm_visualizer/features/searching/view_model/grid_notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:algorithm_visualizer/core/helpers/app_bar/back_button.dart';
// import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
// import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
// import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
// import 'package:algorithm_visualizer/features/sorting/base/widgets/linear_progress_indicator.dart';
//
// part '../widgets/searcher_grid.dart';
//
// final _gridNotifierProvider = StateNotifierProvider<SearchingNotifier, GridNotifierState>(
//   (ref) => SearchingNotifier(),
// );
//
// BorderSide _borderSide([bool isWhite = false]) =>
//     BorderSide(color: isWhite ? ColorManager.white : ColorManager.dividerBlue, width: isWhite ? 0.25.r : 1.r);
//
// BorderDirectional _allBorder() => BorderDirectional(top: _borderSide(), start: _borderSide());
//
// BorderDirectional _thineVerticalBorder() => BorderDirectional(
//       top: _borderSide(true),
//       start: _borderSide(true),
//       end: _borderSide(true),
//       bottom: _borderSide(true),
//     );
//
// class SearchingPage extends ConsumerWidget {
//   const SearchingPage({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return PopScope(
//       onPopInvokedWithResult: (didPop, result) async {
//         if (didPop) {
//           await ref.read(_gridNotifierProvider.notifier).cancelSearching();
//           ref.invalidate(_gridNotifierProvider);
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           centerTitle: false,
//           titleSpacing: 0,
//           leading: CustomBackButtonIcon(),
//           title: _AlgorithmTitle(title: "title", description: "description"),
//         ),
//         body: CustomScrollView(
//           physics: BouncingScrollPhysics(),
//           slivers: [
//
//             // Scaffold(
//             //   appBar: AppBar(
//             //     title: const _ControlButtons(),
//             //     centerTitle: true,
//             //   ),
//             //   body: SafeArea(
//             //     child: LayoutBuilder(
//             //       builder: (BuildContext context, BoxConstraints constraints) {
//             //         return _BuildLayout(constraints.biggest);
//             //       },
//             //     ),
//             //   ),
//             // )
//             SliverPadding(
//               padding: REdgeInsetsDirectional.only(top: 20, bottom: 10),
//               sliver: ShowUpSortingList(),
//             ),
//             // SliverPadding(
//             //   padding: REdgeInsetsDirectional.only(top: 10, bottom: 10),
//             //   sliver: SliverToBoxAdapter(child: _ProgressBar(instance)),
//             // ),
//             // SliverPadding(
//             //   padding: REdgeInsetsDirectional.only(top: 10, bottom: 10),
//             //   sliver: SliverToBoxAdapter(child: _SortingControlButtons(instance)),
//             // ),
//             // SliverPadding(
//             //   padding: REdgeInsetsDirectional.only(top: 10, bottom: 10),
//             //   sliver: SliverToBoxAdapter(child: _LiveCodeSnippet(instance)),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ControlButtons extends StatefulWidget {
//   const _ControlButtons();
//
//   @override
//   State<_ControlButtons> createState() => _ControlButtonsState();
// }
//
// class _ControlButtonsState extends State<_ControlButtons> {
//   PopupMenuItem<String> buildPopupMenuItem(String value, [ThemeEnum? color]) {
//     final isLargeScreen = MediaQuery.sizeOf(context).width > 500;
//     return PopupMenuItem(
//         value: value, child: RegularText(value, fontSize: isLargeScreen ? 16 : 14, color: color));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, _) {
//         return Row(
//           children: [
//             Expanded(
//               flex: 8,
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 40.r,
//                 child: Center(
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: PopupMenuButton<String>(
//                       position: PopupMenuPosition.under,
//                       onSelected: (value) {
//                         if (value == StringsManager.recursiveBacktrackerMaze) {
//                           ref.read(_gridNotifierProvider.notifier).generateRecursiveBacktrackerMaze();
//                         } else if (value == StringsManager.recursiveDivisionMaze) {
//                           ref.read(_gridNotifierProvider.notifier).generateRecursiveDivisionMaze();
//                         }
//                       },
//                       itemBuilder: (context) => [
//                         buildPopupMenuItem(StringsManager.recursiveBacktrackerMaze),
//                         buildPopupMenuItem(StringsManager.recursiveDivisionMaze),
//                       ],
//                       icon: const Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           MediumText(StringsManager.maze, fontSize: 16),
//                           CustomIcon(
//                             Icons.keyboard_arrow_down_rounded,
//                             size: 20,
//                           ),
//                         ],
//                       ), // 3-dot menu
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 10,
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 40.r,
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Center(
//                     child: PopupMenuButton<String>(
//                       position: PopupMenuPosition.under,
//                       style: const ButtonStyle(
//                           backgroundColor: WidgetStatePropertyAll(ColorManager.finishedSearcherBlue)),
//                       onSelected: (value) {
//                         if (value == StringsManager.dijkstra) {
//                           ref.read(_gridNotifierProvider.notifier).performDijkstra();
//                         } else if (value == StringsManager.aStarSearch) {
//                           ref.read(_gridNotifierProvider.notifier).performAStar();
//                         } else if (value == StringsManager.bFS) {
//                           ref.read(_gridNotifierProvider.notifier).performBFS();
//                         }
//                       },
//                       itemBuilder: (context) => [
//                         buildPopupMenuItem(StringsManager.dijkstra),
//                         buildPopupMenuItem(StringsManager.aStarSearch),
//                         buildPopupMenuItem(StringsManager.bFS),
//                       ],
//                       icon: const Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           MediumText(StringsManager.visualize, fontSize: 16),
//                           CustomIcon(Icons.keyboard_arrow_down_rounded, size: 22),
//                         ],
//                       ), // 3-dot menu
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 10,
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 40.r,
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Center(
//                     child: PopupMenuButton<String>(
//                       position: PopupMenuPosition.under,
//                       onSelected: (value) {
//                         if (value == StringsManager.clearPath) {
//                           ref.read(_gridNotifierProvider.notifier).clearTheGrid(keepWall: true);
//                         } else if (value == StringsManager.clearAll) {
//                           ref.read(_gridNotifierProvider.notifier).clearTheGrid();
//                         }
//                       },
//                       itemBuilder: (context) => [
//                         buildPopupMenuItem(StringsManager.clearPath, ThemeEnum.redColor),
//                         buildPopupMenuItem(StringsManager.clearAll, ThemeEnum.redColor),
//                       ],
//                       icon: const Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           MediumText(StringsManager.clear, fontSize: 16, color: ThemeEnum.redColor),
//                           CustomIcon(Icons.keyboard_arrow_down_rounded, size: 20, color: ThemeEnum.redColor),
//                         ],
//                       ), // 3-dot menu
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _BuildLayout extends ConsumerStatefulWidget {
//   const _BuildLayout(this.size);
//   final Size size;
//
//   @override
//   ConsumerState<_BuildLayout> createState() => _BuildLayoutState();
// }
//
// class _BuildLayoutState extends ConsumerState<_BuildLayout> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => _updateLayout());
//   }
//
//   @override
//   void didUpdateWidget(covariant _BuildLayout oldWidget) {
//     if (oldWidget.size != widget.size) {
//       Future.microtask(() => _updateLayout());
//     }
//     super.didUpdateWidget(oldWidget);
//   }
//
//   void _updateLayout() {
//     ref.read(_gridNotifierProvider.notifier).updateGridLayout(widget.size);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const _BuildGridItems();
//   }
// }
//
// class _BuildGridItems extends ConsumerWidget {
//   const _BuildGridItems();
//
//   @override
//   Widget build(BuildContext context, ref) {
//     final gridCount = ref.watch(_gridNotifierProvider.select((it) => it.gridCount));
//     final watchColumnCrossAxisCount =
//         ref.watch(_gridNotifierProvider.select((it) => it.columnCrossAxisCount));
//
//     if (gridCount == 0) {
//       return SliverToBoxAdapter(child: const Center(child: MediumText(StringsManager.notInitializeGridYet)));
//     }
//
//     final read = ref.read(_gridNotifierProvider.notifier);
//
//     return SliverGrid.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: watchColumnCrossAxisCount,
//         childAspectRatio: 1.0, // Ensures squares
//       ),
//       itemBuilder: (context, index) {
//         return _Square(index: index);
//       },
//       itemCount: gridCount,
//     );
//   }
// }
//
// class _Square extends ConsumerStatefulWidget {
//   const _Square({required this.index});
//   final int index;
//   @override
//   _SquareState createState() => _SquareState();
// }
//
// class _SquareState extends ConsumerState<_Square> {
//   @override
//   Widget build(BuildContext context) {
//     final isSelected = ref.watch(_gridNotifierProvider
//         .select((it) => it.gridData.length > widget.index ? it.gridData[widget.index] : GridStatus.empty));
//
//     final isColored = isSelected != GridStatus.empty;
//     final showBorder = isSelected != GridStatus.empty &&
//         isSelected != GridStatus.startPoint &&
//         isSelected != GridStatus.targetPoint;
//
//     return Container(
//       key: ValueKey(widget.index),
//       decoration: BoxDecoration(
//         border: showBorder ? _thineVerticalBorder() : _allBorder(),
//       ),
//       child: AnimatedScale(
//         scale: isColored ? 1.0 : 0.1,
//         duration: SearchingNotifier.scaleAppearDurationForWall,
//         curve: Curves.elasticOut,
//         child: Builder(
//           builder: (context) {
//             switch (isSelected) {
//               case GridStatus.wall:
//                 return const _WallGrid();
//               case GridStatus.startPoint:
//                 return const _StartPointGrid();
//               case GridStatus.targetPoint:
//                 return const _TargetPointGrid();
//               case GridStatus.searcher:
//                 return const _SearcherGrid();
//               case GridStatus.path:
//                 return const _PathGrid();
//               default:
//                 return const _DefaultGrid();
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class _PathGrid extends StatelessWidget {
//   const _PathGrid();
//
//   @override
//   Widget build(BuildContext context) {
//     return const _WidgetSize(
//       decoration: BoxDecoration(color: ColorManager.light2Yellow),
//     );
//   }
// }
//
// class _WallGrid extends StatelessWidget {
//   const _WallGrid();
//
//   @override
//   Widget build(BuildContext context) {
//     return const _WidgetSize(
//       decoration: BoxDecoration(color: ColorManager.wallBlack),
//     );
//   }
// }
//
// class _StartPointGrid extends StatelessWidget {
//   const _StartPointGrid();
//
//   @override
//   Widget build(BuildContext context) {
//     return const _WidgetSize(
//       decoration: BoxDecoration(shape: BoxShape.circle),
//       child: FittedBox(
//         child: CustomIcon(
//           Icons.arrow_forward_ios_rounded,
//           size: 50,
//           color: ThemeEnum.darkPurpleColor,
//         ),
//       ),
//     );
//   }
// }
//
// class _TargetPointGrid extends StatelessWidget {
//   const _TargetPointGrid();
//
//   @override
//   Widget build(BuildContext context) {
//     return const _WidgetSize(
//       decoration: BoxDecoration(shape: BoxShape.circle),
//       child: FittedBox(
//         child: _Circle(
//           radius: 30,
//           backgroundColor: ColorManager.darkPurple,
//           child: _Circle(
//             radius: 20,
//             backgroundColor: ColorManager.white,
//             child: _Circle(radius: 12, backgroundColor: ColorManager.darkPurple),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _Circle extends StatelessWidget {
//   const _Circle({
//     this.child,
//     required this.radius,
//     required this.backgroundColor,
//   });
//   final Widget? child;
//   final double radius;
//   final Color backgroundColor;
//   @override
//   Widget build(BuildContext context) {
//     return CircleAvatar(
//       radius: radius.r,
//       backgroundColor: backgroundColor,
//       child: child,
//     );
//   }
// }
//
// class _DefaultGrid extends StatelessWidget {
//   const _DefaultGrid();
//
//   @override
//   Widget build(BuildContext context) {
//     return const _WidgetSize(
//       decoration: BoxDecoration(color: ColorManager.transparent),
//     );
//   }
// }
//
// class _WidgetSize extends ConsumerWidget {
//   const _WidgetSize({this.child, this.decoration});
//   final Widget? child;
//   final Decoration? decoration;
//   @override
//   Widget build(BuildContext context, ref) {
//     final size = ref.watch(_gridNotifierProvider.select((it) => it.gridSize));
//
//     return Container(
//       width: size,
//       height: size,
//       decoration: decoration,
//       child: child,
//     );
//   }
// }
//
// class SortingPage extends ConsumerWidget {
//   const SortingPage({required this.instance, required this.title, super.key});
//   final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
//   final String title;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final description = ref.read(instance.notifier).description;
//     final complexity = ref.read(instance.notifier).algoComplexity;
//     return PopScope(
//       onPopInvokedWithResult: (didPop, result) async {
//         if (didPop) {
//           await ref.read(instance.notifier).cancelSorting();
//           ref.invalidate(instance); // deletes current instance and resets
//         }
//       },
//       child: Scaffold(
//         body: CustomScrollView(
//           physics: BouncingScrollPhysics(),
//           slivers: [
//             SliverAppBar(
//               pinned: true,
//               centerTitle: false,
//               titleSpacing: 0,
//               leading: CustomBackButtonIcon(),
//               title: _AlgorithmTitle(title: title, description: description),
//             ),
//             SliverToBoxAdapter(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     RSizedBox(width: 16),
//                     _TimeComplexityData(complexity: complexity),
//                     RSizedBox(width: 10),
//                     _SpaceComplexityData(complexity: complexity),
//                     RSizedBox(width: 16),
//                   ],
//                 ),
//               ),
//             ),
//             SliverToBoxAdapter(child: ShowUpSortingList()),
//             // SliverToBoxAdapter(child: _StatusLiveText(instance)),
//             SliverPadding(
//               padding: REdgeInsetsDirectional.only(top: 10, bottom: 10),
//               sliver: SliverToBoxAdapter(child: _ProgressBar(instance)),
//             ),
//             // SliverPadding(
//             //   padding: REdgeInsetsDirectional.only(top: 10, bottom: 10),
//             //   sliver: SliverToBoxAdapter(child: _SortingControlButtons(instance)),
//             // ),
//             SliverPadding(
//               padding: REdgeInsetsDirectional.only(top: 10, bottom: 10),
//               sliver: SliverToBoxAdapter(child: _LiveCodeSnippet(instance)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _LiveCodeSnippet extends ConsumerWidget {
//   const _LiveCodeSnippet(this.instance);
//
//   final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final currentLine = ref.watch(instance.select((s) => s.currentCodeLine));
//     final codeLines = ref.read(instance.notifier).codeSnippet;
//
//     return Padding(
//       padding: REdgeInsets.symmetric(horizontal: 16),
//       child: GlassContainer(
//         withAboveShadow: false,
//         borderRadius: 12,
//         padding: REdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ── Header ──────────────────────────────────────────────────────
//             Row(
//               children: [
//                 CustomIcon(Icons.data_object_rounded, size: 14, color: ThemeEnum.hoverColor),
//                 RSizedBox(width: 6),
//                 MediumText(StringsManager.pseudocode, fontSize: 13, color: ThemeEnum.hoverColor),
//                 const Spacer(),
//                 // Pill showing which line is active.
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 180),
//                   child: currentLine >= 0
//                       ? Container(
//                           key: ValueKey(currentLine),
//                           padding: REdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: context.getColor(ThemeEnum.lightBlueColor).withValues(alpha: 0.15),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: RegularText(
//                             'L${currentLine + 1}',
//                             fontSize: 11,
//                             color: ThemeEnum.lightBlueColor,
//                           ),
//                         )
//                       : const SizedBox.shrink(),
//                 ),
//               ],
//             ),
//             RSizedBox(height: 12),
//             // ── Code lines ───────────────────────────────────────────────────
//             ...codeLines.asMap().entries.map((entry) {
//               final i = entry.key;
//               final isActive = i == currentLine;
//
//               return AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 margin: REdgeInsets.only(bottom: 3),
//                 decoration: BoxDecoration(
//                   color: isActive
//                       ? context.getColor(ThemeEnum.lightBlueColor).withValues(alpha: 0.12)
//                       : Colors.transparent,
//                   borderRadius: BorderRadius.circular(4),
//                   border: isActive
//                       ? Border(
//                           left: BorderSide(
//                             color: context.getColor(ThemeEnum.lightBlueColor),
//                             width: 2.5,
//                           ),
//                         )
//                       : null,
//                 ),
//                 padding: REdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 child: Row(
//                   children: [
//                     // Line number
//                     SizedBox(
//                       width: 20,
//                       child: RegularText(
//                         '${i + 1}',
//                         fontSize: 11,
//                         color: isActive ? ThemeEnum.lightBlueColor : ThemeEnum.hoverColor,
//                       ),
//                     ),
//                     RSizedBox(width: 10),
//                     // Code text — grows to fill available space
//                     Expanded(
//                       child: RegularText(
//                         entry.value,
//                         fontSize: 12,
//                         color: isActive ? ThemeEnum.white2DarkColor : ThemeEnum.hoverColor,
//                       ),
//                     ),
//                     // Execution arrow shown only on the active line
//                     if (isActive)
//                       CustomIcon(
//                         Icons.arrow_right_rounded,
//                         size: 16,
//                         color: ThemeEnum.lightBlueColor,
//                       ),
//                   ],
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _TimeComplexityData extends StatelessWidget {
//   const _TimeComplexityData({required this.complexity});
//
//   final AlgorithmComplexity complexity;
//
//   @override
//   Widget build(BuildContext context) {
//     return GlassContainer(
//       withAboveShadow: false,
//       borderRadius: 8,
//       padding: REdgeInsets.all(6),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CustomIcon(Icons.access_time_rounded, size: 14, color: ThemeEnum.hoverColor),
//           RSizedBox(width: 4),
//           RegularText(StringsManager.time, color: ThemeEnum.hoverColor, fontSize: 14),
//           RSizedBox(width: 2),
//           RegularText(StringsManager.best, color: ThemeEnum.white2DarkColor, fontSize: 12),
//           RSizedBox(width: 2),
//           SemiBoldText(complexity.bestTimeComplexity.getText, color: ThemeEnum.greenColor, fontSize: 14),
//           RSizedBox(width: 4),
//           RegularText(StringsManager.worst, color: ThemeEnum.white2DarkColor, fontSize: 12),
//           RSizedBox(width: 2),
//           SemiBoldText(complexity.worstTimeComplexity.getText, color: ThemeEnum.mainDarkColor, fontSize: 14),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatusLiveText extends ConsumerWidget {
//   const _StatusLiveText(this.instance);
//
//   final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final text = ref.watch(instance.select((s) => s.statusText));
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: GlassContainer(
//         withAboveShadow: false,
//         borderRadius: 8,
//         padding: REdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 250),
//           child: MediumText(
//             key: ValueKey(text),
//             text,
//             fontSize: 14,
//             color: ThemeEnum.white2DarkColor,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _ProgressBar extends ConsumerWidget {
//   const _ProgressBar(this.instance);
//
//   final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Only rebuild when these two values change — nothing else.
//     final progress = ref.watch(instance.select((s) => s.progressValue));
//     final label = ref.watch(instance.select((s) => s.progressLabel));
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(4),
//               child: GradientLinearProgressIndicator(value: progress),
//             ),
//           ),
//           RSizedBox(width: 10),
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 200),
//             child: MediumText(
//               key: ValueKey(label),
//               label,
//               fontSize: 12,
//               color: ThemeEnum.hoverColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _SpaceComplexityData extends StatelessWidget {
//   const _SpaceComplexityData({required this.complexity});
//
//   final AlgorithmComplexity complexity;
//
//   @override
//   Widget build(BuildContext context) {
//     return GlassContainer(
//       withAboveShadow: false,
//       borderRadius: 8,
//       padding: REdgeInsets.all(6),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CustomIcon(Icons.storage_rounded, size: 14, color: ThemeEnum.hoverColor),
//           RSizedBox(width: 4),
//           RegularText(StringsManager.space, color: ThemeEnum.hoverColor, fontSize: 14),
//           RSizedBox(width: 2),
//           SemiBoldText(complexity.spaceComplexity.getText, color: ThemeEnum.mainDarkColor, fontSize: 14),
//         ],
//       ),
//     );
//   }
// }
//
// class _AlgorithmTitle extends StatelessWidget {
//   const _AlgorithmTitle({
//     required this.title,
//     required this.description,
//   });
//
//   final String title;
//   final String description;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         BoldText(title, fontSize: 20),
//         RegularText(
//           description,
//           fontSize: 11,
//           color: ThemeEnum.hoverColor,
//         )
//       ],
//     );
//   }
// }
//
// class SortingAppBar extends StatelessWidget {
//   const SortingAppBar({super.key, required this.title});
//
//   final String title;
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, _) {
//         return InkWell(child: RegularText(title));
//       },
//     );
//   }
// }
//
// class ShowUpSortingList extends ConsumerWidget {
//   const ShowUpSortingList({this.selectedAlgorithmLength = 1, super.key});
//   final int selectedAlgorithmLength;
//   @override
//   Widget build(BuildContext context, ref) {
//     final maxHeight = SortingNotifier.calculateMaxListItemHeight(context);
//
//     return _BuildLayout(Size(200, maxHeight));
//   }
// }
//
// class _BuildItem extends ConsumerWidget {
//   const _BuildItem({
//     required this.item,
//     required this.index,
//     required this.speedDuration,
//     required this.instance,
//     required this.selectedAlgorithmLength,
//     required this.isLastItem,
//     required this.itemWidth,
//     required this.size,
//   });
//   final double itemWidth;
//   final int size;
//   final int index;
//   final SortableItem item;
//   final Duration speedDuration;
//   final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
//   final int selectedAlgorithmLength;
//   final bool isLastItem;
//   @override
//   Widget build(BuildContext context, ref) {
//     final currentItem =
//         ref.watch(instance.select((state) => index < state.list.length ? state.list[index] : null));
//     return Center(
//       child: AnimatedContainer(
//         duration: speedDuration,
//         width: itemWidth,
//         height: SortingNotifier.calculateItemHeight(context, item.value, size, selectedAlgorithmLength),
//         decoration: BoxDecoration(
//           color: context.getColor(currentItem?.getColor ?? SortingNotifier.itemColor),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(3.r), bottom: Radius.circular(3.r)),
//         ),
//       ),
//     );
//   }
// }
