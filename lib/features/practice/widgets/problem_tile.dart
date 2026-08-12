import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/practice/helper/problem.dart';
import 'package:algorithm_visualizer/features/practice/helper/problem_style.dart';
import 'package:algorithm_visualizer/features/practice/view_model/challenges_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProblemTile extends ConsumerWidget {
  final Problem problem;
  final VoidCallback onSolve;

  const ProblemTile({super.key, required this.problem, required this.onSolve});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(
      challengesProvider.select((s) => s.expandedId == problem.id),
    );
    final diffColor = ProblemStyle.difficultyColor(context, problem.difficulty);
    final statusColor = ProblemStyle.statusColor(context, problem.status);
    final statusIcon = ProblemStyle.statusIcon(problem.status);

    return Padding(
      padding: REdgeInsets.only(bottom: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.card),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: expanded ? context.getColor(ThemeEnum.borderAccent) : context.getColor(ThemeEnum.border)),
          boxShadow: context.cardShadow,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MainRow(
              problem: problem,
              expanded: expanded,
              statusColor: statusColor,
              statusIcon: statusIcon,
              diffColor: diffColor,
              onTap: () => ref.read(challengesProvider.notifier).toggleExpanded(problem.id),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: expanded
                  ? _DetailsPanel(problem: problem, statusColor: statusColor, onSolve: onSolve)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainRow extends StatelessWidget {
  final Problem problem;
  final bool expanded;
  final Color statusColor;
  final Color diffColor;
  final IconData statusIcon;
  final VoidCallback onTap;

  const _MainRow({
    required this.problem,
    required this.expanded,
    required this.statusColor,
    required this.diffColor,
    required this.statusIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Icon(statusIcon, size: 16, color: statusColor),
            const RSizedBox(width: 8),
            Text(
              '${problem.num}.',
              style: GoogleFonts.jetBrainsMono(color: context.getColor(ThemeEnum.hover), fontSize: 11.r, fontWeight: FontWeight.w600),
            ),
            const RSizedBox(width: 6),
            Expanded(
              child: Text(
                problem.name,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(color: context.getColor(ThemeEnum.textSecond), fontSize: 13.r, fontWeight: FontWeight.w500),
              ),
            ),
            Text(problem.difficulty.difficultyString,
                style: GoogleFonts.inter(color: diffColor, fontSize: 11.r, fontWeight: FontWeight.w600)),
            const RSizedBox(width: 6),
            AnimatedRotation(
              turns: expanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.chevron_right_rounded, size: 16.r, color: context.getColor(ThemeEnum.hoverSecond)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  final Problem problem;
  final Color statusColor;
  final VoidCallback onSolve;

  const _DetailsPanel({required this.problem, required this.statusColor, required this.onSolve});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.getColor(ThemeEnum.border)))),
      padding: REdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: problem.tags
                .map((t) => Container(
                      padding: REdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.getColor(ThemeEnum.accentBg),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: context.getColor(ThemeEnum.borderAccent)),
                      ),
                      child:
                          Text(t, style: GoogleFonts.inter(color: context.getColor(ThemeEnum.accent), fontSize: 11.r)),
                    ))
                .toList(),
          ),
          const RSizedBox(height: 10),
          Row(
            children: [
              _StatColumn(label: 'Acceptance', value: '${problem.acceptance}%', color: context.getColor(ThemeEnum.textSecond)),
              const RSizedBox(width: 20),
              _StatColumn(
                label: 'Status',
                value: problem.status.difficultyString,
                color: statusColor,
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSolve,
                child: Container(
                  padding: REdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: context.getColor(ThemeEnum.accentBg),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: context.getColor(ThemeEnum.borderAccent)),
                  ),
                  child: Text('Solve →',
                      style: GoogleFonts.inter(
                          color: context.getColor(ThemeEnum.accent), fontSize: 12.r, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: context.getColor(ThemeEnum.hover), fontSize: 10.r)),
        const RSizedBox(height: 2),
        Text(value, style: GoogleFonts.inter(color: color, fontSize: 13.r, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
