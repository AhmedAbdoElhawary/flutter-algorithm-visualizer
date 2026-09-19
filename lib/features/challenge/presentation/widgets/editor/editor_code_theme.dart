import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Builds the code card's [CodeEditorTheme] from [ThemeEnum] roles only.
///
/// The package's own `CodeEditorTheme.dark()` / `.light()` factories carry
/// hard-coded [Color] literals, so they are never used here (FR-007,
/// research R4) — every value below traces back to a `ThemeEnum` role.
///
/// Tokens use the dedicated `code*` roles rather than the `data*` ones. The
/// five `data*` colors are already spoken for by difficulty badges and charts,
/// which left strings and numbers sharing a single hue and gave the light
/// theme a palette tuned for a dark card.
CodeEditorTheme buildEditorCodeTheme(BuildContext context) {
  final plain = context.getColor(ThemeEnum.inkSecondaryTitle);

  return CodeEditorTheme(
    background: context.getColor(ThemeEnum.surface),
    caretColor: context.getColor(ThemeEnum.inkTitle),
    selectionColor: context.getColor(ThemeEnum.inkTitle).withValues(alpha: 0.24),
    border: null,
    borderRadius: const BorderRadiusDirectional.all(Radius.circular(15)),
    editorPadding: REdgeInsets.symmetric(vertical: 12),
    gutterPadding: REdgeInsets.only(right: 12),
    textStyle: TextStyle(
      fontFamily: FontConstants.fontFamily,
      fontSize: 13.sp,
      height: 1.85,
      color: plain,
    ),
    lineNumberStyle: TextStyle(
      fontFamily: FontConstants.fontFamily,
      fontSize: 13.sp,
      height: 1.85,
      color: context.getColor(ThemeEnum.inkThirdTitle),
    ),
    lineNumberBackground: context.getColor(ThemeEnum.surface),
    tokenColors: <TokenType, Color>{
      TokenType.keyword: context.getColor(ThemeEnum.codeKeyword),
      TokenType.builtin: context.getColor(ThemeEnum.codeBuiltin),
      TokenType.identifier: plain,
      TokenType.plain: plain,
      TokenType.operator: context.getColor(ThemeEnum.codePunct),
      TokenType.punctuation: context.getColor(ThemeEnum.codePunct),
      TokenType.number: context.getColor(ThemeEnum.codeNumber),
      TokenType.string: context.getColor(ThemeEnum.codeString),
      TokenType.comment: context.getColor(ThemeEnum.codeComment),
    },
  );
}

/// One code line's rendered height under [buildEditorCodeTheme] — mirrors
/// `CodeEditor`'s own `(fontSize * lineHeightMultiplier).r` formula exactly
/// (`code_editor.dart:160-162`) so [EditorCodeCard] can size itself to fit
/// every line without the package's internal scroll view ever engaging
/// (FR-002, research R3).
double editorCodeLineHeight(CodeEditorTheme theme) {
  final fontSize = theme.textStyle.fontSize ?? 14;
  final lineHeightMultiplier = theme.textStyle.height ?? 1.4;
  return (fontSize * lineHeightMultiplier).r;
}
