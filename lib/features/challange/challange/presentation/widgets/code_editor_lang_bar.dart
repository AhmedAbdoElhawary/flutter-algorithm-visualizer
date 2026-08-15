import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CodeEditorLangBar extends StatelessWidget {
  const CodeEditorLangBar({
    super.key,
    required this.isRunning,
    required this.copied,
    required this.onCopy,
    required this.onRun,
    this.language = StringsManager.dart,
  });

  final bool isRunning;
  final bool copied;
  final Future<void> Function() onCopy;
  final VoidCallback onRun;
  final String language;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isThemeDark;

    return SliverPadding(
      padding: REdgeInsets.fromLTRB(16, 0, 16, 10),
      sliver: SliverToBoxAdapter(
        child: Row(children: [
          Container(
            padding: REdgeInsets.symmetric(vertical: 3, horizontal: 10),
            decoration: BoxDecoration(
              color: context.getColor(ThemeEnum.card),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.getColor(ThemeEnum.border)),
              boxShadow: context.cardShadow,
            ),
            child: Container(
              padding: REdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: context.getColor(ThemeEnum.accentBg),
                borderRadius: BorderRadius.circular(7),
              ),
              child: SemiBoldText(language, color: ThemeEnum.accent, fontSize: 12),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: context.getColor(ThemeEnum.card),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.getColor(ThemeEnum.border)),
                boxShadow: context.cardShadow,
              ),
              child: CustomIcon(
                copied ? Icons.check_rounded : Icons.copy_rounded,
                color: copied ? ThemeEnum.accentGreen : ThemeEnum.hover,
                size: 15,
              ),
            ),
          ),
          const RSizedBox(width: 8),
          GestureDetector(
            onTap: isRunning ? null : onRun,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: REdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isRunning ? context.getColor(ThemeEnum.card) : null,
                gradient: isRunning
                    ? null
                    : LinearGradient(
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                        colors: [
                          context.getColor(ThemeEnum.accentGreen),
                          context.getColor(ThemeEnum.accentGreen)
                        ],
                      ),
                borderRadius: BorderRadius.circular(9),
                border: isRunning ? Border.all(color: context.getColor(ThemeEnum.border)) : null,
                boxShadow: isRunning
                    ? context.cardShadow
                    : [
                        BoxShadow(
                            color: context
                                .getColor(ThemeEnum.accentGreen)
                                .withValues(alpha: isDark ? 0.3 : 0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 4)),
                      ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                CustomIcon(Icons.play_arrow_rounded,
                    size: 14, color: isRunning ? ThemeEnum.hover : ThemeEnum.solidWhite),
                const RSizedBox(width: 4),
                SemiBoldText(
                  isRunning ? StringsManager.running : StringsManager.run,
                  color: isRunning ? ThemeEnum.hover : ThemeEnum.solidWhite,
                  fontSize: 13,
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
