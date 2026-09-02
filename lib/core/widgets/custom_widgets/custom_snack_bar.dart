import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CustomSnackBarType { error, success, warning, info }

extension CustomSnackBarX on BuildContext {
  void showSnackBar({required String message, required CustomSnackBarType type}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: _AuthErrorBanner(message: message, type: type),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: REdgeInsets.fromLTRB(16, 0, 16, 24),
          duration: const Duration(seconds: 3),
          padding: EdgeInsets.zero,
        ),
      );
  }

  void hideCurrentSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }
}

class _AuthErrorBanner extends StatelessWidget {
  final String message;
  final CustomSnackBarType type;
  const _AuthErrorBanner({required this.message, required this.type});

  ThemeEnum get getColor {
    switch (type) {
      case CustomSnackBarType.error:
        return ThemeEnum.accentRed;
      case CustomSnackBarType.success:
        return ThemeEnum.accentGreen;
      case CustomSnackBarType.warning:
        return ThemeEnum.accentYellow;
      case CustomSnackBarType.info:
        return ThemeEnum.accentBlue;
    }
  }

  IconData get getIcon {
    switch (type) {
      case CustomSnackBarType.error:
        return Icons.error_outline_rounded;
      case CustomSnackBarType.success:
        return Icons.check_circle_outline_rounded;
      case CustomSnackBarType.warning:
        return Icons.warning_amber_rounded;
      case CustomSnackBarType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context..hideCurrentSnackBar(),
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: REdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.getColor(getColor).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: context.getColor(getColor).withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            CustomIcon(getIcon, size: 16, color: getColor),
            RSizedBox(width: 8),
            Expanded(child: RegularText(message, color: getColor, fontSize: 12)),
            CustomIcon(Icons.close_rounded, size: 16, color: getColor),
          ],
        ),
      ),
    );
  }
}
