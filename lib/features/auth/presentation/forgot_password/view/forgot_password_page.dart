import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_logo_tile.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/primary_button_quiet.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_common_bits.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_scaffold.dart';
import 'package:algorithm_visualizer/features/auth/presentation/forgot_password/view_model/forgot_password_auth_provider.dart';
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

  void _onSendLink() async {
    final success = await ref.read(authForgotPasswordProvider.notifier).forgotPassword();
    if (success && mounted) {
      context.push(Routes.confirmationPassword.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authForgotPasswordProvider.select((s) => s.isLoading));
    final emailError = ref.watch(authForgotPasswordProvider.select((s) => s.emailError));
    final canResend = ref.watch(authForgotPasswordProvider.select((s) => s.canResend));
    final resendCountdown = ref.watch(authForgotPasswordProvider.select((s) => s.resendCountdown));

    ref.listen(
      authForgotPasswordProvider.select((s) => s.errorMessage),
      (previous, next) {
        if (next != null) context.showSnackBar(message: next, type: CustomSnackBarType.error);
      },
    );

    return AuthScaffold(
      topInset: CdSpace.x2,
      children: [
        AuthEyebrowRow(
          StringsManager.accountRecovery,
          onBack: () => context.canPop() ? context.back() : context.pushTo(Routes.login),
        ),
        SizedBox(height: CdSpace.x8.h),
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: AuthRecoveryTile(),
        ),
        SizedBox(height: CdSpace.x6.h),
        const AuthTitle(StringsManager.forgotPasswordTitle),
        SizedBox(height: CdSpace.x2.h),
        const AuthSubtitle(StringsManager.forgotPasswordSubtitle),
        SizedBox(height: CdSpace.x8.h),
        AuthTextField(
          label: StringsManager.registeredEmail,
          hintText: StringsManager.emailHint,
          prefixIcon: Icons.mail_outline_rounded,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          helperText: StringsManager.codeExpiryNote,
          errorText: emailError,
          onChanged: (v) => ref.read(authForgotPasswordProvider.notifier).setEmail(v),
          onSubmitted: (_) => _onSendLink(),
        ),
        SizedBox(height: CdSpace.x16.h),
        PrimaryButtonQuiet(
          label: canResend
              ? StringsManager.sendLink
              : "${StringsManager.sendLink.tr(context)} (${resendCountdown}s)",
          loading: isLoading,
          onPressed: canResend ? _onSendLink : null,
        ),
        SizedBox(height: CdSpace.x6.h),
        const AuthReturnLink(StringsManager.returnToSignIn),
      ],
    );
  }
}
