import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A row of keys pinned right above the software keyboard while the code
/// editor has focus.
///
/// Mobile keyboards bury `{ } [ ] < > _` behind a symbols page, and have no
/// arrow keys at all — every one of those is used constantly while writing
/// code. This bar puts them one tap away, and every tap goes through
/// [CodeController.value] exactly the way typing does, so auto-closing
/// brackets/quotes and type-over still work for a key tapped here.
///
/// Deliberately [GestureDetector], not a Material button: a focusable button
/// grabs focus on tap by default, which would close the very keyboard this
/// bar sits on top of. [GestureDetector] never touches focus, so the editor
/// stays focused and the keyboard stays open across taps.
class EditorKeyboardToolbar extends StatelessWidget {
  const EditorKeyboardToolbar({super.key, required this.controller, required this.language});

  final CodeController controller;
  final EditorLanguage language;

  /// Dart and JS share a bracket-and-statement vocabulary; Python trades
  /// `;`/`{`/`}` (it uses neither) for `:` up front and a `#` for comments.
  static const List<String> _bracketSymbols = <String>['{', '}', '(', ')', '[', ']'];
  static const List<String> _sharedSymbols = <String>['"', "'", '_', '=', '<', '>', ',', '.'];

  List<String> get _symbols => switch (language) {
        EditorLanguage.python => <String>[':', '(', ')', '[', ']', ..._sharedSymbols, '#'],
        EditorLanguage.dart || EditorLanguage.javascript => <String>[
            ..._bracketSymbols,
            ';',
            ':',
            ..._sharedSymbols,
          ],
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.raised),
        border: Border(top: BorderSide(color: context.getColor(ThemeEnum.hairline))),
      ),
      // A scrolling Sliver list only builds children inside its viewport
      // plus cache extent, so the tail keys would not exist at all — not
      // just be unpainted — until scrolled into view, including for a
      // screen reader swiping through them. This row is short and each key
      // is tiny, so a plain unvirtualized Row costs nothing to build in
      // full and sidesteps that entirely.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: REdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            _LabelKey(label: 'Tab', onTap: () => _insertTab(controller)),
            RSizedBox(width: 10.w),
            _ArrowKey(icon: Icons.keyboard_arrow_left_rounded, onTap: () => _move(controller, _Arrow.left)),
            _ArrowKey(icon: Icons.keyboard_arrow_up_rounded, onTap: () => _move(controller, _Arrow.up)),
            _ArrowKey(icon: Icons.keyboard_arrow_down_rounded, onTap: () => _move(controller, _Arrow.down)),
            _ArrowKey(icon: Icons.keyboard_arrow_right_rounded, onTap: () => _move(controller, _Arrow.right)),
            RSizedBox(width: 10.w),
            for (final symbol in _symbols) _LabelKey(label: symbol, onTap: () => _insert(controller, symbol)),
          ],
        ),
      ),
    );
  }
}

/// Replaces the current selection (a caret is just a zero-length selection)
/// with [text] and moves the caret to sit right after it — the same shape of
/// edit [CodeController] sees from real typing, so [CodeController.value]'s
/// bracket/quote auto-pairing and type-over detection apply here too.
void _insert(CodeController controller, String text) {
  final TextSelection selection = controller.selection;
  final String oldText = controller.text;
  final int start = selection.start < 0 ? oldText.length : selection.start;
  final int end = selection.end < 0 ? oldText.length : selection.end;
  final String newText = oldText.replaceRange(start, end, text);
  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: start + text.length),
  );
}

/// Spaces or a literal tab, whichever [CodeEditorConfig.indentUnit] resolves
/// to for the controller's current config — never hard-coded, so it always
/// matches what auto-indent already inserts after a newline.
void _insertTab(CodeController controller) => _insert(controller, controller.config.indentUnit);

enum _Arrow { left, right, up, down }

/// Moves the caret by one character ([_Arrow.left]/[_Arrow.right]) or one
/// line ([_Arrow.up]/[_Arrow.down]), clamping at the document's edges
/// instead of wrapping. Up/down keep the same column when the destination
/// line is at least that long, and clamp to its end when it's shorter.
///
/// There is no "sticky column" memory across a run of moves — each step
/// reads the *current* column, so after clamping onto a short line, the
/// next move works from that clamped column rather than the column you
/// started the run at. A fancier editor remembers the original column
/// until you type or move sideways; not worth the extra state here.
void _move(CodeController controller, _Arrow arrow) {
  final String text = controller.text;
  final TextSelection selection = controller.selection;
  final int offset = selection.isValid ? selection.baseOffset : text.length;

  final int newOffset;
  switch (arrow) {
    case _Arrow.left:
      newOffset = (offset - 1).clamp(0, text.length);
    case _Arrow.right:
      newOffset = (offset + 1).clamp(0, text.length);
    case _Arrow.up:
    case _Arrow.down:
      final CodeDocument doc = CodeDocument(text);
      final ({int line, int column}) pos = doc.lineColumnAt(offset);
      final int targetLine = arrow == _Arrow.up ? pos.line - 1 : pos.line + 1;
      if (targetLine < 0 || targetLine >= doc.lineCount) return;
      final int targetColumn = pos.column.clamp(0, doc.lineAt(targetLine).length);
      newOffset = doc.offsetAt(targetLine, targetColumn);
  }

  controller.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: newOffset));
}

/// A single symbol/word key — `(`, `;`, `Tab`.
class _LabelKey extends StatelessWidget {
  const _LabelKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: REdgeInsetsDirectional.only(end: 6),
          padding: REdgeInsets.symmetric(horizontal: 12, vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.getColor(ThemeEnum.surface),
            borderRadius: BorderRadius.circular(CdRadius.xs.r),
            border: Border.all(color: context.getColor(ThemeEnum.hairline)),
          ),
          child: RegularText(
            label,
            color: ThemeEnum.inkTitle,
            fontFamily: FontConstants.fontFamily,
            fontSize: 13,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

/// A cursor-movement key, visually distinct (icon, not text) from the
/// symbol keys it sits beside.
class _ArrowKey extends StatelessWidget {
  const _ArrowKey({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Move cursor',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: REdgeInsetsDirectional.only(end: 4),
          padding: REdgeInsets.symmetric(horizontal: 6, vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.getColor(ThemeEnum.surface),
            borderRadius: BorderRadius.circular(CdRadius.xs.r),
            border: Border.all(color: context.getColor(ThemeEnum.hairline)),
          ),
          child: CustomIcon(icon, size: 18, color: ThemeEnum.inkTitle),
        ),
      ),
    );
  }
}
