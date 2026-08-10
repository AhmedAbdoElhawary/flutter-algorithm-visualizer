import 'package:algorithm_visualizer/core/helpers/app_bar/app_bar.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/base/view/base_navigation.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:algorithm_visualizer/features/searching/bfs/view/bfs_searching.dart';
import 'package:algorithm_visualizer/features/searching/dfs/view/dfs_searching.dart';
import 'package:algorithm_visualizer/features/searching/star/view/a_star_searching.dart';
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
import 'package:algorithm_visualizer/features/visualize/view/visualize_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'unknown_page.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _tabAKey = GlobalKey<NavigatorState>();
final _tabBKey = GlobalKey<NavigatorState>();

class Routes {
  static const RouteConfig home = RouteConfig(
    name: 'home',
    path: '/home',
  );
  static const RouteConfig visualize = RouteConfig(
    name: 'visualize',
    path: '/visualize',
    queryParamsName: "instance",
  );
  static const RouteConfig bfsSearching = RouteConfig(
    name: 'bfsSearching',
    path: 'bfsSearching',
  );
  static const RouteConfig dfsSearching = RouteConfig(
    name: 'dfsSearching',
    path: '/visualize/dfsSearching',
  );
  static const RouteConfig aStarSearching = RouteConfig(
    name: 'aStarSearching',
    path: '/visualize/aStarSearching',
  );

  static const RouteConfig bubbleSort = RouteConfig(
    name: 'bubbleSort',
    path: '/visualize/bubbleSort',
  );
  static const RouteConfig insertionSort = RouteConfig(
    name: 'insertionSort',
    path: 'insertionSort',
  );
  static const RouteConfig selectionSort = RouteConfig(
    name: 'selectionSort',
    path: '/visualize/selectionSort',
  );
  static const RouteConfig mergeSort = RouteConfig(
    name: 'mergeSort',
    path: '/visualize/mergeSort',
  );
  static const RouteConfig heapSort = RouteConfig(
    name: 'heapSort',
    path: '/visualize/heapSort',
  );
  static const RouteConfig quickSort = RouteConfig(
    name: 'quickSort',
    path: '/visualize/quickSort',
  );
  static const RouteConfig radixSort = RouteConfig(
    name: 'radixSort',
    path: '/visualize/radixSort',
  );
  static const RouteConfig shellSort = RouteConfig(
    name: 'shellSort',
    path: '/visualize/shellSort',
  );
  static const RouteConfig countingSort = RouteConfig(
    name: 'countingSort',
    path: '/visualize/countingSort',
  );
  static const RouteConfig bucketSort = RouteConfig(
    name: 'bucketSort',
    path: '/visualize/bucketSort',
  );
  static const RouteConfig comparisonSort = RouteConfig(
    name: 'comparisonSort',
    path: '/visualize/comparisonSort',
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
    navigatorKey: _rootKey,
    initialLocation: Routes.home.path,
    errorBuilder: (context, state) => const _UnknownPage(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _tabAKey,
            routes: [
              GoRoute(
                path: Routes.home.path,
                name: Routes.home.name,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _tabBKey,
            routes: [
              GoRoute(
                path: Routes.visualize.path,
                name: Routes.visualize.name,
                builder: (context, state) {
                  final instance = state.uri.queryParameters["instance"];
                  final sortingAlgo =
                      SortingAlgoCards.values.firstWhereOrNull((element) => element.name == instance);
                  final searchingAlgo =
                      SearchingAlgoCards.values.firstWhereOrNull((element) => element.name == instance);
                  if (instance != null && (sortingAlgo == null && searchingAlgo == null)) {
                    return _UnknownPage();
                  }
                  return VisualizePage(sortingCard: sortingAlgo, searchingCard: searchingAlgo);
                },
                routes: [
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
          ),
        ],
      ),
    ],
  );
}
