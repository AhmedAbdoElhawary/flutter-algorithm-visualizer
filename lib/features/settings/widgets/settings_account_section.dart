import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/animated_popup.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/confirmation_dialog_card.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:algorithm_visualizer/features/settings/widgets/change_display_name_dialog.dart';
import 'package:algorithm_visualizer/features/settings/widgets/change_email_dialog.dart';
import 'package:algorithm_visualizer/features/settings/widgets/change_password_dialog.dart';
import 'package:algorithm_visualizer/features/settings/widgets/delete_account_dialog.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The Account card.
///
/// A signed-in user sees which account they are on, then the three things they
/// can change about it, then the way out of it for good. A guest owns only a
/// display name, so that is the whole card for them — the way *in* lives in
/// [SettingsSessionCard] at the foot of the page, with log out.
class SettingsAccountSection extends ConsumerWidget {
  const SettingsAccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(isSignedInProvider);

    return CardContainer(
      surface: CdSurface.main,
      padding: REdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: isSignedIn ? const _SignedInRows() : const _DisplayNameRow(),
    );
  }
}

/// Shows the current name as its caption and opens the rename dialog, exactly
/// like the two rows below it. The profile header used to edit this inline
/// behind a pencil icon; one editable field hidden on another page is one more
/// place for the name to be changed from than there needs to be.
class _DisplayNameRow extends ConsumerWidget {
  const _DisplayNameRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(currentUserNameProvider.select((value) => value));

    return SettingsRow(
      icon: Icons.badge_outlined,
      title: StringsManager.displayName,
      subtitle: name,
      onTap: () => AnimatedPopup.show(
        context,
        builder: (removeOverlay) => ChangeDisplayNameDialog(onClose: removeOverlay),
      ),
    );
  }
}

class _SignedInRows extends StatelessWidget {
  const _SignedInRows();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EmailRow(),
        SettingsRowDivider(),
        _DisplayNameRow(),
        SettingsRowDivider(),
        _ChangeEmailRow(),
        SettingsRowDivider(),
        _ChangePasswordRow(),
        SettingsRowDivider(),
        _DeleteAccountRow(),
      ],
    );
  }
}

class _EmailRow extends ConsumerWidget {
  const _EmailRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(currentUserProvider.select((value) => value?.email));

    return SettingsRow(
      icon: Icons.alternate_email_rounded,
      title: StringsManager.settingsSignedInAs,
      subtitle: email,
      showChevron: false,
    );
  }
}

class _ChangeEmailRow extends StatelessWidget {
  const _ChangeEmailRow();

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: Icons.mark_email_read_outlined,
      title: StringsManager.changeEmail,
      subtitle: StringsManager.changeEmailDesc,
      onTap: () => AnimatedPopup.show(
        context,
        builder: (removeOverlay) => ChangeEmailDialog(onClose: removeOverlay),
      ),
    );
  }
}

class _ChangePasswordRow extends StatelessWidget {
  const _ChangePasswordRow();

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: Icons.lock_reset_rounded,
      title: StringsManager.changePassword,
      subtitle: StringsManager.changePasswordDesc,
      onTap: () => AnimatedPopup.show(
        context,
        builder: (removeOverlay) => ChangePasswordDialog(onClose: removeOverlay),
      ),
    );
  }
}

/// Deletion asks twice on purpose: once for the consequence, once for the
/// identity. The second step is not optional politeness — see
/// [DeleteAccountDialog].
class _DeleteAccountRow extends StatelessWidget {
  const _DeleteAccountRow();

  void _openPasswordStep(BuildContext context) {
    AnimatedPopup.show(
      context,
      builder: (removeOverlay) => DeleteAccountDialog(onClose: removeOverlay),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: Icons.delete_outline_rounded,
      title: StringsManager.deleteAccount,
      subtitle: StringsManager.deleteAccountDesc,
      accentColor: ThemeEnum.dataHard,
      onTap: () => AnimatedPopup.show(
        context,
        builder: (removeOverlay) => ConfirmationDialogCard(
          icon: Icons.warning_amber_rounded,
          title: StringsManager.deleteAccountConfirmTitle,
          description: StringsManager.deleteAccountConfirmDesc,
          confirmLabel: StringsManager.deleteAccountContinue,
          onCancel: removeOverlay,
          onConfirm: () {
            removeOverlay();
            _openPasswordStep(context);
          },
        ),
      ),
    );
  }
}
