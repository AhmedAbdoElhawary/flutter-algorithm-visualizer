import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CodeEditorLangBar extends StatelessWidget {
  const CodeEditorLangBar({
    super.key,
    required this.isRunning,
    required this.copied,
    required this.onCopy,
    required this.onRun,
    this.language = 'Dart',
  });

  final bool isRunning;
  final bool copied;
  final VoidCallback onCopy;
  final VoidCallback onRun;
  final String language;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isThemeDark;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      sliver: SliverToBoxAdapter(
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            decoration: BoxDecoration(
              color: context.getColor(ThemeEnum.card),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.getColor(ThemeEnum.border)),
              boxShadow: context.cardShadow,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: context.getColor(ThemeEnum.accentBg),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                language,
                style: GoogleFonts.inter(
                  color: context.getColor(ThemeEnum.accent),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.getColor(ThemeEnum.card),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.getColor(ThemeEnum.border)),
                boxShadow: context.cardShadow,
              ),
              child: Icon(
                copied ? Icons.check_rounded : Icons.copy_rounded,
                size: 15,
                color: copied ? context.getColor(ThemeEnum.accentGreen) : context.getColor(ThemeEnum.hover),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isRunning ? null : onRun,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isRunning ? context.getColor(ThemeEnum.card) : null,
                gradient: isRunning
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [context.getColor(ThemeEnum.accentGreen), context.getColor(ThemeEnum.accentGreen)],
                      ),
                borderRadius: BorderRadius.circular(9),
                border: isRunning ? Border.all(color: context.getColor(ThemeEnum.border)) : null,
                boxShadow: isRunning
                    ? context.cardShadow
                    : [
                        BoxShadow(
                            color: context.getColor(ThemeEnum.accentGreen).withValues(alpha: isDark ? 0.3 : 0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 4)),
                      ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.play_arrow_rounded, size: 14, color: isRunning ? context.getColor(ThemeEnum.hover) : Colors.white),
                const SizedBox(width: 4),
                Text(isRunning ? 'Running…' : 'Run',
                    style: GoogleFonts.inter(
                      color: isRunning ? context.getColor(ThemeEnum.hover) : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
