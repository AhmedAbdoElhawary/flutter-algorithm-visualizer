import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "─── or ───" divider — CoreDive screen 11.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Rule()),
        const HorizontalGap(),
        const RegularText(StringsManager.orDivider, color: ThemeEnum.textDisabled, fontSize: 10.5, maxLines: 1),
        const HorizontalGap(),
        Expanded(child: _Rule()),
      ],
    );
  }
}

class HorizontalGap extends StatelessWidget {
  const HorizontalGap({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(width: 12.w);
}

class _Rule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1.h, color: context.getColor(ThemeEnum.borderSubtle));
  }
}
