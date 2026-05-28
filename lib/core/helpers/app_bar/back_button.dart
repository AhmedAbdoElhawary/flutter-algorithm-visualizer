import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBarBackButton extends StatelessWidget {
  const CustomAppBarBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const CustomBackButtonIcon(),
      onPressed: () {
        Navigator.maybePop(context);
      },
    );
  }
}

class CustomBackButtonIcon extends ConsumerWidget {
  const CustomBackButtonIcon({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        highlightColor: context.getColor(ThemeEnum.glassColor),
        onTap: () {
          Navigator.maybePop(context);
        },
        child: GlassContainer(
          borderRadius: 8,
          padding: REdgeInsets.all(6),
          child:
          CustomIcon(Icons.arrow_back_ios_new_rounded, size: 20, color: ThemeEnum.focusColor),
        ),
      ),
    );
  }
}
