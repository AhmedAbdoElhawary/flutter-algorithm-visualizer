import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    required this.numbersPadding,
    this.activeLine,
    this.borderRadius,
    this.errorLine,
    this.highlightedLines,
  });

  final int lineCount;
  final CodeEditorTheme theme;
  final ScrollController scrollController;
  final double lineHeight;
  final double numbersPadding;

  /// Zero-based index of the line the caret is currently on, used to
  /// bold/highlight the active line number. Null for no highlight.
  final int? activeLine;

  /// Zero-based index of a line flagged with a syntax/runtime error. When
  /// set, that line's number is painted in [CodeEditorTheme.errorColor].
  final int? errorLine;
  final BorderRadiusGeometry? borderRadius;

  /// Mirrors `CodeController.highlightedLines`: a translucent background
  /// per gutter row for lines highlighted via `CodeController.highlightLine`.
  final Map<int, Color>? highlightedLines;

  @override
  Widget build(BuildContext context) {
    final int digits = '$lineCount'.length;
    final border = theme.border;

    return Container(
      padding: EdgeInsets.only(
          bottom: theme.gutterPadding.bottom + numbersPadding,
          top: theme.gutterPadding.top,
          left: theme.gutterPadding.left,
          right: theme.gutterPadding.right),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: theme.lineNumberBackground ?? theme.background,
        border: theme.borderBetweenNumbersAndEditor && border != null ? BorderDirectional(end: border.left) : null,
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List<Widget>.generate(lineCount, (int index) {
            final bool isActive = index == activeLine;
            final bool isError = index == errorLine;
            final Color? highlight = isError ? null : highlightedLines?[index];
            TextStyle style = theme.lineNumberStyle;
            if (isActive) {
              style = style.copyWith(color: theme.textStyle.color);
            }
            if (isError) {
              style = style.copyWith(
                color: theme.errorColor,
                fontWeight: FontWeight.bold,
              );
            }
            if (highlight != null) {
              style = style.copyWith(
                color: highlight,
                fontWeight: FontWeight.bold,
              );
            }
            return Container(
              padding: REdgeInsets.only(top: numbersPadding),
              height: lineHeight,
              child: Center(child: Text('${index + 1}'.padLeft(digits), style: style)),
            );
          }),
        ),
      ),
    );
  }
}
