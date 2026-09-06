import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/animated_popup.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/confirmation_dialog_card.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_header_icon.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_primary_button.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_text_field.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_provider.dart';
import 'package:algorithm_visualizer/features/home/view/movable_pins.dart';
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
                  RSizedBox(height: 36),
                  const AuthHeaderIcon(
                    type: AuthHeaderIconType.logo,
                    showBadge: true,
                  ),
                  RSizedBox(height: 20),
                  BoldText(
                    StringsManager.welcomeBack,
                    color: ThemeEnum.textPrimary,
                    fontSize: 24,
                    textAlign: TextAlign.center,
                  ),
                  RSizedBox(height: 8),
                  RegularText(
                    StringsManager.signInSubtitle,
                    color: ThemeEnum.textSecond,
                    fontSize: 13,
                    textAlign: TextAlign.center,
                  ),
                  RSizedBox(height: 28),
                  _EmailAuthTextField(),
                  RSizedBox(height: 18),
                  _AuthPasswordTextField(),
                  RSizedBox(height: 24),
                  _AuthButton(),
                  RSizedBox(height: 36),
                  const _LoginFooter(),
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

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RegularText(
          StringsManager.dontHaveAccount,
          color: ThemeEnum.textSecond,
          fontSize: 13,
        ),
        RSizedBox(width: 4),
        GestureDetector(
          onTap: () => context.push(Routes.signUp.path),
          child: SemiBoldText(
            StringsManager.signUp,
            color: ThemeEnum.accent,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _AuthButton extends ConsumerWidget {
  const _AuthButton();

  Future<void> _login(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(authLoginProvider.notifier).login();
    if (success && context.mounted) context.go(Routes.home.path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authLoginProvider.select((s) => s.isLoading));

    return AuthPrimaryButton(
      title: StringsManager.signIn,
      icon: Icons.arrow_forward_rounded,
      isLoading: isLoading,
      onPressed: () async {
        /// Signing in adopts the account's own progress and drops whatever was
        /// solved as a guest, so warn first, but only when there is something
        /// to lose and the form is worth submitting.
        final hasGuestData = ref.read(guestDataServiceProvider).hasGuestData;

        if (!hasGuestData || !ref.read(authLoginProvider.notifier).validateLogin()) {
          return await _login(context, ref);
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

class _EmailAuthTextField extends ConsumerWidget {
  const _EmailAuthTextField();

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

class _AuthPasswordTextField extends ConsumerStatefulWidget {
  const _AuthPasswordTextField();

  @override
  ConsumerState<_AuthPasswordTextField> createState() => _AuthPasswordTextFieldState();
}

class _AuthPasswordTextFieldState extends ConsumerState<_AuthPasswordTextField> {
  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    final passwordError = ref.watch(authLoginProvider.select((s) => s.passwordError));

    return AuthTextField(
      label: StringsManager.password,
      hintText: StringsManager.passwordHint,
      prefixIcon: Icons.lock_outline_rounded,
      isPassword: true,
      isPasswordVisible: isPasswordVisible,
      textInputAction: TextInputAction.done,
      errorText: passwordError,
      onTogglePasswordVisibility: () {
        setState(() {
          isPasswordVisible = !isPasswordVisible;
        });
      },
      onChanged: (v) => ref.read(authLoginProvider.notifier).setPassword(v),
      // onSubmitted: (_) => _onLogin(),
      trailingLabelWidget: GestureDetector(
        onTap: () => context.push(Routes.forgotPassword.path),
        child: MediumText(
          StringsManager.forgotPasswordQuestion,
          color: ThemeEnum.accent,
          fontSize: 12,
        ),
      ),
    );
  }
}
