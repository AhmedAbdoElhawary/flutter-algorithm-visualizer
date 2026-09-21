import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/helpers/current_device.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/avatar_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_sync_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      topPadding: context.isAndroid ? kAndroidTopPageSpacing * 1.5 : kIOSTopPageSpacing,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(),
              RSizedBox(width: 14),
              Expanded(child: _Name()),
              RSizedBox(width: 6),
              ProfileSyncButton(),
              _SettingsButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends ConsumerWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(currentUserNameProvider.select((value) => value));

    return AvatarQuiet(initial: name.isNotEmpty ? name[0].toUpperCase() : StringsManager.anonymous);
  }
}

class _Name extends ConsumerWidget {
  const _Name();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(currentUserNameProvider.select((value) => value));

    return BoldText(
      name,
      maxLines: 1,
      color: ThemeEnum.inkTitle,
      fontSize: 22,
      fontWeight: FontWeightManager.bold800,
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushTo(Routes.settings),
      child: const IconButtonQuiet(
        icon: Icons.settings_outlined,
        iconColor: ThemeEnum.inkSecondaryTitle,
        borderColor: ThemeEnum.inkSecondaryTitle,
        size: 36,
        iconSize: 18,
      ),
    );
  }
}
