import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/helpers/link_launcher.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';

class LegalConsent extends StatelessWidget {
  const LegalConsent({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnlyPadding(
      topPadding: 12,
      bottomPadding: 16,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 2,
        children: [
          RegularText(
            StringsManager.signUpConsentPrefix,
            color: ThemeEnum.inkThirdTitle,
            fontSize: 11,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          _ConsentLink(label: StringsManager.termsOfService, url: kTermsOfServiceUrl),
          RegularText(
            StringsManager.signUpConsentAnd,
            color: ThemeEnum.inkThirdTitle,
            fontSize: 11,
            maxLines: 1,
          ),
          _ConsentLink(label: StringsManager.privacyPolicy, url: kPrivacyPolicyUrl),
        ],
      ),
    );
  }
}

class _ConsentLink extends StatelessWidget {
  const _ConsentLink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.openLink(url),
      child: MediumText(
        label,
        color: ThemeEnum.inkTitle,
        fontSize: 11,
        maxLines: 1,
        decoration: TextDecoration.underline,
      ),
    );
  }
}
