import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_code_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The code card (`04 · EDITOR`, `contracts/ui-contract.md` §2.2): a header
/// strip of three fixed decorative dots plus the file name, and the code
/// area below it. Sized to fit every line so the page-level scroll stays
/// the only vertical scroll on the page (FR-002, research R3).
class EditorCodeCard extends StatelessWidget {
  const EditorCodeCard({
    super.key,
    required this.fileName,
    required this.initialCode,
    required this.highlightedLine,
    required this.running,
    required this.onControllerAttached,
  });

  final String fileName;
  final String initialCode;
  final int? highlightedLine;
  final bool running;
  final void Function(CodeController controller) onControllerAttached;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      fillColor: ThemeEnum.codeBg,
      borderColorOverride: ThemeEnum.border,
      radius: CdRadius.md,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CodeCardHeader(fileName: fileName),
          _CodeArea(
            initialCode: initialCode,
            highlightedLine: highlightedLine,
            running: running,
            onControllerAttached: onControllerAttached,
          ),
        ],
      ),
    );
  }
}

class _CodeCardHeader extends StatelessWidget {
  const _CodeCardHeader({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(vertical: 9, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.getColor(ThemeEnum.borderSubtle))),
      ),
      child: Row(
        children: [
          const _Dot(ThemeEnum.difficultyHard),
          const RSizedBox(width: 5),
          const _Dot(ThemeEnum.difficultyMedium),
          const RSizedBox(width: 5),
          const _Dot(ThemeEnum.difficultyEasy),
          const Spacer(),
          RegularText(
            fileName,
            fontFamily: FontConstants.fontJetBrainsMono,
            fontSize: 10,
            color: ThemeEnum.codeComment,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);

  final ThemeEnum color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.r,
      height: 10.r,
      decoration: BoxDecoration(color: context.getColor(color), shape: BoxShape.circle),
    );
  }
}

class _CodeArea extends StatefulWidget {
  const _CodeArea({
    required this.initialCode,
    required this.highlightedLine,
    required this.running,
    required this.onControllerAttached,
  });

  final String initialCode;
  final int? highlightedLine;
  final bool running;
  final void Function(CodeController controller) onControllerAttached;

  @override
  State<_CodeArea> createState() => _CodeAreaState();
}

class _CodeAreaState extends State<_CodeArea> {
  late final CodeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CodeController(
      text: widget.initialCode,
      theme: CodeEditorTheme.dark(),
      tokenizer: const DartTokenizer(),
      runner: const DartInterpreterRunner(),
      config: const CodeEditorConfig(tabSize: 2, showLineNumbers: true),
    )..addListener(_onTextChanged);
    widget.onControllerAttached(_controller);
    _applyHighlight();
  }

  @override
  void didUpdateWidget(covariant _CodeArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlightedLine != widget.highlightedLine) _applyHighlight();
  }

  void _onTextChanged() => setState(() {});

  void _applyHighlight() {
    _controller.clearHighlights();
    final line = widget.highlightedLine;
    if (line == null || line < 1) return;
    _controller.highlightLine(line, context.getColor(ThemeEnum.textPrimary));
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = buildEditorCodeTheme(context);
    _controller.theme = theme;
    final lineHeight = editorCodeLineHeight(theme);
    final lineCount = _controller.document.lineCount;
    // Matches CodeEditor's own internal padding exactly (+5 top, +5 bottom —
    // see `code_editor.dart:167-169`) so the inner scroll view never engages.
    final height = lineCount * lineHeight + theme.editorPadding.vertical + 10;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CodeEditor(controller: _controller, readOnly: widget.running),
    );
  }
}
