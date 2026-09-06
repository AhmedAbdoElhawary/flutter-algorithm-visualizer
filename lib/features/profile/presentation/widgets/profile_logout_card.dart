import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/animated_popup.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_rounded_elevated_button.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/rounded_outlined_button.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfileLogoutCard extends StatelessWidget {
  const ProfileLogoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HorizontalPadding(
      padding: 16,
      child: AnimatedPopup(
        builder: (removeOverlay) => Consumer(
          builder: (context, ref, child) => _LogoutConfirmationDialog(
            onConfirm: () async {
              removeOverlay();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(Routes.login.path);
            },
            onCancel: removeOverlay,
          ),
        ),
        child: Container(
          padding: REdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.getColor(ThemeEnum.card),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: context.getColor(ThemeEnum.accentRed).withValues(alpha: 0.25),
            ),
            boxShadow: context.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: context.getColor(ThemeEnum.accentRed).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: context.getColor(ThemeEnum.accentRed).withValues(alpha: 0.25),
                  ),
                ),
                child: Center(
                  child: CustomIcon(
                    Icons.logout_rounded,
                    size: 18,
                    color: ThemeEnum.accentRed,
                  ),
                ),
              ),
              RSizedBox(width: 12),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final user = ref.watch(currentUserProvider);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BoldText(
                          StringsManager.logout,
                          color: ThemeEnum.accentRed,
                          fontSize: 13,
                          fontWeight: FontWeightManager.bold800,
                        ),
                        if (user?.email != null && user!.email.isNotEmpty) ...[
                          RSizedBox(height: 2),
                          RegularText(
                            user.email,
                            color: ThemeEnum.textSecond,
                            fontSize: 11,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              CustomIcon(
                Icons.chevron_right_rounded,
                size: 18,
                color: ThemeEnum.hover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _LogoutConfirmationDialog({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320.w,
      padding: REdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.card),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.getColor(ThemeEnum.border)),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: context.getColor(ThemeEnum.accentRed).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIcon(
                Icons.logout_rounded,
                size: 24,
                color: ThemeEnum.accentRed,
              ),
            ),
          ),
          RSizedBox(height: 14),
          BoldText(
            StringsManager.logoutConfirmTitle,
            color: ThemeEnum.textPrimary,
            fontSize: 16,
            textAlign: TextAlign.center,
          ),
          RSizedBox(height: 6),
          RegularText(
            StringsManager.logoutConfirmDesc,
            color: ThemeEnum.textSecond,
            fontSize: 12,
            textAlign: TextAlign.center,
          ),
          RSizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: RoundedOutlinedButton(
                  borderColor: ThemeEnum.border,
                  onPressed: onCancel,
                  child: MediumText(
                    StringsManager.cancel,
                    color: ThemeEnum.textSecond,
                    fontSize: 13,
                  ),
                ),
              ),
              RSizedBox(width: 10),
              Expanded(
                child: CustomRoundedElevatedButton(
                  backgroundColor: ThemeEnum.accentRed,
                  onPressed: onConfirm,
                  child: SemiBoldText(
                    StringsManager.yesLogout,
                    color: ThemeEnum.solidWhite,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
