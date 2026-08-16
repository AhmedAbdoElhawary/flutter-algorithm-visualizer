import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CodeEditorBlock extends StatefulWidget {
  const CodeEditorBlock({
    required this.code,
    this.highlightLineNumber = -1,
    this.executing = false,
    this.controllerCallback,
    super.key,
  });
  final String code;
  final int highlightLineNumber;
  final bool executing;
  final void Function(CodeController controller)? controllerCallback;
  @override
  State<CodeEditorBlock> createState() => _CodeEditorBlockState();
}

class _CodeEditorBlockState extends State<CodeEditorBlock> with SingleTickerProviderStateMixin {
  final border = Border.all(color: const Color.fromRGBO(36, 40, 46, 1), width: 1.r);
  late final CodeController controller;

  @override
  void initState() {
    super.initState();
    controller = CodeController(
      text: widget.code,
      tokenizer: const DartTokenizer(),
      runner: const DartInterpreterRunner(),
      config: const CodeEditorConfig(
        tabSize: 2,
        showLineNumbers: true,
      ),
      theme: CodeEditorTheme(
        background: ColorManager.codeEditorBackground,
        caretColor: ColorManager.whiteD6,
        border: border,
        editorPadding: REdgeInsets.symmetric(vertical: 0, horizontal: 15),
        gutterPadding: REdgeInsets.symmetric(vertical: 0, horizontal: 15),
        lineNumberStyle: TextStyle(
          color: ColorManager.codeEditorNumberColor,
          fontSize: 12.sp,
          height: 1.5,
          fontFamily: FontConstants.fontJetBrainsMono,
        ),
        selectionColor: Color.fromRGBO(54, 83, 116, 1),
        textStyle: TextStyle(
          color: Color(0xFFD4D4D4),
          fontFamily: FontConstants.fontJetBrainsMono,
          fontSize: 14.sp,
          height: 1.5,
        ),
        tokenColors: const <TokenType, Color>{
          TokenType.keyword: Color(0xFFC792EA),
          TokenType.string: Color(0xFF98C379),
          TokenType.number: Color(0xFFF78C6C),
          TokenType.comment: Color(0xFF5C6A8A),
          TokenType.identifier: Color(0xFFD6DEEB),
          TokenType.operator: Color(0xFF89DDFF),
          TokenType.punctuation: Color(0xFFD6DEEB),
          TokenType.builtin: Color(0xFF82AAFF),
          TokenType.plain: Color(0xFFD6DEEB),
        },
      ),
    );

    _highlightLine();


  }


  @override
  void didUpdateWidget(covariant CodeEditorBlock oldWidget) {
    if (oldWidget.highlightLineNumber != widget.highlightLineNumber) _highlightLine();
    if (oldWidget.code != widget.code) {
      final resultCallback = widget.controllerCallback;
      if (resultCallback != null) {
        controller.text = widget.code;
        resultCallback(controller);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void _highlightLine() {
    if (widget.highlightLineNumber < 1) return;
    controller.clearHighlights();

    controller.highlightLine(widget.highlightLineNumber, ColorManager.accentDk);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: REdgeInsetsDirectional.only(start: 12, end: 12),
            decoration: BoxDecoration(
              color: Color.fromRGBO(22, 27, 34, 1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(top: border.top, left: border.left, right: border.right),
            ),
            child: Row(
              children: [
                Padding(
                  padding: REdgeInsetsDirectional.only(top: 12, bottom: 12),
                  child: CircleAvatar(radius: 5.r, backgroundColor: Color.fromRGBO(181, 88, 89, 1)),
                ),
                RSizedBox(width: 5),
                CircleAvatar(radius: 5.r, backgroundColor: Color.fromRGBO(182, 142, 43, 1)),
                RSizedBox(width: 5),
                CircleAvatar(radius: 5.r, backgroundColor: Color.fromRGBO(46, 156, 117, 1)),
                Spacer(),
                if (widget.executing) MediumText(StringsManager.executing, color: ThemeEnum.accentGreen, fontSize: 10)
              ],
            ),
          ),
          Flexible(child: CodeEditor(controller: controller)),
        ],
      ),
    );
  }
}
