import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_page.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/radix/view_model/radix_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => RadixSortNotifier(),
);

class RadixSortPage extends StatefulWidget {
  const RadixSortPage({super.key});

  @override
  State<RadixSortPage> createState() => _RadixSortPageState();
}

class _RadixSortPageState extends State<RadixSortPage> {
  @override
  Widget build(BuildContext context) {
    return SortingPage(instance: _notifierProvider, title: StringsManager.radixSort);
  }
}
