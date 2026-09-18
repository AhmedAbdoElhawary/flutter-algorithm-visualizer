import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Theme choice, as three rows rather than a segmented control.
///
/// [SegmentedControlQuiet] is the house style for a picker, but three labels
/// plus its padding do not fit beside an icon at 360pt, and the Arabic labels
/// are longer still. Rows with a check mark carry the same information, cost
/// nothing at any width, and are the pattern users already know from their
/// phone's own settings.
class SettingsAppearanceSection extends ConsumerWidget {
  const SettingsAppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appSettingsProvider.select((state) => state.themeMode));

    return CardContainer(
      surface: CdSurface.main,
      padding: REdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeOption(
            icon: Icons.brightness_auto_outlined,
            title: StringsManager.themeSystem,
            subtitle: StringsManager.themeSystemDesc,
            mode: ThemeMode.system,
            selected: selected,
          ),
          const SettingsRowDivider(),
          _ThemeOption(
            icon: Icons.light_mode_outlined,
            title: StringsManager.themeLight,
            subtitle: StringsManager.themeLightDesc,
            mode: ThemeMode.light,
            selected: selected,
          ),
          const SettingsRowDivider(),
          _ThemeOption(
            icon: Icons.dark_mode_outlined,
            title: StringsManager.themeDark,
            subtitle: StringsManager.themeDarkDesc,
            mode: ThemeMode.dark,
            selected: selected,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends ConsumerWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.selected,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeMode mode;
  final ThemeMode selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = mode == selected;

    return SettingsRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      accentColor: isSelected ? ThemeEnum.inkTitle : ThemeEnum.inkBody,
      onTap: () => ref.read(appSettingsProvider.notifier).changeTheme(mode),
      // A check on the chosen row and nothing on the others — the absence is
      // the signal, so an unselected row needs no placeholder.
      trailing: isSelected
          ? const CustomIcon(Icons.check_rounded, size: 18, color: ThemeEnum.dataEasy)
          : const SizedBox.shrink(),
    );
  }
}
