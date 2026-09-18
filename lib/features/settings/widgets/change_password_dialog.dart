import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:algorithm_visualizer/features/auth/presentation/change_password/view_model/change_password_provider.dart';
import 'package:algorithm_visualizer/features/settings/widgets/account_dialog_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Changes the sign-in password.
///
/// The current password is not a courtesy "are you sure": Firebase refuses
/// `updatePassword` on a sign-in more than a few minutes old, so the field is
/// what re-authenticates the user and makes the write possible at all.
class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  bool _currentVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

  Future<void> _submit() async {
    final changed = await ref.read(changePasswordProvider.notifier).changePassword();
    if (!mounted) return;

    if (changed) {
      widget.onClose();
      context.showSnackBar(
        message: StringsManager.passwordUpdated,
        type: CustomSnackBarType.success,
      );
      return;
    }

    final error = ref.read(changePasswordProvider).errorMessage;
    if (error != null) {
      context.showSnackBar(message: error, type: CustomSnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(changePasswordProvider.notifier);
    final isLoading = ref.watch(changePasswordProvider.select((s) => s.isLoading));
    final currentError = ref.watch(changePasswordProvider.select((s) => s.currentPasswordError));
    final newError = ref.watch(changePasswordProvider.select((s) => s.newPasswordError));
    final confirmError = ref.watch(changePasswordProvider.select((s) => s.confirmPasswordError));

    return AccountDialogShell(
      icon: Icons.lock_reset_rounded,
      title: StringsManager.changePasswordTitle,
      description: StringsManager.changePasswordDialogDesc,
      confirmLabel: StringsManager.saveChanges,
      loading: isLoading,
      onCancel: widget.onClose,
      onConfirm: _submit,
      fields: [
        AuthTextField(
          label: StringsManager.currentPassword,
          hintText: StringsManager.currentPasswordHint,
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          isPasswordVisible: _currentVisible,
          errorText: currentError,
          onTogglePasswordVisibility: () => setState(() => _currentVisible = !_currentVisible),
          onChanged: notifier.setCurrentPassword,
        ),
        const RSizedBox(height: 12),
        AuthTextField(
          label: StringsManager.newPassword,
          hintText: StringsManager.newPasswordHint,
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          isPasswordVisible: _newVisible,
          errorText: newError,
          onTogglePasswordVisibility: () => setState(() => _newVisible = !_newVisible),
          onChanged: notifier.setNewPassword,
        ),
        const RSizedBox(height: 12),
        AuthTextField(
          label: StringsManager.confirmNewPassword,
          hintText: StringsManager.confirmNewPasswordHint,
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          isPasswordVisible: _confirmVisible,
          textInputAction: TextInputAction.done,
          errorText: confirmError,
          onTogglePasswordVisibility: () => setState(() => _confirmVisible = !_confirmVisible),
          onChanged: notifier.setConfirmPassword,
          onSubmitted: (_) => isLoading ? null : _submit(),
        ),
      ],
    );
  }
}
