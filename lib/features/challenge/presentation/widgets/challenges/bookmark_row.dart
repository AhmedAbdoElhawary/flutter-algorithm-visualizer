import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/secondary_problem_card.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/tag_chip.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart'
    show challengesProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aurora screen 07. One saved problem — a card-depth glass row: title + a
/// filled bookmark glyph, then a difficulty chip and up to two neutral tag
/// chips. Swipe (or tap the glyph) removes it from bookmarks.
class BookmarkRow extends ConsumerWidget {
  const BookmarkRow({super.key, required this.problem, required this.onTap});

  final CodingProblem problem;
  final VoidCallback onTap;

  void _unbookmark(WidgetRef ref) => ref.read(challengesProvider.notifier).toggleBookmark(problem);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = problem.getTags.take(2).toList();

    return Dismissible(
      key: ValueKey(problem.getProblemId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _unbookmark(ref),
      child: SecondaryProblemCard(
        onTap: onTap,
        isSolved: problem.isSolved,
        problemName: problem.getName,
        problemId: problem.getProblemId,
        difficulty: problem.getDifficulty,
        addCardDecoration: true,
        subTitle: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final tag in tags) TagChip(label: tag, fontSize: 9.5, radius: 6),
          ],
        ),
        leading: GestureDetector(
          onTap: () => _unbookmark(ref),
          child: const CustomIcon(Icons.bookmark_rounded, size: 14, color: ThemeEnum.textPrimary),
        ),
      ),
    );
  }
}
