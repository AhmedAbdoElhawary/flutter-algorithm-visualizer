import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/extensions/language.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Language choice, as one row per language with a check mark — the same shape
/// as [SettingsAppearanceSection], for the same reason: a segmented control
/// does not survive a long label at 360pt.
///
/// Both rows are labelled in their own language and marked `translate: false`,
/// so this list reads identically whichever language is active. A user who
/// switched to a script they cannot read can still find their way back.
class SettingsLanguageSection extends ConsumerWidget {
  const SettingsLanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appSettingsProvider.select((state) => state.language));

    return CardContainer(
      surface: CdSurface.main,
      padding: REdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, language) in LanguagesEnum.values.indexed) ...[
            if (index > 0) const SettingsRowDivider(),
            _LanguageOption(language: language, selected: selected),
          ],
        ],
      ),
    );
  }
}

class _LanguageOption extends ConsumerWidget {
  const _LanguageOption({required this.language, required this.selected});

  final LanguagesEnum language;
  final LanguagesEnum selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = language == selected;

    return SettingsRow(
      icon: Icons.translate_rounded,
      title: language.nativeName,
      subtitle: language.endonymHint,
      translateLabels: false,
      accentColor: isSelected ? ThemeEnum.inkTitle : ThemeEnum.inkBody,

      /// Nothing here reloads, rebuilds a route or restarts the app. Writing
      /// the preference moves `AppSettingsState.language`, `MyApp` rebuilds
      /// `MaterialApp` with the new `locale`, and the delegate resolves
      /// synchronously — so the switch lands on the very next frame with the
      /// user still on this screen, scrolled to the same place.
      onTap: () => ref.read(appSettingsProvider.notifier).changeLanguage(language),
      trailing: isSelected
          ? const CustomIcon(Icons.check_rounded, size: 18, color: ThemeEnum.dataEasy)
          : const SizedBox.shrink(),
    );
  }
}
