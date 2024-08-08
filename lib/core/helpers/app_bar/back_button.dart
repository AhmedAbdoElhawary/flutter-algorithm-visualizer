import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/helpers/svg_picture.dart';
import 'package:algorithm_visualizer/core/resources/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final isLangEnglish =
        ref.watch(appSettingsProvider).language == LanguagesEnum.english;

    final String icon;
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        icon =
            isLangEnglish ? IconsAssets.backButton : IconsAssets.backButtonRTL;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        icon = isLangEnglish
            ? IconsAssets.iosBackButton
            : IconsAssets.iosBackButtonRTL;
    }
    return CustomAssetsSvg(icon, size: 30);
  }
}
