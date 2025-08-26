import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_page.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/bubble/view_model/bubble_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => BubbleSortNotifier(),
);

class BubbleSortPage extends StatelessWidget {
  const BubbleSortPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SortingPage(instance: _notifierProvider, title: StringsManager.bubbleSort);
  }
}
