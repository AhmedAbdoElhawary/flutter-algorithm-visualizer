import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusBox extends StatelessWidget {
  const StatusBox({super.key, required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.r,
      height: 28.r,
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.accentBg),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
          child: Icon(
        isCorrect ? Icons.check_rounded : Icons.close_rounded,
        size: 14.r,
        color: context.getColor(isCorrect ? ThemeEnum.accentGreen : ThemeEnum.accentRed),
      )),
    );
  }
}
