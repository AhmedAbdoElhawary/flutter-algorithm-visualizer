import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/primary_button_quiet.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_common_bits.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_scaffold.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/password_strength_meter.dart';
import 'package:algorithm_visualizer/features/auth/presentation/signup/view_model/signup_auth_providers.dart';
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
  void initState() {
    super.initState();

    /// Carry over the name the user already picked while browsing as a guest,
    /// so they are not asked for it twice. The signup state outlives this page,
    /// so a name typed on an earlier visit wins over the guest one.
    final typedName = ref.read(authSignupProvider).name;
    if (typedName.trim().isNotEmpty) {
      _nameController.text = typedName;
      return;
    }

    final guestName = ref.read(guestDataServiceProvider).guestName;
    if (guestName == null) return;

    _nameController.text = guestName;

    /// Push the seeded name into signup state after this build pass: go_router
    /// builds the page inside a layout callback, and mutating a provider there
    /// is disallowed by Riverpod.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(authSignupProvider.notifier).setName(guestName);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    final success = await ref.read(authSignupProvider.notifier).register();
    if (success && mounted) context.go(Routes.home.path);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authSignupProvider.select((s) => s.isLoading));
    final nameError = ref.watch(authSignupProvider.select((s) => s.nameError));
    final emailError = ref.watch(authSignupProvider.select((s) => s.emailError));

    ref.listen(
      authSignupProvider.select((s) => s.errorMessage),
      (previous, next) {
        if (next != null) context.showSnackBar(message: next, type: CustomSnackBarType.error);
      },
    );

    return AuthScaffold(
      topInset: CdSpace.x6,
      children: [
        const AuthTitle(StringsManager.createAccount),
        SizedBox(height: CdSpace.x2.h),
        const AuthSubtitle(StringsManager.signUpSubtitle),
        SizedBox(height: CdSpace.x6.h),
        AuthTextField(
          label: StringsManager.fullName,
          hintText: StringsManager.fullNameHint,
          prefixIcon: Icons.person_outline_rounded,
          controller: _nameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          errorText: nameError,
          onChanged: (v) => ref.read(authSignupProvider.notifier).setName(v),
        ),
        SizedBox(height: CdSpace.gapCard.h),
        AuthTextField(
          label: StringsManager.emailAddress,
          hintText: StringsManager.emailHint,
          prefixIcon: Icons.mail_outline_rounded,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: emailError,
          onChanged: (v) => ref.read(authSignupProvider.notifier).setEmail(v),
        ),
        SizedBox(height: CdSpace.gapCard.h),
        _PasswordField(controller: _passwordController),
        SizedBox(height: CdSpace.gapCard.h),
        _ConfirmPasswordField(controller: _confirmPasswordController),
        SizedBox(height: CdSpace.x6.h),
        PrimaryButtonQuiet(
          label: StringsManager.createAccount,
          loading: isLoading,
          onPressed: _onRegister,
        ),
        SizedBox(height: CdSpace.x4.h),
        AuthFooterPrompt(
          prompt: StringsManager.alreadyHaveAccount,
          action: StringsManager.signIn,
          onTap: () => context.canPop() ? context.pop() : context.go(Routes.login.path),
        ),
      ],
    );
  }
}

class _PasswordField extends ConsumerStatefulWidget {
  const _PasswordField({required this.controller});

  final TextEditingController controller;

  @override
  ConsumerState<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends ConsumerState<_PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final passwordError = ref.watch(authSignupProvider.select((s) => s.passwordError));
    final password = ref.watch(authSignupProvider.select((s) => s.password));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          label: StringsManager.password,
          hintText: StringsManager.createStrongPasswordHint,
          prefixIcon: Icons.lock_outline_rounded,
          controller: widget.controller,
          isPassword: true,
          isPasswordVisible: _visible,
          textInputAction: TextInputAction.next,
          errorText: passwordError,
          onTogglePasswordVisibility: () => setState(() => _visible = !_visible),
          onChanged: (v) => ref.read(authSignupProvider.notifier).setPassword(v),
        ),
        if (passwordError == null || passwordError.isEmpty) PasswordStrengthMeter(password: password),
      ],
    );
  }
}

class _ConfirmPasswordField extends ConsumerStatefulWidget {
  const _ConfirmPasswordField({required this.controller});

  final TextEditingController controller;

  @override
  ConsumerState<_ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends ConsumerState<_ConfirmPasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final confirmPasswordError = ref.watch(authSignupProvider.select((s) => s.confirmPasswordError));

    return AuthTextField(
      label: StringsManager.confirmPassword,
      hintText: StringsManager.reEnterPasswordHint,
      prefixIcon: Icons.lock_outline_rounded,
      controller: widget.controller,
      isPassword: true,
      isPasswordVisible: _visible,
      textInputAction: TextInputAction.done,
      errorText: confirmPasswordError,
      onTogglePasswordVisibility: () => setState(() => _visible = !_visible),
      onChanged: (v) => ref.read(authSignupProvider.notifier).setConfirmPassword(v),
    );
  }
}
