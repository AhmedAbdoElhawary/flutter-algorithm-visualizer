import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_back_button.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/code_editor/code_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditorTitleRow extends StatelessWidget {
  const EditorTitleRow({super.key, required this.problemName, required this.problemId});

  final String problemName;
  final int problemId;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CustomBackButton(),
        Expanded(
          child: SemiBoldText(problemName,  color: ThemeEnum.textPrimary, maxLines: 1),
        ),
        const RSizedBox(width: 8),
        const _LanguageChip(),
        const RSizedBox(width: 7),
        Consumer(
          builder: (context, ref, child) {
            final provider = codeEditorControllerProvider(problemId);
            final copied = ref.watch(provider.select((s) => s.copied));

            return IconButtonQuiet(
              icon: copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 34,
              iconSize: 18,
              iconColor: copied ? ThemeEnum.difficultyEasy : null,
              onTap: () => ref.read(provider.notifier).copyCode(),
            );
          },
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(vertical: 8, horizontal: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CdRadius.sm.r),
        border: Border.all(color: context.getColor(ThemeEnum.border)),
      ),
      child: const RegularText(
        StringsManager.dart,
        fontFamily: FontConstants.fontJetBrainsMono,
        fontSize: 11,
        color: ThemeEnum.textBody,
        maxLines: 1,
      ),
    );
  }
}
