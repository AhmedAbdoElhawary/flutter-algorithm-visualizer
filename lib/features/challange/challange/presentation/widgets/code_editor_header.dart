import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TODO: wire `title` / `difficulty` up to the real `CodingProblem` entity
/// once it's fetched — kept as plain params for now so this widget stays
/// dumb and reusable.
class CodeEditorHeader extends StatelessWidget {
  const CodeEditorHeader({
    super.key,
    this.title = 'Two Sum',
    this.difficulty = 'Easy',
  });

  final String title;
  final String difficulty;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      sliver: SliverToBoxAdapter(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CODE EDITOR',
              style: GoogleFonts.inter(
                  color: context.getColor(ThemeEnum.hover), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Row(children: [
            Text(title,
                style: GoogleFonts.inter(
                    color: context.getColor(ThemeEnum.textPrimary), fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: context.isThemeDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(difficulty,
                  style: GoogleFonts.inter(
                      color: context.getColor(ThemeEnum.accentBlue), fontSize: 11, fontWeight: FontWeight.w600)),
            )
          ]),
        ]),
      ),
    );
  }
}
