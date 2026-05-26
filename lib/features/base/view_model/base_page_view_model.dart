import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/sorting/bubble/view_model/bubble_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/bucket/view_model/bucket_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/counting/view_model/counting_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/heap/view_model/heap_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/insertion/view_model/insertion_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/merge/view_model/merge_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/quick/view_model/quick_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/radix/view_model/radix_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/selection/view_model/selection_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/shell/view_model/shell_sort_notifier.dart';
import 'package:flutter/material.dart';

class AlgoCard {
  final GlassCard card;
  final RouteConfig route;
  AlgoCard({required this.route, required this.card});
}

class BasePageViewModel {
  static final searchingCard = [];
  static final sortingCards = [
    AlgoCard(
      route: Routes.bubbleSort,
      card: GlassCard(
        algoComplexity: BubbleSortNotifier.algorithmComplexity,
        color: Color(0xFF5B9CF6),
        icon: Icons.auto_graph,
      ),
    ),
    AlgoCard(
      route: Routes.selectionSort,
      card: GlassCard(
        algoComplexity: SelectionSortNotifier.algorithmComplexity,
        color: Color(0xFFFFA726),
        icon: Icons.my_location,
      ),
    ),
    AlgoCard(
      route: Routes.insertionSort,
      card: GlassCard(
        algoComplexity: InsertionSortNotifier.algorithmComplexity,
        color: Color(0xFF66BB6A),
        icon: Icons.input,
      ),
    ),
    AlgoCard(
      route: Routes.mergeSort,
      card: GlassCard(
        algoComplexity: MergeSortNotifier.algorithmComplexity,
        color: Color(0xFFA78BFA),
        icon: Icons.merge_type,
      ),
    ),
    AlgoCard(
      route: Routes.quickSort,
      card: GlassCard(
        algoComplexity: QuickSortNotifier.algorithmComplexity,
        color: Color(0xFFFB7185),
        icon: Icons.electric_bolt_rounded,
      ),
    ),
    AlgoCard(
      route: Routes.heapSort,
      card: GlassCard(
        algoComplexity: HeapSortNotifier.algorithmComplexity,
        color: Color(0xFF8D6E63),
        icon: Icons.account_tree,
      ),
    ),
    AlgoCard(
      route: Routes.shellSort,
      card: GlassCard(
        algoComplexity: ShellSortNotifier.algorithmComplexity,
        color: Color(0xFF26A69A),
        icon: Icons.blur_linear,
      ),
    ),
    AlgoCard(
      route: Routes.radixSort,
      card: GlassCard(
        algoComplexity: RadixSortNotifier.algorithmComplexity,
        color: Color(0xFF5C6BC0),
        icon: Icons.pin,
      ),
    ),
    AlgoCard(
      route: Routes.countingSort,
      card: GlassCard(
        algoComplexity: CountingSortNotifier.algorithmComplexity,
        color: Color(0xFF26C6DA),
        icon: Icons.format_list_numbered,
      ),
    ),
    AlgoCard(
      route: Routes.bucketSort,
      card: GlassCard(
        algoComplexity: BucketSortNotifier.algorithmComplexity,
        color: Color(0xFFFF7043),
        icon: Icons.inventory_2,
      ),
    ),
  ];
}
