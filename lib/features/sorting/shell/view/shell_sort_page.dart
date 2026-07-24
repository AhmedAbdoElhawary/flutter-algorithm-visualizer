import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_page_view_model.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_page.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/shell/view_model/shell_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => ShellSortNotifier(),
);

class ShellSortPage extends StatelessWidget {
  const ShellSortPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SortingPage(
        instance: BasePageViewModel.sortingCards[StringsManager.shellSort]?.instance ?? _notifierProvider,
        title: StringsManager.shellSort);
  }
}
