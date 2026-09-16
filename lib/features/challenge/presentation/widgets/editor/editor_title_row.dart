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
          child: SemiBoldText(problemName, color: ThemeEnum.inkTitle, maxLines: 1),
        ),
        const RSizedBox(width: 7),
        Consumer(
          builder: (context, ref, child) {
            final provider = codeEditorControllerProvider(problemId);
            final copied = ref.watch(provider.select((s) => s.copied));

            return IconButtonQuiet(
              icon: copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 34,
              iconSize: 18,
              iconColor: copied ? ThemeEnum.dataEasy : null,
              onTap: () => ref.read(provider.notifier).copyCode(),
            );
          },
        ),
      ],
    );
  }
}
