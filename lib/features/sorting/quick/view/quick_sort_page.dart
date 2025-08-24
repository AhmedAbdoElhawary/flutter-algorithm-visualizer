import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_page.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/quick/view_model/quick_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => QuickSortNotifier(),
);

class QuickSortPage extends ConsumerStatefulWidget {
  const QuickSortPage({super.key});

  @override
  ConsumerState<QuickSortPage> createState() => _QuickSortPageState();
}

class _QuickSortPageState extends ConsumerState<QuickSortPage> {
  @override
  void deactivate() {
    ref.invalidate(_notifierProvider); // deletes current instance and resets
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return SortingPage(instance: _notifierProvider, title: StringsManager.quickSort);
  }
}
