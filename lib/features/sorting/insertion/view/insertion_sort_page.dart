import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_page.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/insertion/view_model/insertion_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => InsertionSortNotifier(),
);

class InsertionSortPage extends ConsumerStatefulWidget {
  const InsertionSortPage({super.key});

  @override
  ConsumerState<InsertionSortPage> createState() => _InsertionSortPageState();
}

class _InsertionSortPageState extends ConsumerState<InsertionSortPage> {
  @override
  void deactivate() {
    ref.invalidate(_notifierProvider); // deletes current instance and resets
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return SortingPage(instance: _notifierProvider, title: StringsManager.insertionSort);
  }
}
