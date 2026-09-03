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

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetLink() async {
    final success = await ref.read(authProvider.notifier).forgotPassword();
    if (success && mounted) {
      context.push(Routes.resetPassword.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final emailError = ref.watch(authProvider.select((s) => s.emailError));
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
                  const _ForgotPasswordAppBar(),
                  RSizedBox(height: 32),
                  const AuthHeaderIcon(
                    type: AuthHeaderIconType.key,
                    showBadge: false,
                  ),
                  RSizedBox(height: 20),
                  BoldText(
                    StringsManager.forgotPasswordTitle,
                    color: ThemeEnum.textPrimary,
                    fontSize: 24,
                    textAlign: TextAlign.center,
                  ),
                  RSizedBox(height: 8),
                  RegularText(
                    StringsManager.forgotPasswordSubtitle,
                    color: ThemeEnum.textSecond,
                    fontSize: 13,
                    textAlign: TextAlign.center,
                  ),
                  RSizedBox(height: 28),
                  AuthTextField(
                    label: StringsManager.registeredEmail,
                    hintText: StringsManager.emailHint,
                    prefixIcon: Icons.mail_outline_rounded,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    helperText: StringsManager.recoveryEmailNote,
                    errorText: emailError,
                    onChanged: (v) => ref.read(authProvider.notifier).setEmail(v),
                    onSubmitted: (_) => _onSendResetLink(),
                  ),
                  RSizedBox(height: 28),
                  AuthPrimaryButton(
                    title: StringsManager.sendResetLink,
                    icon: Icons.send_rounded,
                    isLoading: isLoading,
                    onPressed: _onSendResetLink,
                  ),
                  RSizedBox(height: 36),
                  const _ReturnToLoginLink(),
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

class _ForgotPasswordAppBar extends StatelessWidget {
  const _ForgotPasswordAppBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const AuthBackButton(),
        MediumText(
          StringsManager.accountRecovery,
          color: ThemeEnum.textSecond,
          fontSize: 12,
          letterSpacing: 1.0,
        ),
        RSizedBox(width: 40),
      ],
    );
  }
}

class _ReturnToLoginLink extends StatelessWidget {
  const _ReturnToLoginLink();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(Routes.login.path);
        }
      },
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
