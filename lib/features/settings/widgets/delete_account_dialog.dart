import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/helpers/link_launcher.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/primary_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/secondary_button_quiet.dart';
import 'package:algorithm_visualizer/features/auth/presentation/delete_account/view_model/delete_account_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Step two of the deletion flow: prove it is really you.
///
/// The password is not a second "are you sure" — Firebase refuses to delete a
/// user whose sign-in is more than a few minutes old, so re-authenticating is
/// part of the operation itself. Asking here is the only way to get it.
class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  bool _visible = false;

  Future<void> _delete() async {
    final deleted = await ref.read(deleteAccountProvider.notifier).deleteAccount();
    if (!mounted) return;

    if (deleted) {
      widget.onClose();
      context.showSnackBar(
        message: StringsManager.deleteAccountSuccess,
        type: CustomSnackBarType.success,
      );
      context.pushAndRemoveAll(Routes.login);
      return;
    }

    final error = ref.read(deleteAccountProvider).errorMessage;
    if (error != null) {
      context.showSnackBar(message: error, type: CustomSnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(deleteAccountProvider.select((s) => s.isLoading));
    final passwordError = ref.watch(deleteAccountProvider.select((s) => s.passwordError));

    return CardContainer(
      radius: CdRadius.dialog,
      padding: REdgeInsets.all(20),
      child: SizedBox(
        width: 320.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DialogIcon(),
            const RSizedBox(height: 14),
            const BoldText(
              StringsManager.deleteAccountPasswordTitle,
              color: ThemeEnum.inkTitle,
              fontSize: 16,
              fontWeight: FontWeightManager.bold800,
              textAlign: TextAlign.center,
            ),
            const RSizedBox(height: 6),
            const RegularText(
              StringsManager.deleteAccountPasswordDesc,
              color: ThemeEnum.inkSecondaryTitle,
              fontSize: 12,
              textAlign: TextAlign.center,
            ),
            const RSizedBox(height: 18),
            AuthTextField(
              label: StringsManager.password,
              hintText: StringsManager.passwordHint,
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
              isPasswordVisible: _visible,
              textInputAction: TextInputAction.done,
              errorText: passwordError,
              onTogglePasswordVisibility: () => setState(() => _visible = !_visible),
              onChanged: (v) => ref.read(deleteAccountProvider.notifier).setPassword(v),
              onSubmitted: (_) => isLoading ? null : _delete(),
            ),
            const RSizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SecondaryButtonQuiet(
                    label: StringsManager.cancel,
                    onPressed: isLoading ? null : widget.onClose,
                  ),
                ),
                const RSizedBox(width: 10),
                Expanded(
                  child: PrimaryButtonQuiet(
                    label: StringsManager.deleteAccountConfirmButton,
                    loading: isLoading,
                    onPressed: isLoading ? null : _delete,
                  ),
                ),
              ],
            ),
            const RSizedBox(height: 12),
            const _WebNoticeLink(),
          ],
        ),
      ),
    );
  }
}

/// The way out for someone who cannot complete this dialog — a forgotten
/// password, or a lost device. Google requires that route to exist at a public
/// URL, so pointing at it from here costs nothing and closes the loop.
class _WebNoticeLink extends StatelessWidget {
  const _WebNoticeLink();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.openLink(kDeleteAccountUrl),
      child: const MediumText(
        StringsManager.deleteAccountWebNotice,
        color: ThemeEnum.inkSecondaryTitle,
        fontSize: 10.5,
        maxLines: 3,
        textAlign: TextAlign.center,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

class _DialogIcon extends StatelessWidget {
  const _DialogIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 48.r,
        height: 48.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.raised),
          shape: BoxShape.circle,
        ),
        child: const CustomIcon(
          Icons.delete_forever_rounded,
          size: 24,
          color: ThemeEnum.dataHard,
        ),
      ),
    );
  }
}
