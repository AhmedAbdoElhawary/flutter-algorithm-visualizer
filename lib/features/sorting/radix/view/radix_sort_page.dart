import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_page_view_model.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_page.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/radix/view_model/radix_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => RadixSortNotifier(),
);

class RadixSortPage extends StatelessWidget {
  const RadixSortPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SortingPage(instance:  BasePageViewModel.sortingCards[StringsManager.radixSort]?.instance ?? _notifierProvider
        , title: StringsManager.radixSort);
  }
}
