import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/aurora_chips.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/helper/problem_style.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart'
    show challengesProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Aurora screen 07. One saved problem — a card-depth glass row: title + a
/// filled bookmark glyph, then a difficulty chip and up to two neutral tag
/// chips. Swipe (or tap the glyph) removes it from bookmarks.
class BookmarkRow extends ConsumerWidget {
  const BookmarkRow({super.key, required this.problem, required this.onTap});

  final CodingProblem problem;
  final VoidCallback onTap;

  void _unbookmark(WidgetRef ref) =>
      ref.read(challengesProvider.notifier).toggleBookmark(problem);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difficulty = problem.getDifficulty;
    final chipDifficulty = ProblemStyle.chipDifficulty(difficulty);
    final tags = problem.getTags.take(2).toList();

    return Dismissible(
      key: ValueKey(problem.getProblemId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _unbookmark(ref),
      child: GlassContainer(
        depth: GlassDepth.card,
        borderRadius: 14,
        padding: REdgeInsets.symmetric(horizontal: 14, vertical: 13),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SemiBoldText(
                    problem.getName,
                    color: ThemeEnum.textBright,
                    fontSize: 12.5,
                    maxLines: 2,
                  ),
                ),
                const RSizedBox(width: 10),
                GestureDetector(
                  onTap: () => _unbookmark(ref),
                  child: const CustomIcon(Icons.bookmark_rounded,
                      size: 14, color: ThemeEnum.textPrimary),
                ),
              ],
            ),
            const RSizedBox(height: 9),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (chipDifficulty != null)
                  DifficultyChip(
                    difficulty: chipDifficulty,
                    label: difficulty.difficultyString,
                    fontSize: 9.5,
                    radius: 6,
                  ),
                for (final tag in tags)
                  TagChip(label: tag, fontSize: 9.5, radius: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
