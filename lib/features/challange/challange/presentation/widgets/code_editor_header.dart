import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';

class CodeEditorHeader extends StatelessWidget {
  const CodeEditorHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MediumText(
              StringsManager.codeEditor,
              color: ThemeEnum.hover,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}
