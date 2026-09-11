import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/aurora_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Screen title — 700, tight tracking. [large] is screen 11's 26px; the rest
/// use 24px.
class AuthTitle extends StatelessWidget {
  const AuthTitle(this.text, {super.key, this.large = false});

  final String text;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return BoldText(
      text,
      color: ThemeEnum.textPrimary,
      fontSize: large ? 26 : 24,
      letterSpacing: large ? -0.52 : -0.48,
      maxLines: 2,
    );
  }
}

class AuthSubtitle extends StatelessWidget {
  const AuthSubtitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RegularText(text, color: ThemeEnum.textSecond, fontSize: 12.5, maxLines: 3, height: 1.65);
  }
}

/// "ACCOUNT RECOVERY" eyebrow with a leading back square — CoreDive screen 12.
class AuthEyebrowRow extends StatelessWidget {
  const AuthEyebrowRow(this.label, {super.key, this.onBack});

  final String label;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomBackButton(onTap: onBack),
        SizedBox(width: 12.w),
        SemiBoldText(label, color: ThemeEnum.textSecond, fontSize: 12, letterSpacing: 1.2, maxLines: 1),
      ],
    );
  }
}

/// Centred "prompt + action" footer, e.g. "No account yet? Sign up".
class AuthFooterPrompt extends StatelessWidget {
  const AuthFooterPrompt({super.key, required this.prompt, required this.action, required this.onTap});

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RegularText(prompt, color: ThemeEnum.textSecond, fontSize: 12, maxLines: 1),
          SizedBox(width: 4.w),
          SemiBoldText(action, color: ThemeEnum.primaryHover, fontSize: 12, maxLines: 1),
        ],
      ),
    );
  }
}

/// Plain centred "Return to sign in" link — CoreDive screen 12.
class AuthReturnLink extends StatelessWidget {
  const AuthReturnLink(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.canPop() ? context.pop() : context.go(Routes.login.path),
      child: Center(
        child: MediumText(text, color: ThemeEnum.textSecond, fontSize: 12, maxLines: 1),
      ),
    );
  }
}
