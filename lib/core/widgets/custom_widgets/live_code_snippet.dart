
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LiveCodeSnippet extends ConsumerWidget {
  const LiveCodeSnippet({required this.currentLine,required this.codeLines,super.key});

  final List<String>  codeLines;
final int currentLine;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: REdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        withAboveShadow: false,
        borderRadius: 12,
        padding: REdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                CustomIcon(Icons.data_object_rounded, size: 14, color: ThemeEnum.hoverColor),
                RSizedBox(width: 6),
                MediumText(StringsManager.pseudocode, fontSize: 13, color: ThemeEnum.hoverColor),
                const Spacer(),
                // Pill showing which line is active.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: currentLine >= 0
                      ? Container(
                    key: ValueKey(currentLine),
                    padding: REdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.getColor(ThemeEnum.lightBlueColor).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: RegularText(
                      'L${currentLine + 1}',
                      fontSize: 11,
                      color: ThemeEnum.lightBlueColor,
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            RSizedBox(height: 12),
            // ── Code lines ───────────────────────────────────────────────────
            ...codeLines.asMap().entries.map((entry) {
              final i = entry.key;
              final isActive = i == currentLine;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: REdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? context.getColor(ThemeEnum.lightBlueColor).withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: isActive
                      ? Border(
                    left: BorderSide(
                      color: context.getColor(ThemeEnum.lightBlueColor),
                      width: 2.5,
                    ),
                  )
                      : null,
                ),
                padding: REdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    // Line number
                    SizedBox(
                      width: 20,
                      child: RegularText(
                        '${i + 1}',
                        fontSize: 11,
                        color: isActive ? ThemeEnum.lightBlueColor : ThemeEnum.hoverColor,
                      ),
                    ),
                    RSizedBox(width: 10),
                    // Code text — grows to fill available space
                    Expanded(
                      child: RegularText(
                        entry.value,
                        fontSize: 12,
                        color: isActive ? ThemeEnum.white2DarkColor : ThemeEnum.hoverColor,
                      ),
                    ),
                    // Execution arrow shown only on the active line
                    if (isActive)
                      CustomIcon(
                        Icons.arrow_right_rounded,
                        size: 16,
                        color: ThemeEnum.lightBlueColor,
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
