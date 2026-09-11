import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/bar_chart_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/quiet_progress_bar.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/surface_card.dart';
import 'package:algorithm_visualizer/features/visualize/view_model/live_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The live-session widget's three planned sizes. Only [home] is built —
/// **scope note (per `/speckit-analyze` finding U1, unresolved)**: `expanded`
/// (lock-screen) and `pill` are not wired anywhere; `research.md` R10
/// confirms `home` is the only size with an existing call site. Do not treat
/// [expanded] or [pill] as implemented until FR-017 is clarified.
enum LiveSessionSize { home, expanded, pill }

/// One widget, driven entirely by [liveSessionProvider] — it carries no
/// colour of its own. Renders nothing when no session is live.
class LiveSessionCard extends ConsumerWidget {
  final LiveSessionSize size;

  const LiveSessionCard({super.key, this.size = LiveSessionSize.home});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(liveSessionProvider);
    if (data == null) return const SizedBox.shrink();

    switch (size) {
      case LiveSessionSize.home:
        return _HomeLiveSessionCard(data: data);
      case LiveSessionSize.expanded:
      case LiveSessionSize.pill:
        // TODO(FR-017): expanded/pill sizes are unbuilt — it's unresolved
        // whether "expanded" means an in-app Flutter view or a native OS
        // widget extension. Resolve via /speckit-clarify before building.
        return const SizedBox.shrink();
    }
  }
}

class _HomeLiveSessionCard extends StatelessWidget {
  final LiveSessionData data;

  const _HomeLiveSessionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final elapsed = data.liveElapsed;
    final timer =
        '${elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}:${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PulsingDot(),
              RSizedBox(width: 6),
              MediumText(
                'LIVE',
                fontSize: 9.5,
                color: ThemeEnum.textBody,
              ),
              RSizedBox(width: 8),
              Expanded(
                child: SemiBoldText(data.algorithmName, fontSize: 12, color: ThemeEnum.textPrimary, maxLines: 1),
              ),
              RegularText(
                timer,
                fontSize: 11,
                color: ThemeEnum.textSecond,
                fontFamily: FontConstants.fontJetBrainsMono,
              ),
            ],
          ),
          RSizedBox(height: 10),
          SizedBox(
            height: 30.h,
            child: BarChartQuiet(
              compact: true,
              trackHeight: 30.h,
              gap: 2,
              bars: data.bars
                  .map((b) => BarChartBar(
                        value: b.fraction,
                        max: 1,
                        state: switch (b.state) {
                          LiveBarState.idle => BarState.idle,
                          LiveBarState.compared => BarState.comparing,
                          LiveBarState.sorted => BarState.sorted,
                        },
                      ))
                  .toList(),
            ),
          ),
          RSizedBox(height: 10),
          Row(
            children: [
              Expanded(child: QuietProgressBar(value: data.progress)),
              RSizedBox(width: 10),
              RegularText(
                '${data.currentStep} / ${data.totalSteps}',
                fontSize: 11,
                color: ThemeEnum.textSecond,
                fontFamily: FontConstants.fontJetBrainsMono,
              ),
              RSizedBox(width: 10),
              _PauseSquare(playing: data.isPlaying),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = reduceMotion ? 1.0 : Curves.easeInOut.transform(_controller.value);
        return Opacity(
          opacity: reduceMotion ? 1 : 0.5 + (t * 0.5),
          child: Transform.scale(
            scale: reduceMotion ? 1 : 0.85 + (t * 0.15),
            child: Container(
              width: 6.r,
              height: 6.r,
              decoration: BoxDecoration(
                color: context.getColor(ThemeEnum.textBright),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PauseSquare extends StatelessWidget {
  final bool playing;

  const _PauseSquare({required this.playing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26.r,
      height: 26.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.textBright),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
        size: 15.r,
        color: context.getColor(ThemeEnum.onPrimary),
      ),
    );
  }
}
