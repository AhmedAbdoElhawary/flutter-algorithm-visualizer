import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/animated_popup.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/confirmation_dialog_card.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The last card on the Settings page: the way out of the account, or the way
/// into one.
///
/// It used to sit at the foot of the profile page. Signing in and signing out
/// are settings, not statistics, and keeping them here means there is exactly
/// one screen that changes who you are signed in as.
///
/// No section header above it on purpose — it is a single destructive-ish
/// action, not a group of related rows.
class SettingsSessionCard extends ConsumerWidget {
  const SettingsSessionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(isSignedInProvider);

    return isSignedIn ? const _LogoutCard() : const _GuestSignInCard();
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
            if (context.mounted) context.pushAndRemoveAll(Routes.login);
          },
        ),
      ),
      child: const _AccountCardBody(
        icon: Icons.logout_rounded,
        title: StringsManager.logout,
        accentColor: ThemeEnum.dataHard,
      ),
    );
  }
}

class _GuestSignInCard extends StatelessWidget {
  const _GuestSignInCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// `go`, not `push` — see [MainNavigationShell]. Pushing login over the
      /// live shell keeps Settings open behind it, so signing in as someone
      /// else lands back on Settings when the profile tab is next tapped.
      onTap: () => context.pushAndRemoveAll(Routes.login),
      child: const _AccountCardBody(
        icon: Icons.login_rounded,
        title: StringsManager.guestAccountTitle,
        subtitle: StringsManager.guestAccountDesc,
        accentColor: ThemeEnum.inkPrimary,
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
    return CardContainer(
      surface: CdSurface.main,
      padding: REdgeInsetsDirectional.only(start: 14, end: 8, top: 12, bottom: 12),
      child: Row(
        children: [
          IconButtonQuiet(icon: icon, size: 36, iconSize: 18, iconColor: accentColor),
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
            color: ThemeEnum.track,
            flipsWithDirection: true,
          ),
        ],
      ),
    );
  }
}

class _AccountCardLabels extends StatelessWidget {
  final String title;
  final String? subtitle;
  final ThemeEnum accentColor;

  const _AccountCardLabels({
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText(
          title,
          color: accentColor,
          fontSize: 13,
          fontWeight: FontWeightManager.bold800,
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const RSizedBox(height: 2),
          RegularText(
            subtitle!,
            color: ThemeEnum.inkSecondaryTitle,
            fontSize: 11,
          ),
        ],
      ],
    );
  }
}
