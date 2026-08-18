import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/problems_notifier.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/profile_stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeData {
  const HomeData({
    required this.greeting,
    required this.stats,
    required this.continueProblem,
    required this.categoryItems,
    required this.recentActivity,
  });

  final String greeting;
  final ProfileStats stats;
  final CodingProblem? continueProblem;
  final List<CategoryItem> categoryItems;
  final List<RecentSubmission> recentActivity;
}

class CategoryItem {
  const CategoryItem({
    required this.name,
    required this.solved,
    required this.total,
    required this.icon,
  });

  final String name;
  final int solved;
  final int total;
  final IconData icon;
}

final homeDataProvider = Provider<HomeData>((ref) {
  final asyncProblems = ref.watch(problemsProvider);
  final stats = ref.watch(profileStatsProvider);

  return asyncProblems.when(
    data: (problems) {
      final greeting = _computeGreeting();
      final continueProblem = _findContinueProblem(problems);
      final categoryItems = _computeCategoryItems(problems);
      final recentActivity = stats.recentSubmissions;

      return HomeData(
        greeting: greeting,
        stats: stats,
        continueProblem: continueProblem,
        categoryItems: categoryItems,
        recentActivity: recentActivity,
      );
    },
    loading: () => HomeData(
      greeting: _computeGreeting(),
      stats: stats,
      continueProblem: null,
      categoryItems: [],
      recentActivity: [],
    ),
    error: (_, __) => HomeData(
      greeting: _computeGreeting(),
      stats: stats,
      continueProblem: null,
      categoryItems: [],
      recentActivity: [],
    ),
  );
});

String _computeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

CodingProblem? _findContinueProblem(List<CodingProblem> problems) {
  final attempted = problems
      .where((p) => !p.isSolved && p.getSolutionsStatus.isNotEmpty)
      .toList();
  if (attempted.isNotEmpty) return attempted.first;

  final unsolved = problems.where((p) => !p.isSolved).toList();
  return unsolved.isNotEmpty ? unsolved.first : null;
}

final _categoryIconMap = <String, IconData>{
  'Arrays': Icons.list_rounded,
  'Linked List': Icons.link_rounded,
  'Hash Table': Icons.table_chart_rounded,
  'Stack': Icons.layers_rounded,
  'Queue': Icons.view_stream_rounded,
  'Tree': Icons.account_tree_rounded,
  'Graph': Icons.hub_rounded,
  'Dynamic Programming': Icons.insights_rounded,
  'Binary Search': Icons.search_rounded,
  'Sorting': Icons.sort_rounded,
  'Greedy': Icons.trending_up_rounded,
  'Backtracking': Icons.undo_rounded,
  'Bit Manipulation': Icons.code_rounded,
  'Math': Icons.calculate_rounded,
  'String': Icons.text_fields_rounded,
  'Heap': Icons.grid_view_rounded,
  'Two Pointers': Icons.swap_horiz_rounded,
  'Sliding Window': Icons.swipe_rounded,
  'Divide and Conquer': Icons.call_split_rounded,
};

List<CategoryItem> _computeCategoryItems(List<CodingProblem> problems) {
  final categoryCount = <String, int>{};
  final categoryTotal = <String, int>{};

  for (final p in problems) {
    final cat = p.getCategory;
    if (cat.isEmpty) continue;
    categoryTotal[cat] = (categoryTotal[cat] ?? 0) + 1;
    if (p.isSolved) {
      categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
    }
  }

  final items = categoryCount.entries.map((e) {
    final total = categoryTotal[e.key] ?? 0;
    return CategoryItem(
      name: e.key,
      solved: e.value,
      total: total,
      icon: _categoryIconMap[e.key] ?? Icons.category_rounded,
    );
  }).toList()
    ..sort((a, b) => b.solved.compareTo(a.solved));

  return items;
}
