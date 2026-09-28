import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart'
    show problemsProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({required this.isBookmarked, required this.problem, super.key});
  final bool isBookmarked;
  final CodingProblem problem;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(problemsProvider.notifier).toggleBookmark(problem);
      },
      child: CustomIcon(
        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        color: isBookmarked ? ThemeEnum.inkPrimary : ThemeEnum.inkPrimary,
        size: 18,
      ),
    );
  }
}
