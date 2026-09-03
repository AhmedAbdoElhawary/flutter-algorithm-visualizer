import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:algorithm_visualizer/features/auth/presentation/widgets/auth_header_icon.dart';
import 'package:algorithm_visualizer/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:algorithm_visualizer/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/features/home/view/movable_pins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _onSaveNewPassword() async {
    final success = await ref.read(authProvider.notifier).resetPassword();
    if (success && mounted) {
      context.go(Routes.login.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNewPasswordVisible =
        ref.watch(authProvider.select((s) => s.isNewPasswordVisible));
    final isConfirmNewPasswordVisible =
        ref.watch(authProvider.select((s) => s.isConfirmNewPasswordVisible));
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final codeError = ref.watch(authProvider.select((s) => s.verificationCodeError));
    final newPasswordError = ref.watch(authProvider.select((s) => s.newPasswordError));
    final confirmNewPasswordError =
        ref.watch(authProvider.select((s) => s.confirmNewPasswordError));
    ref.listen(
      authProvider.select((s) => s.errorMessage),
          (previous, next) {
        if (next != null) context.showSnackBar(message: next, type: CustomSnackBarType.error);
      },
    );
    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.primary),
      body: SafeArea(
        child: MovablePinsBackground(
          pinColor: ThemeEnum.whiteD4Color,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: HorizontalPadding(
              padding: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RSizedBox(height: 16),
                  const _ResetPasswordAppBar(),
                  RSizedBox(height: 32),
                  const AuthHeaderIcon(
                    type: AuthHeaderIconType.key,
                    showBadge: false,
                  ),
                  RSizedBox(height: 20),
                  BoldText(
                    StringsManager.setNewPassword,
                    color: ThemeEnum.textPrimary,
                    fontSize: 24,
                    textAlign: TextAlign.center,
                  ),
                  RSizedBox(height: 8),
                  RegularText(
                    StringsManager.setNewPasswordSubtitle,
                    color: ThemeEnum.textSecond,
                    fontSize: 13,
                    textAlign: TextAlign.center,
                  ),
                  RSizedBox(height: 24),
                  AuthTextField(
                    label: StringsManager.verificationCode,
                    hintText: StringsManager.verificationCodeHint,
                    prefixIcon: Icons.pin_outlined,
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    errorText: codeError,
                    onChanged: (v) =>
                        ref.read(authProvider.notifier).setVerificationCode(v),
                  ),
                  RSizedBox(height: 16),
                  AuthTextField(
                    label: StringsManager.newPassword,
                    hintText: StringsManager.newPasswordHint,
                    prefixIcon: Icons.lock_outline_rounded,
                    controller: _newPasswordController,
                    isPassword: true,
                    isPasswordVisible: isNewPasswordVisible,
                    textInputAction: TextInputAction.next,
                    errorText: newPasswordError,
                    onTogglePasswordVisibility: () =>
                        ref.read(authProvider.notifier).toggleNewPasswordVisibility(),
                    onChanged: (v) =>
                        ref.read(authProvider.notifier).setNewPassword(v),
                  ),
                  RSizedBox(height: 16),
                  AuthTextField(
                    label: StringsManager.confirmNewPassword,
                    hintText: StringsManager.confirmNewPasswordHint,
                    prefixIcon: Icons.lock_outline_rounded,
                    controller: _confirmNewPasswordController,
                    isPassword: true,
                    isPasswordVisible: isConfirmNewPasswordVisible,
                    textInputAction: TextInputAction.done,
                    errorText: confirmNewPasswordError,
                    onTogglePasswordVisibility: () => ref
                        .read(authProvider.notifier)
                        .toggleConfirmNewPasswordVisibility(),
                    onChanged: (v) =>
                        ref.read(authProvider.notifier).setConfirmNewPassword(v),
                    onSubmitted: (_) => _onSaveNewPassword(),
                  ),
                  RSizedBox(height: 24),
                  AuthPrimaryButton(
                    title: StringsManager.saveNewPassword,
                    icon: Icons.verified_user_outlined,
                    isLoading: isLoading,
                    onPressed: _onSaveNewPassword,
                  ),
                  RSizedBox(height: 28),
                  const _ResetPasswordReturnToLoginLink(),
                  RSizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetPasswordAppBar extends StatelessWidget {
  const _ResetPasswordAppBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const AuthBackButton(),
        MediumText(
          StringsManager.newPasswordTitle,
          color: ThemeEnum.textSecond,
          fontSize: 12,
          letterSpacing: 1.0,
        ),
        RSizedBox(width: 40),
      ],
    );
  }
}

class _ResetPasswordReturnToLoginLink extends StatelessWidget {
  const _ResetPasswordReturnToLoginLink();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(Routes.login.path),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIcon(
            Icons.arrow_back_rounded,
            size: 14,
            color: ThemeEnum.textSecond,
          ),
          RSizedBox(width: 6),
          RegularText(
            StringsManager.returnToLogin,
            color: ThemeEnum.textSecond,
            fontSize: 13,
          ),
        ],
      ),
    );
  }
}
