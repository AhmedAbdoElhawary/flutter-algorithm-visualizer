import 'package:algorithm_visualizer/core/helpers/app_bar/app_bar.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/base/view/base_page.dart';
import 'package:algorithm_visualizer/features/searching/view/a_star_searching.dart';
import 'package:algorithm_visualizer/features/searching/view/bfs_searching.dart';
import 'package:algorithm_visualizer/features/searching/view/dfs_searching.dart';
import 'package:algorithm_visualizer/features/sorting/bubble/view/bubble_sort_page.dart';
import 'package:algorithm_visualizer/features/sorting/bucket/view/bucket_sort_page.dart';
import 'package:algorithm_visualizer/features/sorting/comparison/view/comparison_sort_page.dart';
import 'package:algorithm_visualizer/features/sorting/counting/view/counting_sort_page.dart';
import 'package:algorithm_visualizer/features/sorting/heap/view/heap_sort_page.dart';
import 'package:algorithm_visualizer/features/sorting/insertion/view/insertion_sort_page.dart';
import 'package:algorithm_visualizer/features/sorting/merge/view/merge_sort_page.dart';
import 'package:algorithm_visualizer/features/sorting/quick/view/quick_sort_page.dart';
import 'package:algorithm_visualizer/features/sorting/radix/view/radix_sort_page.dart';
import 'package:algorithm_visualizer/features/sorting/selection/view/selection_sort_page.dart';
import 'package:algorithm_visualizer/features/sorting/shell/view/shell_sort_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'unknown_page.dart';

class Routes {
  static const RouteConfig base = RouteConfig(
    name: 'base',
    path: '/',
  );
  static const RouteConfig bfsSearching = RouteConfig(
    name: 'bfsSearching',
    path: '/bfsSearching',
  );
  static const RouteConfig dfsSearching = RouteConfig(
    name: 'dfsSearching',
    path: '/dfsSearching',
  );
  static const RouteConfig aStarSearching = RouteConfig(
    name: 'aStarSearching',
    path: '/aStarSearching',
  );

  static const RouteConfig bubbleSort = RouteConfig(
    name: 'bubbleSort',
    path: '/bubbleSort',
  );
  static const RouteConfig insertionSort = RouteConfig(
    name: 'insertionSort',
    path: '/insertionSort',
  );
  static const RouteConfig selectionSort = RouteConfig(
    name: 'selectionSort',
    path: '/selectionSort',
  );
  static const RouteConfig mergeSort = RouteConfig(
    name: 'mergeSort',
    path: '/mergeSort',
  );
  static const RouteConfig heapSort = RouteConfig(
    name: 'heapSort',
    path: '/heapSort',
  );
  static const RouteConfig quickSort = RouteConfig(
    name: 'quickSort',
    path: '/quickSort',
  );
  static const RouteConfig radixSort = RouteConfig(
    name: 'radixSort',
    path: '/radixSort',
  );
  static const RouteConfig shellSort = RouteConfig(
    name: 'shellSort',
    path: '/shellSort',
  );
  static const RouteConfig countingSort = RouteConfig(
    name: 'countingSort',
    path: '/countingSort',
  );
  static const RouteConfig bucketSort = RouteConfig(
    name: 'bucketSort',
    path: '/bucketSort',
  );
  static const RouteConfig comparisonSort = RouteConfig(
    name: 'comparisonSort',
    path: '/comparisonSort',
  );
}

class RouteConfig {
  final String name;
  final String path;
  final String pathParamsName;
  final String queryParamsName;

  const RouteConfig({
    required this.name,
    required this.path,
    this.pathParamsName = "",
    this.queryParamsName = "",
  });
}

class AppRoutes {
  static final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: Routes.base.path,
    errorBuilder: (context, state) => const _UnknownPage(),
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return child;
        },
        routes: [
          GoRoute(
            path: Routes.base.path,
            name: Routes.base.name,
            builder: (context, state) => const BasePage(),
          ),
          GoRoute(
            path: Routes.bfsSearching.path,
            name: Routes.bfsSearching.name,
            builder: (context, state) => const BFSSearchingPage(),
          ),
          GoRoute(
            path: Routes.dfsSearching.path,
            name: Routes.dfsSearching.name,
            builder: (context, state) => const DFSSearchingPage(),
          ),
          GoRoute(
            path: Routes.aStarSearching.path,
            name: Routes.aStarSearching.name,
            builder: (context, state) => const AStarSearchingPage(),
          ),
          GoRoute(
            path: Routes.bubbleSort.path,
            name: Routes.bubbleSort.name,
            builder: (context, state) {
              return const BubbleSortPage();
            },
          ),
          GoRoute(
            path: Routes.insertionSort.path,
            name: Routes.insertionSort.name,
            builder: (context, state) {
              return const InsertionSortPage();
            },
          ),
          GoRoute(
            path: Routes.selectionSort.path,
            name: Routes.selectionSort.name,
            builder: (context, state) {
              return const SelectionSortPage();
            },
          ),
          GoRoute(
            path: Routes.mergeSort.path,
            name: Routes.mergeSort.name,
            builder: (context, state) {
              return const MergeSortPage();
            },
          ),
          GoRoute(
            path: Routes.heapSort.path,
            name: Routes.heapSort.name,
            builder: (context, state) {
              return const HeapSortPage();
            },
          ),
          GoRoute(
            path: Routes.quickSort.path,
            name: Routes.quickSort.name,
            builder: (context, state) {
              return const QuickSortPage();
            },
          ),
          GoRoute(
            path: Routes.radixSort.path,
            name: Routes.radixSort.name,
            builder: (context, state) {
              return const RadixSortPage();
            },
          ),
          GoRoute(
            path: Routes.shellSort.path,
            name: Routes.shellSort.name,
            builder: (context, state) {
              return const ShellSortPage();
            },
          ),
          GoRoute(
            path: Routes.countingSort.path,
            name: Routes.countingSort.name,
            builder: (context, state) {
              return const CountingSortPage();
            },
          ),
          GoRoute(
            path: Routes.bucketSort.path,
            name: Routes.bucketSort.name,
            builder: (context, state) {
              return const BucketSortPage();
            },
          ),
          GoRoute(
            path: Routes.comparisonSort.path,
            name: Routes.comparisonSort.name,
            builder: (context, state) {
              return const ComparisonSortPage();
            },
          ),
        ],
      ),
    ],
  );
}
