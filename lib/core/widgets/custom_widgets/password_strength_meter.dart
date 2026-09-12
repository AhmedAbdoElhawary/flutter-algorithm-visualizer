import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Four 3px segments + a caption naming the level and the next improvement —
/// CoreDive screen 13.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final strength = PasswordStrength.evaluate(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) SizedBox(width: 5.w),
              Expanded(
                child: Container(
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: context.getColor(
                      i < strength.filledSegments ? ThemeEnum.difficultyEasy : ThemeEnum.surfaceAlt,
                    ),
                    borderRadius: BorderRadius.circular(CdRadius.pill.r),
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 6.h),
        RegularText(strength.caption, color: ThemeEnum.textSecond, fontSize: 10.5, maxLines: 1),
      ],
    );
  }
}

class PasswordStrength {
  const PasswordStrength._(this.filledSegments, this.caption);

  /// 0–4 lit segments.
  final int filledSegments;

  /// "Fair · add a number to strengthen it"
  final String caption;

  static PasswordStrength evaluate(String password) {
    if (password.isEmpty) {
      return const PasswordStrength._(0, StringsManager.pwStrengthEmpty);
    }

    final hasDigit = password.contains(RegExp(r'\d'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasSymbol = password.contains(RegExp(r'[^A-Za-z0-9]'));
    final mixedCase = hasLower && hasUpper;

    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (hasDigit) score++;
    if (mixedCase) score++;
    if (hasSymbol) score++;

    final filled = score.clamp(1, 4);

    final level = switch (filled) {
      1 => StringsManager.pwStrengthWeak,
      2 => StringsManager.pwStrengthFair,
      3 => StringsManager.pwStrengthGood,
      _ => StringsManager.pwStrengthStrong,
    };

    final String hint;
    if (password.length < 8) {
      hint = StringsManager.pwHintAddLength;
    } else if (!hasDigit) {
      hint = StringsManager.pwHintAddNumber;
    } else if (!mixedCase) {
      hint = StringsManager.pwHintAddCase;
    } else if (!hasSymbol) {
      hint = StringsManager.pwHintAddSymbol;
    } else {
      hint = StringsManager.pwHintStrongEnough;
    }

    return PasswordStrength._(filled, '$level · $hint');
  }
}
