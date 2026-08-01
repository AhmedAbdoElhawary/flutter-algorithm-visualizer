import 'package:flutter/widgets.dart';

import '../models/code_editor_theme.dart';

/// The line-number gutter shown on the left side of [CodeEditor].
///
/// This is a plain, dumb rendering widget: it receives [lineCount] and a
/// [scrollController] that's kept in sync with the editor's own text
/// scroll view by [CodeEditor], and just paints numbers. It has no
/// knowledge of tokens, editing, or the controller.
class LineNumbers extends StatelessWidget {
  const LineNumbers({
    super.key,
    required this.lineCount,
    required this.theme,
    required this.scrollController,
    required this.lineHeight,
    this.activeLine,
  });

  final int lineCount;
  final CodeEditorTheme theme;
  final ScrollController scrollController;
  final double lineHeight;

  /// Zero-based index of the line the caret is currently on, used to
  /// bold/highlight the active line number. Null for no highlight.
  final int? activeLine;

  @override
  Widget build(BuildContext context) {
    final int digits = '$lineCount'.length;

    return Container(
      color: theme.lineNumberBackground ?? theme.background,
      padding: theme.gutterPadding,
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List<Widget>.generate(lineCount, (int index) {
            final bool isActive = index == activeLine;
            return SizedBox(
              height: lineHeight,
              child: Text(
                '${index + 1}'.padLeft(digits),
                style: isActive
                    ? theme.lineNumberStyle
                        .copyWith(color: theme.textStyle.color)
                    : theme.lineNumberStyle,
              ),
            );
          }),
        ),
      ),
    );
  }
}
