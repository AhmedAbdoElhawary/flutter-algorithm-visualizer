import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/ltr_content.dart';
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
    this.language = EditorLanguage.dart,
  });

  final String fileName;
  final String initialCode;
  final int? highlightedLine;
  final bool running;
  final void Function(CodeController controller) onControllerAttached;

  /// The language the editor is showing, which decides the syntax colouring.
  /// Choosing it belongs to the title row's drop-down, not to this card.
  final EditorLanguage language;

  @override
  Widget build(BuildContext context) {
    /// The whole card is pinned left-to-right, header included.
    ///
    /// Mirroring it in Arabic would put the line-number gutter on the right
    /// of the code, run the caret and selection backwards, and move the
    /// window dots away from the corner every editor puts them in. Source is
    /// read left to right in every language, so this card does not mirror.
    return LtrContent(
      child: CardContainer(
        fillColor: ThemeEnum.surface,
        borderColorOverride: ThemeEnum.hairline,
        radius: CdRadius.md,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CodeCardHeader(fileName: fileName),
            _CodeArea(
              initialCode: initialCode,
              language: language,
              highlightedLine: highlightedLine,
              running: running,
              onControllerAttached: onControllerAttached,
            ),
          ],
        ),
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
        border: Border(bottom: BorderSide(color: context.getColor(ThemeEnum.hairline))),
      ),
      child: Row(
        children: [
          const _Dot(ThemeEnum.dataHard),
          const RSizedBox(width: 5),
          const _Dot(ThemeEnum.dataMedium),
          const RSizedBox(width: 5),
          const _Dot(ThemeEnum.dataEasy),
          const Spacer(),
          RegularText(
            fileName,
            fontFamily: FontConstants.fontFamily,
            fontSize: 10,
            color: ThemeEnum.inkThirdTitle,
            maxLines: 1,
            translate: false,
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
    required this.language,
    required this.highlightedLine,
    required this.running,
    required this.onControllerAttached,
  });

  final String initialCode;
  final EditorLanguage language;
  final int? highlightedLine;
  final bool running;
  final void Function(CodeController controller) onControllerAttached;

  @override
  State<_CodeArea> createState() => _CodeAreaState();
}

/// The tokenizer for each language. Python indents by four, which is not a
/// preference but the width its own tooling assumes.
Tokenizer _tokenizerFor(EditorLanguage language) => switch (language) {
      EditorLanguage.dart => const DartTokenizer(),
      EditorLanguage.python => const PythonTokenizer(),
      EditorLanguage.javascript => const JavascriptTokenizer(),
    };

int _tabSizeFor(EditorLanguage language) => language == EditorLanguage.python ? 4 : 2;

class _CodeAreaState extends State<_CodeArea> {
  late final CodeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CodeController(
      text: widget.initialCode,
      // No theme here on purpose: `build` assigns `buildEditorCodeTheme` on
      // every frame, before the first paint. Passing the package's hard-coded
      // `CodeEditorTheme.dark()` only suggested the editor is dark-only, which
      // it is not.
      tokenizer: _tokenizerFor(widget.language),
      runner: const DartInterpreterRunner(),
      config: CodeEditorConfig(tabSize: _tabSizeFor(widget.language), showLineNumbers: true),
    )..addListener(_onTextChanged);
    widget.onControllerAttached(_controller);
    _applyHighlight();
  }

  @override
  void didUpdateWidget(covariant _CodeArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      // The controller's text is swapped by the editor controller, which owns
      // the per-language drafts; only the colouring is this widget's to do.
      _controller.setTokenizer(_tokenizerFor(widget.language));
      _controller.config = CodeEditorConfig(tabSize: _tabSizeFor(widget.language), showLineNumbers: true);
    }
    if (oldWidget.highlightedLine != widget.highlightedLine) _applyHighlight();
  }

  void _onTextChanged() => setState(() {});

  void _applyHighlight() {
    _controller.clearHighlights();
    final line = widget.highlightedLine;
    if (line == null || line < 1) return;
    _controller.highlightLine(line, context.getColor(ThemeEnum.inkTitle));
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
