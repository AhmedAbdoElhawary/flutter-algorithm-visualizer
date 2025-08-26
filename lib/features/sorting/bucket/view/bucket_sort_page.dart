import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_page.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/bucket/view_model/bucket_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => BucketSortNotifier(),
);

class BucketSortPage extends StatefulWidget {
  const BucketSortPage({super.key});

  @override
  State<BucketSortPage> createState() => _BucketSortPageState();
}

class _BucketSortPageState extends State<BucketSortPage> {
  @override
  Widget build(BuildContext context) {
    return SortingPage(instance: _notifierProvider, title: StringsManager.bucketSort);
  }
}
