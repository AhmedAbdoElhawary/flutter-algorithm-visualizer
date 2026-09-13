import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomCtaBar extends StatelessWidget {
  final Widget child;

  const BottomCtaBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Container(
          height: 60.r,
          margin: REdgeInsets.fromLTRB(16, 0, 16, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(CdRadius.md.r)),
            color: context.getColor(ThemeEnum.primary),
          ),
        ),
        Padding(padding: REdgeInsets.fromLTRB(16, 12, 16, 12), child: child)
      ],
    );
  }
}
