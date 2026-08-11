import 'dart:ui';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/how_it_works.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CodeEditorBlock extends StatefulWidget {
  const CodeEditorBlock(this.code, {super.key});
  final String code;
  @override
  State<CodeEditorBlock> createState() => _CodeEditorBlockState();
}

class _CodeEditorBlockState extends State<CodeEditorBlock> with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  late final CodeController controller;
  final border = Border.all(color: const Color.fromRGBO(36, 40, 46, 1), width: 1.r);

  OverlayEntry? _overlay;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  void _togglePopup() {
    if (_overlay != null) {
      _removePopup();
    } else {
      _showPopup();
    }
  }

  void _showPopup() {
    _overlay = OverlayEntry(
      builder: (context) {
        final width = MediaQuery.sizeOf(context).width * 0.89;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removePopup,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) {
                    final value = Curves.easeOut.transform(_controller.value);

                    return BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: value * 12,
                        sigmaY: value * 12,
                      ),
                      child: Container(
                        color: Colors.black.withValues(alpha: value * 0.18),
                      ),
                    );
                  },
                ),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(-width, -120.r),
              child: FadeTransition(
                opacity: _opacity,
                child: SlideTransition(
                  position: _offset,
                  child: ScaleTransition(
                    scale: _scale,
                    alignment: Alignment.topRight,
                    child: const Material(
                      color: Colors.transparent,
                      child: HowItWorks(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
    _controller.forward(from: 0);
  }

  void _removePopup() async {
    if (_overlay == null) return;

    await _controller.reverse();

    _overlay?.remove();
    _overlay = null;
  }

  @override
  void initState() {
    super.initState();

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _scale = Tween(
      begin: 0.15,
      end: 1.0,
    ).animate(curve);

    _opacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(curve);

    _offset = Tween(
      begin: const Offset(0.08, -0.08),
      end: Offset.zero,
    ).animate(curve);

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
          fontFamily: 'JetBrainsMono',
        ),
        selectionColor: Color.fromRGBO(54, 83, 116, 1),
        textStyle: TextStyle(
          color: Color(0xFFD4D4D4),
          fontFamily: 'JetBrainsMono',
          fontSize: 14.sp,
          height: 1.5,
        ),
        tokenColors: const <TokenType, Color>{
          // function, if, else, while, let, const, return...
          TokenType.keyword: Color(0xFFC792EA),

          // "hello"
          TokenType.string: Color(0xFF98C379),

          // 0, 1, 23...
          TokenType.number: Color(0xFFF78C6C),

          // // comments
          TokenType.comment: Color(0xFF5C6A8A),

          // variable names
          TokenType.identifier: Color(0xFFD6DEEB),

          // =, +, -, <=, === ...
          TokenType.operator: Color(0xFF89DDFF),

          // { } ( ) [ ] ; , .
          TokenType.punctuation: Color(0xFFD6DEEB),

          // Built-in objects/functions
          // Math, console, Array, String...
          TokenType.builtin: Color(0xFF82AAFF),

          // Plain text
          TokenType.plain: Color(0xFFD6DEEB),
        },
      ),
    );

    // final result = controller.execute();
    // if (result.success) {
    //   print(result.stdout.join('\n')); // everything the code printed
    // } else {
    //   print('Line ${result.error!.line}: ${result.error!.message}');
    // }
  }

  @override
  void dispose() {
    controller.dispose();
    _removePopup();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        // color: ColorManager.codeEditorBackground
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: REdgeInsetsDirectional.all(12),
            decoration: BoxDecoration(
              color: Color.fromRGBO(22, 27, 34, 1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(top: border.top, left: border.left, right: border.right),
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 5.r, backgroundColor: Color.fromRGBO(181, 88, 89, 1)),
                RSizedBox(width: 5),
                CircleAvatar(radius: 5.r, backgroundColor: Color.fromRGBO(182, 142, 43, 1)),
                RSizedBox(width: 5),
                CircleAvatar(radius: 5.r, backgroundColor: Color.fromRGBO(46, 156, 117, 1)),
                Spacer(),
                CompositedTransformTarget(
                  link: _layerLink,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _togglePopup,
                    child: Icon(
                      Icons.lightbulb,
                      size: 16.r,
                      color: const Color.fromRGBO(213, 209, 17, 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(child: CodeEditor(controller: controller)),
        ],
      ),
    );
  }
}
