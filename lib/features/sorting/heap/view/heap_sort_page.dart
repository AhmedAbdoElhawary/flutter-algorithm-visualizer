import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_page.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/heap/view_model/heap_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => HeapSortNotifier(),
);

class HeapSortPage extends StatefulWidget {
  const HeapSortPage({super.key});

  @override
  State<HeapSortPage> createState() => _HeapSortPageState();
}

class _HeapSortPageState extends State<HeapSortPage> {

  @override
  Widget build(BuildContext context) {
    return SortingPage(instance: _notifierProvider, title: StringsManager.heapSort);
  }
}
