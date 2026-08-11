import 'package:algorithm_visualizer/core/widgets/custom_widgets/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LiveCodeSnippet extends ConsumerWidget {
  const LiveCodeSnippet({required this.currentLine, required this.code, super.key});

  final String code;
  final int currentLine;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: REdgeInsets.symmetric(horizontal: 16),
      child: CodeEditorBlock(code),
    );
  }
}
