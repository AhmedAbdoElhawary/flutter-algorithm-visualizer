import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/animated_popup.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/confirmation_dialog_card.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:algorithm_visualizer/features/settings/presentation/widgets/delete_account_dialog.dart';
import 'package:algorithm_visualizer/features/settings/presentation/widgets/settings_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// The Account card. A guest is offered a way in; a signed-in user is shown
/// which account they are on and the way out of it for good.
class SettingsAccountSection extends ConsumerWidget {
  const SettingsAccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(isSignedInProvider);

    return CardContainer(
      surface: CdSurface.main,
      padding: REdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: isSignedIn ? const _SignedInRows() : const _GuestRow(),
    );
  }
}

class _GuestRow extends StatelessWidget {
  const _GuestRow();

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: Icons.login_rounded,
      title: StringsManager.guestAccountTitle,
      subtitle: StringsManager.settingsGuestModeDesc,
      onTap: () => context.push(Routes.login.path),
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
        _DeleteAccountRow(),
      ],
    );
  }
}

class _EmailRow extends ConsumerWidget {
  const _EmailRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(
      currentUserProvider.select(
        (value) => value.maybeWhen(data: (data) => data?.email ?? '', orElse: () => ''),
      ),
    );

    return SettingsRow(
      icon: Icons.alternate_email_rounded,
      title: StringsManager.settingsSignedInAs,
      subtitle: email,
      showChevron: false,
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
