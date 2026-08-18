import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/code_editor/code_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CodeEditorLangBar extends ConsumerWidget {
  const CodeEditorLangBar({
    super.key,
    required this.problem,
    this.language = StringsManager.dart,
  });

  final String language;
  final CodingProblem problem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isThemeDark;
    final provider = codeEditorControllerProvider(problem.problemId ?? 0);
    final notifier = ref.read(provider.notifier);

    return SliverPadding(
      padding: REdgeInsets.fromLTRB(16, 0, 16, 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Container(
              padding: REdgeInsets.symmetric(vertical: 4, horizontal: 4),
              decoration: BoxDecoration(
                color: context.getColor(ThemeEnum.card),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.getColor(ThemeEnum.border)),
                boxShadow: context.cardShadow,
              ),
              child: Container(
                padding: REdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: context.getColor(ThemeEnum.accentBlueBg),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: SemiBoldText(language, color: ThemeEnum.accentBlue, fontSize: 12),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: notifier.copyCode,
              child: Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: context.getColor(ThemeEnum.card),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.getColor(ThemeEnum.border)),
                  boxShadow: context.cardShadow,
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final copied = ref.watch(provider.select((value) => value.copied));

                    return CustomIcon(
                      copied ? Icons.check_rounded : Icons.copy_rounded,
                      color: copied ? ThemeEnum.accentGreen : ThemeEnum.hover,
                      size: 15,
                    );
                  },
                ),
              ),
            ),
            const RSizedBox(width: 8),

            /// TODO: add this button, but make sure you saved every time user write a code (auto save)
            // AnimatedPopup(
            //   builder: (removeOverlay) => _ResetPopupContent(
            //     onCancel: removeOverlay,
            //     onConfirm: () {
            //       notifier.resetCode();
            //       removeOverlay();
            //     },
            //   ),
            //   child: Container(
            //     width: 32.r,
            //     height: 32.r,
            //     decoration: BoxDecoration(
            //       color: context.getColor(ThemeEnum.card),
            //       borderRadius: BorderRadius.circular(8),
            //       border: Border.all(color: context.getColor(ThemeEnum.border)),
            //       boxShadow: context.cardShadow,
            //     ),
            //     child: CustomIcon(Icons.restore_rounded, color: ThemeEnum.hover, size: 15),
            //   ),
            // ),
            // const RSizedBox(width: 8),
            Consumer(
              builder: (context, ref, child) {
                final isRunning = ref.watch(provider.select((value) => value.isRunning));

                return GestureDetector(
                  onTap: isRunning
                      ? null
                      : () async {
                          await notifier.runCode(
                            (result) async {
                              if (result == null) return;
                              if (!(!result.allPassed && problem.isThereAnyCorrectCodeSaved)) {
                                await ref.read(challengesProvider.notifier).updateProblem(problem, result);
                              }
                            },
                          );
                        },
                  child: Container(
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIcon(Icons.play_arrow_rounded,
                            size: 14, color: isRunning ? ThemeEnum.hover : ThemeEnum.solidWhite),
                        const RSizedBox(width: 4),
                        BoldText(
                          isRunning ? StringsManager.running : StringsManager.run,
                          color: isRunning ? ThemeEnum.hover : ThemeEnum.solidWhite,
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
//
// class _ResetPopupContent extends StatelessWidget {
//   const _ResetPopupContent({required this.onConfirm, required this.onCancel});
//
//   final VoidCallback onConfirm;
//   final VoidCallback onCancel;
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.sizeOf(context).width * 0.82;
//
//     return SizedBox(
//       width: width,
//       child: Container(
//         padding: REdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: context.getColor(ThemeEnum.card),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: context.getColor(ThemeEnum.border)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(children: [
//               Container(
//                 padding: REdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: context.getColor(ThemeEnum.accentRedRc).withValues(alpha: 0.12),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: CustomIcon(Icons.restore_rounded, size: 18, color: ThemeEnum.accentRed),
//               ),
//               RSizedBox(width: 10),
//               Expanded(child: BoldText(StringsManager.resetCode, color: ThemeEnum.textSecond, fontSize: 15)),
//             ]),
//             RSizedBox(height: 12),
//             RegularText(
//               StringsManager.resetCodeDesc,
//               color: ThemeEnum.hover,
//               fontSize: 13,
//               height: 1.5,
//             ),
//             RSizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 InkWell(
//                   onTap: onCancel,
//                   child: Container(
//                     padding: REdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: context.getColor(ThemeEnum.border)),
//                     ),
//                     child: RegularText(StringsManager.noCancel, color: ThemeEnum.hoverSecond, fontSize: 13),
//                   ),
//                 ),
//                 RSizedBox(width: 8),
//                 InkWell(
//                   onTap: onConfirm,
//                   child: Container(
//                     padding: REdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: context.getColor(ThemeEnum.accentRedRc),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: SemiBoldText(StringsManager.yesReset, color: ThemeEnum.solidWhite, fontSize: 13),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
