import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/animated_popup.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/confirmation_dialog_card.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfileLogoutCard extends ConsumerWidget {
  const ProfileLogoutCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(isSignedInProvider);

    return HorizontalPadding(
      padding: 16,
      child: isSignedIn ? const _LogoutCard() : const _GuestSignInCard(),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard();

  @override
  Widget build(BuildContext context) {
    return AnimatedPopup(
      builder: (removeOverlay) => Consumer(
        builder: (context, ref, child) => ConfirmationDialogCard(
          icon: Icons.logout_rounded,
          title: StringsManager.logoutConfirmTitle,
          description: StringsManager.logoutConfirmDesc,
          confirmLabel: StringsManager.yesLogout,
          onCancel: removeOverlay,
          onConfirm: () async {
            removeOverlay();
            await ref.read(authLoginProvider.notifier).logout();
            if (context.mounted) context.go(Routes.login.path);
          },
        ),
      ),
      child: const _AccountCardBody(
        icon: Icons.logout_rounded,
        title: StringsManager.logout,
        accentColor: ThemeEnum.accentRed,
      ),
    );
  }
}

class _GuestSignInCard extends StatelessWidget {
  const _GuestSignInCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.login.path),
      child: const _AccountCardBody(
        icon: Icons.login_rounded,
        title: StringsManager.guestAccountTitle,
        subtitle: StringsManager.guestAccountDesc,
        accentColor: ThemeEnum.accent,
      ),
    );
  }
}

class _AccountCardBody extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final ThemeEnum accentColor;

  const _AccountCardBody({
    required this.icon,
    required this.title,
    required this.accentColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsetsDirectional.only(start: 14,end: 8, top: 12,bottom: 12),
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.card),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.getColor(accentColor).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: context.getColor(accentColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: context.getColor(accentColor).withValues(alpha: 0.25),
              ),
            ),
            child: Center(
              child: CustomIcon(
                icon,
                size: 18,
                color: accentColor,
              ),
            ),
          ),
          const RSizedBox(width: 6),
          Expanded(
            child: _AccountCardLabels(
              title: title,
              subtitle: subtitle,
              accentColor: accentColor,
            ),
          ),
          const CustomIcon(
            Icons.chevron_right_rounded,
            size: 18,
            color: ThemeEnum.hover,
          ),
        ],
      ),
    );
  }
}

class _AccountCardLabels extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final ThemeEnum accentColor;

  const _AccountCardLabels({
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(
      currentUserProvider.select(
        (value) => value.maybeWhen(data: (data) => data?.email ?? "", orElse: () => ""),
      ),
    );
    final caption = email.isNotEmpty ? email : subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText(
          title,
          color: accentColor,
          fontSize: 13,
          fontWeight: FontWeightManager.bold800,
        ),
        if (caption != null && caption.isNotEmpty) ...[
          const RSizedBox(height: 2),
          RegularText(
            caption,
            color: ThemeEnum.textSecond,
            fontSize: 11,
          ),
        ],
      ],
    );
  }
}
