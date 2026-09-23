import 'package:algorithm_visualizer/core/helpers/app_info.dart';
import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/helpers/current_device.dart';
import 'package:algorithm_visualizer/core/helpers/link_launcher.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_back_button.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/section_header.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_account_section.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_appearance_section.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_contact_section.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_row.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_session_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          Expanded(
            child: SingleChildScrollView(
              padding: REdgeInsets.fromLTRB(16, 0, 16, kBottomPageSpacing),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: StringsManager.settingsAccountSection),
                  RSizedBox(height: 10),
                  SettingsAccountSection(),
                  RSizedBox(height: 22),
                  SectionHeader(title: StringsManager.settingsAppearanceSection),
                  RSizedBox(height: 10),
                  SettingsAppearanceSection(),
                  // TODO(ahmed): Arabic ships as code but is not reachable, so
                  // this row stays off — a language picker that cannot change
                  // the language is worse than no picker. Turning it back on
                  // means doing all four together: uncomment these lines, the
                  // locale and the delegate in `my_app.dart`, and declare
                  // `assets/problems.ar.json` under `assets:` in pubspec.yaml
                  // (it is loaded at runtime today but never bundled, and the
                  // failure is swallowed, so every problem reads in English).
                  // RSizedBox(height: 22),
                  // SectionHeader(title: StringsManager.language),
                  // RSizedBox(height: 10),
                  // SettingsLanguageSection(),
                  RSizedBox(height: 22),
                  SectionHeader(title: StringsManager.settingsLegalSection),
                  RSizedBox(height: 10),
                  _LegalSection(),
                  RSizedBox(height: 22),
                  SectionHeader(title: StringsManager.settingsContactSection),
                  RSizedBox(height: 10),
                  SettingsContactSection(),
                  RSizedBox(height: 22),
                  SectionHeader(title: StringsManager.settingsAboutSection),
                  RSizedBox(height: 10),
                  _AboutSection(),
                  RSizedBox(height: 22),
                  SettingsSessionCard(),
                  // RSizedBox(height: 18),
                  // _MadeByLine(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      topPadding: context.isAndroid ? kAndroidTopPageSpacing : kIOSTopPageSpacing,
      bottomPadding: 14,
      child: const Row(
        children: [
          CustomBackButton(),
          BoldText(StringsManager.settings, color: ThemeEnum.inkTitle, fontSize: 17),
        ],
      ),
    );
  }
}

/// Both rows open the published page rather than an in-app copy.
///
/// One document, one URL, one version: an in-app transcription would be a
/// second thing to keep in step with the page the Play Console links to, and
/// the two drifting is worse than needing a connection to read them.
class _LegalSection extends StatelessWidget {
  const _LegalSection();

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      surface: CdSurface.main,
      padding: REdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsRow(
            icon: Icons.gavel_rounded,
            title: StringsManager.termsOfService,
            subtitle: StringsManager.termsOfServiceDesc,
            onTap: () => context.openLink(kTermsOfServiceUrl),
          ),
          const SettingsRowDivider(),
          SettingsRow(
            icon: Icons.shield_outlined,
            title: StringsManager.privacyPolicy,
            subtitle: StringsManager.privacyPolicyDesc,
            onTap: () => context.openLink(kPrivacyPolicyUrl),
          ),
          const SettingsRowDivider(),
          SettingsRow(
            icon: Icons.delete_outline_rounded,
            title: StringsManager.deleteAccountHowItWorks,
            subtitle: StringsManager.deleteAccountHowItWorksDesc,
            onTap: () => context.openLink(kDeleteAccountUrl),
          ),
          const SettingsRowDivider(),
          // The documents' own version, which moves independently of the app's
          // — see [kLegalVersion]. Given its own row rather than crammed into
          // the section header, where a longer date or the Arabic translation
          // would not fit.
          const SettingsRow(
            icon: Icons.history_rounded,
            title: StringsManager.legalVersionPrefix,
            subtitle: '$kLegalVersion · $kLegalUpdated',
            showChevron: false,
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      surface: CdSurface.main,
      padding: REdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsRow(
            icon: Icons.terminal_rounded,
            title: StringsManager.sourceCode,
            subtitle: StringsManager.sourceCodeDesc,
            onTap: () => context.openLink(kSourceCodeUrl, target: LinkTarget.external),
          ),
          const SettingsRowDivider(),
          SettingsRow(
            icon: Icons.info_outline_rounded,
            title: StringsManager.appVersionLabel,
            subtitle: AppInfo.version,
            showChevron: false,
          ),
        ],
      ),
    );
  }
}

// class _MadeByLine extends StatelessWidget {
//   const _MadeByLine();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: RegularText(
//         StringsManager.madeBy,
//         color: ThemeEnum.inkMuted,
//         fontSize: 11,
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }
