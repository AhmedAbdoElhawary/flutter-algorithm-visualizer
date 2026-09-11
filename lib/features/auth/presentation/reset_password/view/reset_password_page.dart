// import 'package:algorithm_visualizer/config/routes/route_app.dart';
// import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
// import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
// import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
// import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_common_bits.dart';
// import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_logo_tile.dart';
// import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_primary_button.dart';
// import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_scaffold.dart';
// import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_text_field.dart';
// import 'package:algorithm_visualizer/features/auth/presentation/common/widget/password_strength_meter.dart';
// import 'package:algorithm_visualizer/features/auth/presentation/reset_password/view_model/reset_password_auth_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
//
// /// Not depicted in the CoreDive handoff (screen 12 stops at "Send code"). Built
// /// on the same auth components for continuity.
// class ResetPasswordPage extends ConsumerStatefulWidget {
//   const ResetPasswordPage({super.key});
//
//   @override
//   ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }
//
// class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
//   final _codeController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmNewPasswordController = TextEditingController();
//
//   @override
//   void dispose() {
//     _codeController.dispose();
//     _newPasswordController.dispose();
//     _confirmNewPasswordController.dispose();
//     super.dispose();
//   }
//
//   void _onSaveNewPassword() async {
//     final success = await ref.read(authResetPasswordProvider.notifier).resetPassword();
//     if (success && mounted) context.go(Routes.login.path);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isLoading = ref.watch(authResetPasswordProvider.select((s) => s.isLoading));
//     final codeError = ref.watch(authResetPasswordProvider.select((s) => s.verificationCodeError));
//
//     ref.listen(
//       authResetPasswordProvider.select((s) => s.errorMessage),
//       (previous, next) {
//         if (next != null) context.showSnackBar(message: next, type: CustomSnackBarType.error);
//       },
//     );
//
//     return AuthScaffold(
//       topInset: CdSpace.x2,
//       children: [
//         AuthEyebrowRow(
//           StringsManager.newPasswordTitle,
//           onBack: () => context.canPop() ? context.pop() : context.go(Routes.login.path),
//         ),
//         SizedBox(height: CdSpace.x8.h),
//         const Align(
//           alignment: AlignmentDirectional.centerStart,
//           child: AuthRecoveryTile(),
//         ),
//         SizedBox(height: CdSpace.x6.h),
//         const AuthTitle(StringsManager.setNewPassword),
//         SizedBox(height: CdSpace.x2.h),
//         const AuthSubtitle(StringsManager.setNewPasswordSubtitle),
//         SizedBox(height: CdSpace.x8.h),
//         AuthTextField(
//           label: StringsManager.verificationCode,
//           hintText: StringsManager.verificationCodeHint,
//           prefixIcon: Icons.pin_outlined,
//           controller: _codeController,
//           keyboardType: TextInputType.number,
//           textInputAction: TextInputAction.next,
//           errorText: codeError,
//           onChanged: (v) => ref.read(authResetPasswordProvider.notifier).setVerificationCode(v),
//         ),
//         SizedBox(height: CdSpace.gapCard.h),
//         _NewPasswordField(controller: _newPasswordController),
//         SizedBox(height: CdSpace.gapCard.h),
//         _ConfirmNewPasswordField(
//           controller: _confirmNewPasswordController,
//           onSubmitted: (_) => _onSaveNewPassword(),
//         ),
//         SizedBox(height: CdSpace.x6.h),
//         AuthPrimaryButton(
//           title: StringsManager.saveNewPassword,
//           isLoading: isLoading,
//           onPressed: _onSaveNewPassword,
//         ),
//         SizedBox(height: CdSpace.x6.h),
//         const AuthReturnLink(StringsManager.returnToSignIn),
//       ],
//     );
//   }
// }
//
// class _NewPasswordField extends ConsumerStatefulWidget {
//   const _NewPasswordField({required this.controller});
//
//   final TextEditingController controller;
//
//   @override
//   ConsumerState<_NewPasswordField> createState() => _NewPasswordFieldState();
// }
//
// class _NewPasswordFieldState extends ConsumerState<_NewPasswordField> {
//   bool _visible = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final newPasswordError = ref.watch(authResetPasswordProvider.select((s) => s.newPasswordError));
//     final password = ref.watch(authResetPasswordProvider.select((s) => s.newPassword));
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AuthTextField(
//           label: StringsManager.newPassword,
//           hintText: StringsManager.newPasswordHint,
//           prefixIcon: Icons.lock_outline_rounded,
//           controller: widget.controller,
//           isPassword: true,
//           isPasswordVisible: _visible,
//           textInputAction: TextInputAction.next,
//           errorText: newPasswordError,
//           onTogglePasswordVisibility: () => setState(() => _visible = !_visible),
//           onChanged: (v) => ref.read(authResetPasswordProvider.notifier).setNewPassword(v),
//         ),
//         if (newPasswordError == null || newPasswordError.isEmpty)
//           PasswordStrengthMeter(password: password),
//       ],
//     );
//   }
// }
//
// class _ConfirmNewPasswordField extends ConsumerStatefulWidget {
//   const _ConfirmNewPasswordField({required this.controller, this.onSubmitted});
//
//   final TextEditingController controller;
//   final ValueChanged<String>? onSubmitted;
//
//   @override
//   ConsumerState<_ConfirmNewPasswordField> createState() => _ConfirmNewPasswordFieldState();
// }
//
// class _ConfirmNewPasswordFieldState extends ConsumerState<_ConfirmNewPasswordField> {
//   bool _visible = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final confirmNewPasswordError =
//         ref.watch(authResetPasswordProvider.select((s) => s.confirmNewPasswordError));
//
//     return AuthTextField(
//       label: StringsManager.confirmNewPassword,
//       hintText: StringsManager.confirmNewPasswordHint,
//       prefixIcon: Icons.lock_outline_rounded,
//       controller: widget.controller,
//       isPassword: true,
//       isPasswordVisible: _visible,
//       textInputAction: TextInputAction.done,
//       errorText: confirmNewPasswordError,
//       onTogglePasswordVisibility: () => setState(() => _visible = !_visible),
//       onChanged: (v) => ref.read(authResetPasswordProvider.notifier).setConfirmNewPassword(v),
//       onSubmitted: widget.onSubmitted,
//     );
//   }
// }
