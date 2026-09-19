import 'dart:async';
import 'dart:math' as math;

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
import 'package:algorithm_visualizer/features/profile/presentation/view_model/sync_hint_store.dart';
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

class _SyncAction extends ConsumerStatefulWidget {
  const _SyncAction();

  @override
  ConsumerState<_SyncAction> createState() => _SyncActionState();
}

class _SyncActionState extends ConsumerState<_SyncAction> {
  /// How long the tag stays up before it fades out on its own.
  static const Duration _tagDuration = Duration(seconds: 10);

  late bool _hintActive = !ref.watch(syncHintStoreProvider).isSeen;
  late bool _tagVisible = _hintActive;
  Timer? _tagTimer;

  /// The tag lives in the root overlay so it floats over the stats grid below
  /// the header instead of being painted under it. [_link] keeps it pinned to
  /// the button.
  final LayerLink _link = LayerLink();
  final OverlayPortalController _tagPortal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    if (!_hintActive) return;

    _tagPortal.show();

    _tagTimer = Timer(_tagDuration, () {
      if (!mounted) return;

      setState(() => _tagVisible = false);
      // The tag had its five seconds, so the hint counts as delivered even if
      // the spinning border keeps running until the button is tapped.
      ref.read(syncHintStoreProvider).markSeen();
    });
  }

  @override
  void dispose() {
    _tagTimer?.cancel();
    super.dispose();
  }

  void _dismissHint() {
    _tagTimer?.cancel();
    if (_hintActive) ref.read(syncHintStoreProvider).markSeen();

    setState(() {
      _hintActive = false;
      _tagVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSyncing = ref.watch(problemSyncProvider.select((state) => state.isSyncing));
    final hasUnsyncedChanges = ref.watch(problemSyncProvider.select((state) => state.hasUnsyncedChanges));

    return Semantics(
      button: true,
      label: StringsManager.syncNow.tr(context),
      child: GestureDetector(
        onTap: isSyncing ? null : () => _onTap(context, ref),
        child: CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(
            controller: _tagPortal,
            overlayChildBuilder: _buildTag,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                isSyncing
                    ? const _SyncSpinner()
                    : const IconButtonQuiet(
                        icon: Icons.sync_rounded,
                        iconColor: ThemeEnum.inkSecondaryTitle,
                        borderColor: ThemeEnum.inkSecondaryTitle,
                        size: 36,
                        iconSize: 18,
                      ),
                if (_hintActive && !isSyncing) const _ShimmerBorder(size: 36),
                if (hasUnsyncedChanges && !isSyncing) const _UnsyncedDot(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context) {
    return CompositedTransformFollower(
      link: _link,
      targetAnchor: Alignment.bottomCenter,
      followerAnchor: Alignment.topCenter,
      offset: Offset(0, 6.r),
      child: SizedBox(
        width: 170.r,
        child: Align(
          alignment: Alignment.topCenter,
          child: _SyncHintTag(visible: _tagVisible, onHidden: _tagPortal.hide),
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    if (_hintActive) _dismissHint();

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
        border: Border.all(color: context.getColor(ThemeEnum.inkSecondaryTitle)),
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

class _UnsyncedDot extends StatelessWidget {
  const _UnsyncedDot();

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: -3.r,
      end: -3.r,
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
                color: ThemeEnum.inkSecondaryTitle,
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

class _ShimmerBorder extends StatefulWidget {
  const _ShimmerBorder({required this.size});

  final double size;

  @override
  State<_ShimmerBorder> createState() => _ShimmerBorderState();
}

class _ShimmerBorderState extends State<_ShimmerBorder> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          size: Size(widget.size.r, widget.size.r),
          painter: _ShimmerBorderPainter(
            turns: _controller.value,
            ring: context.getColor(ThemeEnum.dataMedium).withValues(alpha: 0.65),
            head: context.getColor(ThemeEnum.dataMedium),
            radius: 10.r,
            strokeWidth: 2.r,
          ),
        ),
      ),
    );
  }
}

class _ShimmerBorderPainter extends CustomPainter {
  const _ShimmerBorderPainter({
    required this.turns,
    required this.ring,
    required this.head,
    required this.radius,
    required this.strokeWidth,
  });

  final double turns;
  final Color ring;
  final Color head;
  final double radius;
  final double strokeWidth;

  static const List<double> _stops = <double>[0, 0.5, 0.8, 0.86, 1];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(strokeWidth / 2);
    final rrect = RRect.fromRectAndRadius(inset, Radius.circular(radius));

    final shader = SweepGradient(
      colors: <Color>[ring, ring, head, ring, ring],
      stops: _stops,
      transform: GradientRotation(turns * 2 * math.pi),
    ).createShader(rect);

    // Same ring drawn twice: a blurred pass so the head carries a halo, a crisp
    // one on top so the outline itself stays sharp.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader = shader
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 1.6),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_ShimmerBorderPainter oldDelegate) =>
      oldDelegate.turns != turns || oldDelegate.head != head || oldDelegate.ring != ring;
}

class _SyncHintTag extends StatefulWidget {
  const _SyncHintTag({required this.visible, required this.onHidden});

  final bool visible;

  final VoidCallback onHidden;

  @override
  State<_SyncHintTag> createState() => _SyncHintTagState();
}

class _SyncHintTagState extends State<_SyncHintTag> {
  static const Duration _duration = Duration(milliseconds: 260);

  bool _entered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _entered = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final shown = _entered && widget.visible;

    return IgnorePointer(
      child: AnimatedScale(
        scale: shown ? 1 : 0.8,
        duration: _duration,
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: shown ? 1 : 0,
          duration: _duration,
          onEnd: () {
            if (!widget.visible) widget.onHidden();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: Size(12.r, 6.r),
                painter: _TagArrowPainter(
                  fill: context.getColor(ThemeEnum.raised),
                  border: context.getColor(ThemeEnum.hairline),
                ),
              ),
              CardContainer(
                surface: CdSurface.secondary,
                radius: CdRadius.smAlt,
                padding: REdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: const MediumText(
                  StringsManager.syncHint,
                  color: ThemeEnum.inkTitle,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagArrowPainter extends CustomPainter {
  const _TagArrowPainter({required this.fill, required this.border});

  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = border,
    );
  }

  @override
  bool shouldRepaint(_TagArrowPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.border != border;
}
