import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_common_bits.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_logo_tile.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_scaffold.dart';
import 'package:algorithm_visualizer/features/auth/presentation/forgot_password/view_model/forgot_password_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ConfirmationPasswordPage extends ConsumerStatefulWidget {
  const ConfirmationPasswordPage({super.key});

  @override
  ConsumerState<ConfirmationPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ConfirmationPasswordPage> {
  @override
  Widget build(BuildContext context) {
    ref.listen(
      authForgotPasswordProvider.select((s) => s.errorMessage),
      (previous, next) {
        if (next != null) {
          context.showSnackBar(message: next, type: CustomSnackBarType.error);
        }
      },
    );

    return AuthScaffold(
      topInset: CdSpace.x2,
      children: [
        AuthEyebrowRow(
          StringsManager.accountRecovery,
          onBack: () => context.canPop() ? context.back() : context.pushTo(Routes.login),
        ),
        const RSizedBox(height: CdSpace.x8),
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: AuthRecoveryTile(icon: Icons.mark_email_read_outlined),
        ),
        const RSizedBox(height: CdSpace.x6),
        const AuthTitle(StringsManager.checkEmail),
        const RSizedBox(height: CdSpace.x2),
        Consumer(
          builder: (context, ref, child) {
            final email = ref.watch(authForgotPasswordProvider.select((value) => value.email));

            return AuthCombineSubtitle(
              text: StringsManager.weSendToYourEmailPart1Subtitle,
              highlightedText: email,
              secondText: StringsManager.weSendToYourEmailPart2Subtitle,
            );
          },
        ),
        const RSizedBox(height: CdSpace.x8),
        Consumer(
          builder: (context, ref, child) {
            final countdown = ref.watch(authForgotPasswordProvider.select((s) => s.resendCountdown));

            return CardContainer(
              child: AuthCombineSubtitle(
                text: StringsManager.noteReceiveTheLinkDescription,
                highlightedText: "${countdown}s",
                secondText: "",
                fontSize: 11,
              ),
            );
          },
        ),
        const RSizedBox(height: CdSpace.x8),
        Consumer(
          builder: (context, ref, child) {
            final canResend = ref.watch(authForgotPasswordProvider.select((s) => s.canResend));

            return GestureDetector(
              onTap: canResend ? () => ref.read(authForgotPasswordProvider.notifier).resendEmail() : null,
              child: Center(
                child: MediumText(
                  StringsManager.resendEmailLink,
                  color: canResend ? ThemeEnum.inkTitle : ThemeEnum.inkThirdTitle,
                  fontSize: 14,
                  maxLines: 1,
                ),
              ),
            );
          },
        ),
        const RSizedBox(height: CdSpace.x4),
        const AuthReturnLink(StringsManager.returnToSignIn),
      ],
    );
  }
}
