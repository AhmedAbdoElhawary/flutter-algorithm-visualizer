import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [Theme] sometimes switch came from material 2 randomly,
/// so this to make sure for it (not enough if you right useMaterial3 in app theme)

class CustomSwitch extends ConsumerWidget {
  const CustomSwitch({required this.value, required this.onChanged, super.key});
  final bool value;

  final void Function(bool value) onChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = ref.watch(appSettingsProvider).themeMode == ThemeMode.light;
    return Theme(
      data: isLight ? AppTheme.light : AppTheme.dark,
      child: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: context.getColor(ThemeEnum.focusColor),
        activeColor: context.getColor(ThemeEnum.whiteD1Color),
        inactiveThumbColor: context.getColor(ThemeEnum.whiteColor),
        thumbIcon: WidgetStatePropertyAll(
          Icon(
            Icons.add,
            color: context.getColor(ThemeEnum.transparentColor),
          ),
        ),
        inactiveTrackColor:
            isLight ? ColorManager.whiteD5 : ColorManager.blackL3,
        trackOutlineColor:
            const WidgetStatePropertyAll(ColorManager.transparent),
      ),
    );
  }
}
