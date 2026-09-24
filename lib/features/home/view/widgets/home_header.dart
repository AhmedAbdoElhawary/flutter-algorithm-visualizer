import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // in case i will add others to not rebuild it just to take the name
    final name = ref.watch(currentUserNameProvider.select((value) => value));
    final greeting = ref.watch(homeDataProvider.select((value) => value.greeting));

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      topPadding: 16,
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
                  color: ThemeEnum.inkSecondaryTitle,
                ),
                SizedBox(height: 2.h),
                BoldText(
                  '$name 👋',
                  fontSize: 22,
                  color: ThemeEnum.inkTitle,
                  letterSpacing: -0.5,
                ),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final isSignedIn = ref.watch(isSignedInProvider);
              if (isSignedIn) return const SizedBox.shrink();
              return GestureDetector(
                // `go`, not `push`: leaving for the sign-in screen must clear the whole
                // navigation stack, including every shell branch's saved page. A
                // pushed login would sit on top of a live shell, and the next
                // account would inherit the previous one's open tabs.
                onTap: () => context.pushAndRemoveAll(Routes.login),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BoldText(StringsManager.signIn, fontSize: 14),
                    RSizedBox(width: 5),
                    IconButtonQuiet(
                      icon: Icons.login_rounded,
                      size: 36,
                      iconSize: 18,
                      iconColor: ThemeEnum.inkPrimary,
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
