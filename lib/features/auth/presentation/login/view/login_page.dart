import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/animated_popup.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/confirmation_dialog_card.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_common_bits.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_logo_tile.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_primary_button.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_scaffold.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_text_field.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      authLoginProvider.select((s) => s.errorMessage),
      (previous, next) {
        if (next != null) context.showSnackBar(message: next, type: CustomSnackBarType.error);
      },
    );

    return AuthScaffold(
      topInset: CdSpace.x12,
      children: [
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: AuthLogoTile(),
        ),
        SizedBox(height: CdSpace.x6.h),
        const AuthTitle(StringsManager.welcomeBack, large: true),
        SizedBox(height: CdSpace.x2.h),
        const AuthSubtitle(StringsManager.signInSubtitle),
        SizedBox(height: CdSpace.x8.h),
        const _EmailField(),
        SizedBox(height: CdSpace.x4.h),
        const _PasswordField(),
        SizedBox(height: CdSpace.x8.h),
        const _SignInButton(),
        // SizedBox(height: CdSpace.x4.h),
        // const AuthDivider(),
        // SizedBox(height: CdSpace.x4.h),
        // AuthSecondaryButton(
        //   title: StringsManager.continueWithGoogle,
        //   onPressed: () => context.showSnackBar(
        //     message: StringsManager.socialAuthUnavailable,
        //     type: CustomSnackBarType.info,
        //   ),
        // ),
        SizedBox(height: CdSpace.x6.h),
        AuthFooterPrompt(
          prompt: StringsManager.noAccountYet,
          action: StringsManager.signUp,
          onTap: () => context.push(Routes.signUp.path),
        ),
      ],
    );
  }
}

class _SignInButton extends ConsumerWidget {
  const _SignInButton();

  Future<void> _login(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(authLoginProvider.notifier).login();
    if (success && context.mounted) context.go(Routes.home.path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authLoginProvider.select((s) => s.isLoading));

    return AuthPrimaryButton(
      title: StringsManager.signIn,
      isLoading: isLoading,
      onPressed: () {
        /// Signing in adopts the account's own progress and drops whatever was
        /// solved as a guest, so warn first, but only when there is something
        /// to lose and the form is worth submitting.
        final hasGuestData = ref.read(guestDataServiceProvider).hasGuestData;

        if (!hasGuestData || !ref.read(authLoginProvider.notifier).validateLogin()) {
          _login(context, ref);
          return;
        }

        AnimatedPopup.show(
          context,
          builder: (removeOverlay) => ConfirmationDialogCard(
            icon: Icons.sync_problem_rounded,
            title: StringsManager.guestProgressWarningTitle,
            description: StringsManager.guestProgressWarningDesc,
            confirmLabel: StringsManager.continueToLogin,
            onCancel: removeOverlay,
            onConfirm: () {
              removeOverlay();
              _login(context, ref);
            },
          ),
        );
      },
    );
  }
}

class _EmailField extends ConsumerWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailError = ref.watch(authLoginProvider.select((s) => s.emailError));

    return AuthTextField(
      label: StringsManager.emailAddress,
      hintText: StringsManager.emailHint,
      prefixIcon: Icons.mail_outline_rounded,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      errorText: emailError,
      onChanged: (v) => ref.read(authLoginProvider.notifier).setEmail(v),
    );
  }
}

class _PasswordField extends ConsumerStatefulWidget {
  const _PasswordField();

  @override
  ConsumerState<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends ConsumerState<_PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final passwordError = ref.watch(authLoginProvider.select((s) => s.passwordError));

    return AuthTextField(
      label: StringsManager.password,
      hintText: StringsManager.passwordHint,
      prefixIcon: Icons.lock_outline_rounded,
      isPassword: true,
      isPasswordVisible: _visible,
      textInputAction: TextInputAction.done,
      errorText: passwordError,
      onTogglePasswordVisibility: () => setState(() => _visible = !_visible),
      onChanged: (v) => ref.read(authLoginProvider.notifier).setPassword(v),
      trailingLabelWidget: GestureDetector(
        onTap: () => context.push(Routes.forgotPassword.path),
        child: const MediumText(StringsManager.forgotShort, color: ThemeEnum.primaryHover, fontSize: 11, maxLines: 1),
      ),
    );
  }
}
