import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:algorithm_visualizer/features/auth/presentation/change_email/view_model/change_email_provider.dart';
import 'package:algorithm_visualizer/features/settings/widgets/account_dialog_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Requests a move to a different e-mail address.
///
/// Nothing changes when this dialog closes. Firebase sends a link to the *new*
/// address and swaps it in only once that link is opened, which is what stops
/// someone typing an address they do not own. The password field above it
/// re-authenticates the session, which the operation requires.
class ChangeEmailDialog extends ConsumerStatefulWidget {
  const ChangeEmailDialog({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends ConsumerState<ChangeEmailDialog> {
  bool _passwordVisible = false;

  Future<void> _submit() async {
    final requested = await ref.read(changeEmailProvider.notifier).requestEmailChange();
    if (!mounted) return;

    if (requested) {
      widget.onClose();
      context.showSnackBar(
        message: StringsManager.changeEmailLinkSent,
        type: CustomSnackBarType.success,
      );
      return;
    }

    final error = ref.read(changeEmailProvider).errorMessage;
    if (error != null) {
      context.showSnackBar(message: error, type: CustomSnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(changeEmailProvider.notifier);
    final isLoading = ref.watch(changeEmailProvider.select((s) => s.isLoading));
    final emailError = ref.watch(changeEmailProvider.select((s) => s.newEmailError));
    final passwordError = ref.watch(changeEmailProvider.select((s) => s.currentPasswordError));

    return AccountDialogShell(
      icon: Icons.mark_email_read_outlined,
      title: StringsManager.changeEmailTitle,
      description: StringsManager.changeEmailDialogDesc,
      confirmLabel: StringsManager.saveChanges,
      loading: isLoading,
      onCancel: widget.onClose,
      onConfirm: _submit,
      fields: [
        AuthTextField(
          label: StringsManager.newEmail,
          hintText: StringsManager.emailHint,
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          errorText: emailError,
          onChanged: notifier.setNewEmail,
        ),
        const RSizedBox(height: 12),
        AuthTextField(
          label: StringsManager.currentPassword,
          hintText: StringsManager.currentPasswordHint,
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          isPasswordVisible: _passwordVisible,
          textInputAction: TextInputAction.done,
          errorText: passwordError,
          onTogglePasswordVisibility: () => setState(() => _passwordVisible = !_passwordVisible),
          onChanged: notifier.setCurrentPassword,
          onSubmitted: (_) => isLoading ? null : _submit(),
        ),
      ],
    );
  }
}
