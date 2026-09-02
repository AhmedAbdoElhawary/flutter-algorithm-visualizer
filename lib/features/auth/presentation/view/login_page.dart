import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/widgets/auth_header_icon.dart';
import 'package:algorithm_visualizer/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:algorithm_visualizer/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/features/auth/presentation/widgets/demo_account_card.dart';
import 'package:algorithm_visualizer/features/home/view/movable_pins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final success = await ref.read(authProvider.notifier).login();
    if (success && mounted) {
      context.go(Routes.home.path);
    }
  }

  void _onAutoFill() {
    ref.read(authProvider.notifier).fillDemoAccount();
    _emailController.text = 'ahmed@example.com';
    _passwordController.text = 'password123';
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordVisible = ref.watch(authProvider.select((s) => s.isPasswordVisible));
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final emailError = ref.watch(authProvider.select((s) => s.emailError));
    final passwordError = ref.watch(authProvider.select((s) => s.passwordError));
    final errorMessage = ref.watch(authProvider.select((s) => s.errorMessage));

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
                  if (errorMessage != null) ...[
                    _AuthErrorBanner(message: errorMessage),
                    RSizedBox(height: 16),
                  ],
                  AuthTextField(
                    label: StringsManager.emailAddress,
                    hintText: StringsManager.emailHint,
                    prefixIcon: Icons.mail_outline_rounded,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    errorText: emailError,
                    onChanged: (v) => ref.read(authProvider.notifier).setEmail(v),
                  ),
                  RSizedBox(height: 18),
                  AuthTextField(
                    label: StringsManager.password,
                    hintText: StringsManager.passwordHint,
                    prefixIcon: Icons.lock_outline_rounded,
                    controller: _passwordController,
                    isPassword: true,
                    isPasswordVisible: isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    errorText: passwordError,
                    onTogglePasswordVisibility: () =>
                        ref.read(authProvider.notifier).togglePasswordVisibility(),
                    onChanged: (v) => ref.read(authProvider.notifier).setPassword(v),
                    onSubmitted: (_) => _onLogin(),
                    trailingLabelWidget: GestureDetector(
                      onTap: () => context.push(Routes.forgotPassword.path),
                      child: MediumText(
                        StringsManager.forgotPasswordQuestion,
                        color: ThemeEnum.accent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  RSizedBox(height: 24),
                  AuthPrimaryButton(
                    title: StringsManager.signIn,
                    icon: Icons.arrow_forward_rounded,
                    isLoading: isLoading,
                    onPressed: _onLogin,
                  ),
                  RSizedBox(height: 20),
                  DemoAccountCard(onAutoFill: _onAutoFill),
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

class _AuthErrorBanner extends StatelessWidget {
  final String message;

  const _AuthErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.accentRed).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: context.getColor(ThemeEnum.accentRed).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CustomIcon(
            Icons.error_outline_rounded,
            size: 16,
            color: ThemeEnum.accentRed,
          ),
          RSizedBox(width: 8),
          Expanded(
            child: RegularText(
              message,
              color: ThemeEnum.accentRed,
              fontSize: 12,
            ),
          ),
        ],
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
