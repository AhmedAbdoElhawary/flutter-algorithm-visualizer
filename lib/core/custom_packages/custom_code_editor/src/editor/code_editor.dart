import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/code_editor_config.dart';
import '../models/code_editor_theme.dart';
import '../widgets/line_numbers.dart';
import 'code_controller.dart';
import 'code_document.dart';

/// A lightweight, mobile-first code editor widget.
///
/// Built directly on top of [EditableText] (the same low-level widget
/// `TextField` and `CupertinoTextField` are built on) rather than on
/// Material's `TextField`, so this package doesn't force a Material (or
/// Cupertino) dependency on you — it fits into either design language, or
/// neither.
///
/// ```dart
/// CodeEditor(
///   controller: controller,
///   theme: CodeEditorTheme.dark(),
/// )
/// ```
///
/// All editing *behavior* (indentation, bracket pairing, highlighting)
/// lives on [CodeController] — this widget is just the visual shell:
/// the editable text area plus an optional line-number gutter, kept in
/// vertical scroll sync.
class CodeEditor extends StatefulWidget {
  const CodeEditor({
    super.key,
    required this.controller,
    this.config,
    this.theme,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.textInputAction = TextInputAction.newline,
  });

  /// The controller driving this editor. Also owns [config]/[theme]
  /// defaults if the corresponding widget properties are left null.
  final CodeController controller;

  /// Overrides [controller.config] for this widget instance. If null,
  /// whatever is already set on [controller] is used.
  final CodeEditorConfig? config;

  /// Overrides [controller.theme] for this widget instance. If null,
  /// whatever is already set on [controller] is used.
  final CodeEditorTheme? theme;

  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final TextInputAction textInputAction;

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  final ScrollController _horizontalScrollController = ScrollController();
  late FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController();
  final double _numbersPadding = 5;
  int _lineCount = 1;
  int? _activeLine;
  int? _errorLine;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _applyOverrides();
    widget.controller.addListener(_onControllerChanged);
    _onControllerChanged();
  }

  @override
  void didUpdateWidget(covariant CodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyOverrides();
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _onControllerChanged();
    }
  }

  void _applyOverrides() {
    if (widget.config != null) widget.controller.config = widget.config!;
    if (widget.theme != null) widget.controller.theme = widget.theme!;
  }

  void _onControllerChanged() {
    final CodeDocument doc = widget.controller.document;
    final TextSelection selection = widget.controller.selection;
    int? activeLine;
    if (selection.baseOffset >= 0) {
      activeLine = doc.lineColumnAt(selection.baseOffset).line;
    }
    // highlightedLines is mutated in place (not reassigned), so it can't
    // be cheaply diffed like the other fields — just always rebuild on
    // any controller notification.
    setState(() {
      _lineCount = doc.lineCount;
      _activeLine = activeLine;
      _errorLine = widget.controller.errorLine;
    });
  }

  List<Widget> _buildLineHighlightBars(CodeEditorTheme theme, double lineHeight) {
    final List<Widget> bars = <Widget>[];
    widget.controller.highlightedLines.forEach(
      (int line, Color color) {
        if (line == _errorLine) return;
        bars.add(Positioned(
          top: line * lineHeight,
          left: 0,
          right: 0,
          height: lineHeight,
          child: Container(
            decoration: BoxDecoration(
                border: BorderDirectional(start: BorderSide(color: color, width: 2)),
                color: color.withValues(alpha: 0.1)),
          ),
        ));
      },
    );
    if (_errorLine != null) {
      bars.add(
        Positioned(
          top: _errorLine! * lineHeight,
          left: 0,
          right: 0,
          height: lineHeight,
          child: ColoredBox(color: theme.errorColor.withValues(alpha: 0.16)),
        ),
      );
    }
    return bars;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    _scrollController.dispose();
    _gutterController?.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CodeEditorTheme theme = widget.controller.theme;
    final CodeEditorConfig config = widget.controller.config;

    final double fontSize = theme.textStyle.fontSize ?? 14;
    final double lineHeightMultiplier = theme.textStyle.height ?? 1.4;
    final double lineHeight = (fontSize * lineHeightMultiplier).r;

    final borderRadius = theme.borderRadius;

    final Widget editableArea = Container(
      padding: REdgeInsetsDirectional.only(
          bottom: theme.editorPadding.bottom + _numbersPadding,
          top: theme.editorPadding.top + 5,
          end: theme.editorPadding.right),
      decoration: BoxDecoration(
        borderRadius: borderRadius == null
            ? null
            : borderRadius.bottomEnd != Radius.zero && borderRadius.topEnd != Radius.zero
                ? BorderRadiusDirectional.only(bottomEnd: borderRadius.bottomEnd, topEnd: borderRadius.topEnd)
                : borderRadius.bottomEnd != Radius.zero
                    ? BorderRadiusDirectional.only(bottomEnd: borderRadius.bottomEnd)
                    : borderRadius.topEnd != Radius.zero
                        ? BorderRadiusDirectional.only(topEnd: borderRadius.topEnd)
                        : null,
        color: theme.background,
      ),
      child: Stack(
        children: [
          ..._buildLineHighlightBars(theme, lineHeight),
          Container(
            padding: REdgeInsetsDirectional.only(start: theme.editorPadding.left),
            child: EditableText(
              controller: widget.controller,
              focusNode: _focusNode,
              style: theme.textStyle,
              cursorColor: theme.caretColor,
              backgroundCursorColor: theme.background,
              selectionColor: theme.selectionColor,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              maxLines: null,
              minLines: null,
              expands: false,
              keyboardType: TextInputType.multiline,
              textInputAction: widget.textInputAction,
              autocorrect: false,
              enableSuggestions: false,
              cursorWidth: theme.caretWidth,
              cursorHeight: theme.caretHeight,
              cursorOffset: Offset(0, 2),
              cursorRadius: const Radius.circular(1),
            ),
          ),
        ],
      ),
    );

    if (!config.showLineNumbers) return editableArea;

    return Container(
      decoration: BoxDecoration(
        border: theme.border,
        borderRadius: borderRadius,
        color: theme.background,
      ),
      child: Row(
        children: <Widget>[
          LineNumbers(
            numbersPadding: _numbersPadding,
            borderRadius: borderRadius == null
                ? null
                : borderRadius.bottomStart != Radius.zero && borderRadius.topStart != Radius.zero
                    ? BorderRadiusDirectional.only(
                        bottomStart: borderRadius.bottomStart, topStart: borderRadius.topStart)
                    : borderRadius.bottomStart != Radius.zero
                        ? BorderRadiusDirectional.only(bottomStart: borderRadius.bottomStart)
                        : borderRadius.topStart != Radius.zero
                            ? BorderRadiusDirectional.only(topStart: borderRadius.topStart)
                            : null,
            lineCount: _lineCount,
            theme: theme,
            scrollController: _mirrorScrollController(),
            lineHeight: lineHeight,
            activeLine: _activeLine,
            errorLine: _errorLine,
            highlightedLines: widget.controller.highlightedLines,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalScrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: IntrinsicWidth(
                  child: editableArea,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The line-number gutter and the text field scroll independently in
  /// Flutter (there's no built-in "linked scroll views" primitive), so we
  /// give the gutter its own controller and nudge it to follow the text
  /// field's offset whenever the latter changes.
  ScrollController? _gutterController;
  ScrollController _mirrorScrollController() {
    final ScrollController controller = _gutterController ??= ScrollController();
    if (!_listenerAttached) {
      _listenerAttached = true;
      _scrollController.addListener(() {
        if (!controller.hasClients) return;
        final double offset = _scrollController.offset.clamp(
          0.0,
          controller.position.maxScrollExtent,
        );
        controller.jumpTo(offset);
      });
    }
    return controller;
  }

  bool _listenerAttached = false;
}
