import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_page.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/comparison/view_model/comparison_sort_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final _notifierProvider = StateNotifierProvider<ComparisonSortNotifier, ComparisonSortingNotifierState>(
  (ref) => ComparisonSortNotifier(),
);

class ComparisonSortPage extends ConsumerStatefulWidget {
  const ComparisonSortPage({super.key});

  @override
  ConsumerState<ComparisonSortPage> createState() => _ComparisonSortPageState();
}

class _ComparisonSortPageState extends ConsumerState<ComparisonSortPage> {
  @override
  void deactivate() {
    ref.invalidate(_notifierProvider); // deletes current instance and resets

    ComparisonSortNotifier.sortingAlgorithms.values.toList().forEach(
      (element) {
        try {
          ref.invalidate(element.provider);
        } catch (e) {
          //
        }
      },
    );
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: const _DrawerMenu(),
      body: SafeArea(
        child: Column(
          children: [
            const Flexible(child: _BuildComparisonLists()),
            const RSizedBox(height: 15),
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 0),
              child: Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10,
                  children: [
                    SortingControlButtons(
                      playSorting: () => ref.read(_notifierProvider.notifier).playSorting(ref),
                      stopSorting: () => ref.read(_notifierProvider.notifier).stopSorting(ref),
                      generateAgain: () => ref.read(_notifierProvider.notifier).generateAgain(ref),
                    ),
                    SymmetricPadding(
                      horizontal: 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SpeedDraggable(
                            onChanged: (persent) {
                              ref.read(_notifierProvider.notifier).changeSpeed(persent, ref);
                            },
                          ),
                          _SizeDraggable(ref: ref),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 1,
      title: const SortingAppBar(title: StringsManager.comparisonSort),
    );
  }
}

class _SizeDraggable extends StatelessWidget {
  const _SizeDraggable({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final operationStatus = ref.watch(_notifierProvider.select((state) => state.operationStatus));
    final isRunning = operationStatus == SortingEnum.played || operationStatus == SortingEnum.stopped;

    return SizeDraggable(
      isRunning: isRunning,
      onChanged: (persent) {
        ref.read(_notifierProvider.notifier).changeSize(persent, ref);
      },
    );
  }
}

class _DrawerMenu extends ConsumerWidget {
  const _DrawerMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAlgorithms = ref.watch(_notifierProvider.select((state) => state.selectedAlgorithms));
    final algorithms = ComparisonSortNotifier.sortingAlgorithms.keys.toList();
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const ListTile(
              title: SemiBoldText(StringsManager.comparisonAlgorithms, color: ThemeEnum.focusColor),
            ),
            ...List.generate(
              algorithms.length,
              (index) => ListTile(
                trailing:
                    selectedAlgorithms.firstWhereOrNull((element) => element.name == algorithms[index]) !=
                            null
                        ? const CustomIcon(Icons.check)
                        : null,
                title: RegularText(algorithms[index]),
                onTap: () {
                  ref.read(_notifierProvider.notifier).selectAlgorithm(algorithms[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildComparisonLists extends ConsumerWidget {
  const _BuildComparisonLists();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAlgorithms = ref.watch(_notifierProvider.select((state) => state.selectedAlgorithms));

    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: Column(
        children: List.generate(
          selectedAlgorithms.length,
          (index) => Flexible(
            child: Column(
              children: [
                Flexible(
                  child: ShowUpSortingList(
                    selectedAlgorithms[index].provider,
                    selectedAlgorithmLength: selectedAlgorithms.length,
                  ),
                ),
                RegularText(selectedAlgorithms[index].name, fontSize: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
