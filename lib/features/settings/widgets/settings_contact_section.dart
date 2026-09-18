import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/helpers/link_launcher.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Ways to reach a human.
///
/// The mail row is not a nicety: an address the user can find is what turns a
/// one-star review into a message that can actually be answered, and the store
/// listing has to name a support contact regardless.
///
/// Profiles open with [LinkTarget.external] so an installed GitHub or LinkedIn
/// app takes them — already signed in — rather than a browser tab asking the
/// user to log in again.
class SettingsContactSection extends StatelessWidget {
  const SettingsContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      surface: CdSurface.main,
      padding: REdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsRow(
            icon: Icons.mail_outline_rounded,
            title: StringsManager.contactEmail,
            subtitle: kSupportEmail,
            onTap: () => context.sendEmail(kSupportEmail, subject: kSupportEmailSubject),
          ),
          const SettingsRowDivider(),
          SettingsRow(
            icon: Icons.code_rounded,
            title: StringsManager.contactGithub,
            subtitle: StringsManager.contactGithubDesc,
            onTap: () => context.openLink(kGithubProfileUrl, target: LinkTarget.external),
          ),
          const SettingsRowDivider(),
          SettingsRow(
            icon: Icons.person_outline_rounded,
            title: StringsManager.contactLinkedIn,
            subtitle: StringsManager.contactLinkedInDesc,
            onTap: () => context.openLink(kLinkedInUrl, target: LinkTarget.external),
          ),
        ],
      ),
    );
  }
}
