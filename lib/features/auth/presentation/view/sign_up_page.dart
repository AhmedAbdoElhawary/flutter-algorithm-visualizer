import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/widgets/auth_header_icon.dart';
import 'package:algorithm_visualizer/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:algorithm_visualizer/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/features/home/view/movable_pins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    final success = await ref.read(authProvider.notifier).register();
    if (success && mounted) {
      context.go(Routes.home.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordVisible = ref.watch(authProvider.select((s) => s.isPasswordVisible));
    final isConfirmPasswordVisible =
        ref.watch(authProvider.select((s) => s.isConfirmPasswordVisible));
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final nameError = ref.watch(authProvider.select((s) => s.nameError));
    final emailError = ref.watch(authProvider.select((s) => s.emailError));
    final passwordError = ref.watch(authProvider.select((s) => s.passwordError));
    final confirmPasswordError = ref.watch(authProvider.select((s) => s.confirmPasswordError));
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
                  RSizedBox(height: 32),
                  const AuthHeaderIcon(
                    type: AuthHeaderIconType.shield,
                    showBadge: false,
                  ),
                  RSizedBox(height: 20),
                  BoldText(
                    StringsManager.createAccount,
                    color: ThemeEnum.textPrimary,
                    fontSize: 24,
                    textAlign: TextAlign.center,
                  ),
                  RSizedBox(height: 8),
                  RegularText(
                    StringsManager.signUpSubtitle,
                    color: ThemeEnum.textSecond,
                    fontSize: 13,
                    textAlign: TextAlign.center,
                  ),
                  RSizedBox(height: 24),
                  AuthTextField(
                    label: StringsManager.fullName,
                    hintText: StringsManager.fullNameHint,
                    prefixIcon: Icons.person_outline_rounded,
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    errorText: nameError,
                    onChanged: (v) => ref.read(authProvider.notifier).setName(v),
                  ),
                  RSizedBox(height: 16),
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
                  RSizedBox(height: 16),
                  AuthTextField(
                    label: StringsManager.password,
                    hintText: StringsManager.createStrongPasswordHint,
                    prefixIcon: Icons.lock_outline_rounded,
                    controller: _passwordController,
                    isPassword: true,
                    isPasswordVisible: isPasswordVisible,
                    textInputAction: TextInputAction.next,
                    errorText: passwordError,
                    onTogglePasswordVisibility: () =>
                        ref.read(authProvider.notifier).togglePasswordVisibility(),
                    onChanged: (v) => ref.read(authProvider.notifier).setPassword(v),
                  ),
                  RSizedBox(height: 16),
                  AuthTextField(
                    label: StringsManager.confirmPassword,
                    hintText: StringsManager.reEnterPasswordHint,
                    prefixIcon: Icons.lock_outline_rounded,
                    controller: _confirmPasswordController,
                    isPassword: true,
                    isPasswordVisible: isConfirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    errorText: confirmPasswordError,
                    onTogglePasswordVisibility: () =>
                        ref.read(authProvider.notifier).toggleConfirmPasswordVisibility(),
                    onChanged: (v) => ref.read(authProvider.notifier).setConfirmPassword(v),
                    onSubmitted: (_) => _onRegister(),
                  ),
                  RSizedBox(height: 24),
                  AuthPrimaryButton(
                    title: StringsManager.registerAndStartLearning,
                    icon: Icons.arrow_forward_rounded,
                    isLoading: isLoading,
                    onPressed: _onRegister,
                  ),
                  RSizedBox(height: 28),
                  const _SignUpFooter(),
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

class _SignUpFooter extends StatelessWidget {
  const _SignUpFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RegularText(
          StringsManager.alreadyHaveAccount,
          color: ThemeEnum.textSecond,
          fontSize: 13,
        ),
        RSizedBox(width: 4),
        GestureDetector(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.login.path);
            }
          },
          child: SemiBoldText(
            StringsManager.login,
            color: ThemeEnum.accent,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
