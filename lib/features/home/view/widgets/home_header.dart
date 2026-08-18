import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({required this.greeting, super.key});

  final String greeting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileNameProvider);

    return OnlyPadding(
      startPadding: 20,
      endPadding: 20,
      topPadding: 18,
      bottomPadding: 14,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediumText(
                  '$greeting,',
                  fontSize: 13,
                  color: ThemeEnum.textSecond,
                ),
                SizedBox(height: 2.h),
                BoldText(
                  '$name 👋',
                  fontSize: 22,
                  color: ThemeEnum.textPrimary,
                  letterSpacing: -0.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
