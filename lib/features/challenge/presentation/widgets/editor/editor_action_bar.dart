import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/bottom_cta_bar.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/primary_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/secondary_button_quiet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditorActionBar extends StatelessWidget {
  const EditorActionBar({
    super.key,
    required this.onReset,
    required this.onRun,
    required this.running,
  });

  final VoidCallback onReset;
  final VoidCallback onRun;

  final bool running;

  @override
  Widget build(BuildContext context) {
    return BottomCtaBar(
      child: Row(
        children: [
          SecondaryButtonQuiet(
            label: StringsManager.reset,
            onPressed: onReset,
            expand: false,
            borderColor: ThemeEnum.editorResetBorder,
            horizontalInnerPadding: 24,
          ),
          const RSizedBox(width: 16),
          Expanded(
            child: PrimaryButtonQuiet(
              label: running ? StringsManager.running : StringsManager.runAndSubmit,
              onPressed: running ? null : onRun,
            ),
          ),
        ],
      ),
    );
  }
}
