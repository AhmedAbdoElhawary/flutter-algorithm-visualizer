import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.canPop()) return const SizedBox.shrink();

    return OnlyPadding(
      endPadding: 14,
      child: IconButtonQuiet(
        icon: Icons.arrow_back_ios_new_rounded,
        size: 32,
        iconSize: 16,
        onTap: context.back,
      ),
    );
  }
}
