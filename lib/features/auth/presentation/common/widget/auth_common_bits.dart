import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AuthTitle extends StatelessWidget {
  const AuthTitle(this.text, {super.key, this.large = false});

  final String text;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return BoldText(
      text,
      color: ThemeEnum.inkTitle,
      fontSize: large ? 26 : 24,
      letterSpacing: large ? -0.52 : -0.48,
      maxLines: 2,
      fontWeight: FontWeight.w900,
    );
  }
}

class AuthSubtitle extends StatelessWidget {
  const AuthSubtitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RegularText(text, color: ThemeEnum.inkSecondaryTitle, fontSize: 13, maxLines: 3, height: 1.65);
  }
}

class AuthCombineSubtitle extends StatelessWidget {
  const AuthCombineSubtitle({
    required this.text,
    required this.highlightedText,
    required this.secondText,
    this.fontSize = 13,
    super.key,
  });

  final String text;
  final String highlightedText;
  final String secondText;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      maxLines: 5,
      TextSpan(
        text: text,
        style: GetRegularStyle(
            color: context.getColor(ThemeEnum.inkSecondaryTitle), fontSize: fontSize, height: 1.65),
        children: [
          const TextSpan(text: " "),
          TextSpan(
            text: highlightedText,
            style: GetMediumStyle(color: context.getColor(ThemeEnum.inkTitle), fontSize: fontSize + 1),
          ),
          const TextSpan(text: " ."),
          TextSpan(text: secondText),
        ],
      ),
    );
  }
}

class AuthEyebrowRow extends StatelessWidget {
  const AuthEyebrowRow(this.label, {super.key, this.onBack});

  final String label;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CustomBackButton(),
        SemiBoldText(label,
            color: ThemeEnum.inkSecondaryTitle, fontSize: 12, letterSpacing: 1.2, maxLines: 1),
      ],
    );
  }
}

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
          RegularText(prompt, color: ThemeEnum.inkSecondaryTitle, fontSize: 12, maxLines: 1),
          SizedBox(width: 4.w),
          SemiBoldText(action, color: ThemeEnum.inkTitle, fontSize: 12, maxLines: 1),
        ],
      ),
    );
  }
}

class AuthReturnLink extends StatelessWidget {
  const AuthReturnLink(this.text, {this.size = 12, this.color = ThemeEnum.inkSecondaryTitle, super.key});

  final String text;
  final double size;
  final ThemeEnum color;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.canPop() ? context.back() : context.pushTo(Routes.login),
      child: Center(
        child: MediumText(text, color: color, fontSize: size, maxLines: 1),
      ),
    );
  }
}
