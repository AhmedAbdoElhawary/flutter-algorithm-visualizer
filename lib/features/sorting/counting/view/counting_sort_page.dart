import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_page_view_model.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_page.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/counting/view_model/counting_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => CountingSortNotifier(),
);

class CountingSortPage extends StatelessWidget {
  const CountingSortPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SortingPage(
        instance: HomePageViewModel.sortingCards[StringsManager.countingSort]?.instance ?? _notifierProvider,
        title: StringsManager.countingSort);
  }
}
