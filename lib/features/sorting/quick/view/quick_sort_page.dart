import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_page.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/quick/view_model/quick_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => QuickSortNotifier(),
);

class QuickSortPage extends StatefulWidget {
  const QuickSortPage({super.key});

  @override
  State<QuickSortPage> createState() => _QuickSortPageState();
}

class _QuickSortPageState extends State<QuickSortPage> {
  @override
  Widget build(BuildContext context) {
    return SortingPage(instance: _notifierProvider, title: StringsManager.quickSort);
  }
}
