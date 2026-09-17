import 'dart:async';

import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/animated_popup.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/primary_button_quiet.dart';
import 'package:algorithm_visualizer/features/challenge/domain/services/problem_sync_service.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileSyncButton extends ConsumerWidget {
  const ProfileSyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(isSignedInProvider);

    if (!isSignedIn) return const SizedBox.shrink();

    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [_SyncAction(), RSizedBox(width: 6)],
    );
  }
}

class _SyncAction extends ConsumerWidget {
  const _SyncAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = ref.watch(problemSyncProvider.select((state) => state.isSyncing));
    final hasPendingChanges = ref.watch(problemSyncProvider.select((state) => state.hasPendingChanges));

    return Semantics(
      button: true,
      label: StringsManager.syncNow.tr(context),
      child: GestureDetector(
        onTap: isSyncing ? null : () => _onTap(context, ref),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            isSyncing
                ? const _SyncSpinner()
                : const IconButtonQuiet(
                    icon: Icons.cloud_sync_outlined,
                    iconColor: ThemeEnum.inkBody,
                    borderColor: ThemeEnum.inkBody,
                    size: 36,
                    iconSize: 18,
                  ),

            if (hasPendingChanges && !isSyncing) const _PendingDot(),
          ],
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(problemSyncProvider.notifier);

    final remaining = notifier.remainingCooldown;
    if (remaining > Duration.zero) {
      AnimatedPopup.show(
        context,
        builder: (removeOverlay) => _SyncCooldownCard(
          initialRemaining: remaining,
          onDismiss: removeOverlay,
        ),
      );
      return;
    }

    final result = await notifier.sync();

    if (!context.mounted) return;

    switch (result) {
      case ProblemSyncResult.success:
        context.showSnackBar(
          message: StringsManager.syncSuccess.tr(context),
          type: CustomSnackBarType.success,
        );
      case ProblemSyncResult.failure:
        context.showSnackBar(
          message: StringsManager.syncFailure.tr(context),
          type: CustomSnackBarType.error,
        );

      case ProblemSyncResult.cooldown:
      case ProblemSyncResult.notSignedIn:
        break;
    }
  }
}

class _SyncSpinner extends StatelessWidget {
  const _SyncSpinner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.r,
      height: 36.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.getColor(ThemeEnum.inkBody)),
      ),
      child: SizedBox(
        width: 16.r,
        height: 16.r,
        child: CircularProgressIndicator(
          strokeWidth: 2.r,
          color: context.getColor(ThemeEnum.inkPrimary),
        ),
      ),
    );
  }
}

class _PendingDot extends StatelessWidget {
  const _PendingDot();

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: -4.r,
      end: -4.r,
      child: Container(
        width: 13.r,
        height: 13.r,
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.dataMedium),
          shape: BoxShape.circle,

          border: Border.all(color: context.getColor(ThemeEnum.ground), width: 2.r),
        ),
      ),
    );
  }
}

class _SyncCooldownCard extends StatefulWidget {
  const _SyncCooldownCard({required this.initialRemaining, required this.onDismiss});

  final Duration initialRemaining;
  final VoidCallback onDismiss;

  @override
  State<_SyncCooldownCard> createState() => _SyncCooldownCardState();
}

class _SyncCooldownCardState extends State<_SyncCooldownCard> {
  late int _seconds = widget.initialRemaining.inSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() => _seconds = _seconds > 0 ? _seconds - 1 : 0);

      if (_seconds == 0) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CardContainer(
        radius: CdRadius.dialog,
        padding: REdgeInsets.all(16),
        child: SizedBox(
          width: ScreenUtil().screenWidth - 67.r,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.getColor(ThemeEnum.raised),
                  shape: BoxShape.circle,
                ),
                child: const CustomIcon(
                  Icons.hourglass_bottom_rounded,
                  size: 24,
                  color: ThemeEnum.dataMedium,
                ),
              ),
              const RSizedBox(height: 14),
              const BoldText(
                StringsManager.syncCooldownTitle,
                color: ThemeEnum.inkTitle,
                fontSize: 16,
                fontWeight: FontWeightManager.bold800,
                textAlign: TextAlign.center,
              ),
              const RSizedBox(height: 6),
              RegularText(
                StringsManager.syncCooldownDesc(_seconds, tr: (source) => source.tr(context)),
                translate: false,
                color: ThemeEnum.inkBody,
                fontSize: 12,
                textAlign: TextAlign.center,
              ),
              const RSizedBox(height: 20),
              PrimaryButtonQuiet(
                label: StringsManager.syncCooldownConfirm,
                onPressed: widget.onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
