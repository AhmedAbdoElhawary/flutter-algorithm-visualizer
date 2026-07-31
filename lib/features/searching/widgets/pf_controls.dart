import 'package:algorithm_visualizer/features/searching/helper/searching_state.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view_model/searching_notifier.dart';
import 'ctrl_btn.dart';
import 'speed_selector.dart';

class PFControls extends ConsumerWidget {
  const PFControls({required this.instance, super.key});
  final StateNotifierProvider<SearchingNotifier, SearchingState> instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(instance);
    final notifier = ref.read(instance.notifier);

    return Padding(
      padding: REdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CtrlBtn(icon: Icons.restart_alt_rounded, onTap: notifier.reset),
              const RSizedBox(width: 8),
              CtrlBtn(
                icon: Icons.skip_previous_rounded,
                onTap: (state.hasSteps && !state.isAtStart) ? notifier.stepBackward : null,
              ),
              const RSizedBox(width: 8),
              _PlayButton(playing: state.playing, onTap: notifier.togglePlay),
              const RSizedBox(width: 8),
              CtrlBtn(
                icon: Icons.skip_next_rounded,
                onTap: (state.hasSteps && !state.isAtEnd) ? notifier.stepForward : null,
              ),
              const RSizedBox(width: 8),
              CtrlBtn(icon: Icons.grid_off_rounded, onTap: notifier.clearWalls, tooltip: 'Clear walls'),
              const RSizedBox(width: 8),
              CtrlBtn(icon: Icons.shuffle_rounded, onTap: notifier.randomizeWalls, tooltip: 'Random walls'),
              const RSizedBox(width: 8),
              SpeedSelector(instance: instance),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool playing;
  final VoidCallback onTap;
  const _PlayButton({required this.playing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: context.accentGradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.accent.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 26.r,
        ),
      ),
    );
  }
}
