import 'package:algorithm_visualizer/features/searching/pathfinding/models/searching_state.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/searching_notifier.dart';
import 'ctrl_btn.dart';
import 'speed_selector.dart';

class c extends ConsumerWidget {
  const PFControls({required this.instance,super.key});
  final StateNotifierProvider<SearchingNotifier, SearchingState> instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(instance);
    final notifier = ref.read(instance.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CtrlBtn(icon: Icons.restart_alt_rounded, onTap: notifier.reset),
          const SizedBox(width: 8),
          CtrlBtn(
            icon: Icons.skip_previous_rounded,
            onTap: (state.hasSteps && !state.isAtStart) ? notifier.stepBackward : null,
          ),
          const SizedBox(width: 8),
          _PlayButton(playing: state.playing, onTap: notifier.togglePlay),
          const SizedBox(width: 8),
          CtrlBtn(
            icon: Icons.skip_next_rounded,
            onTap: (state.hasSteps && !state.isAtEnd) ? notifier.stepForward : null,
          ),
          const SizedBox(width: 8),
          CtrlBtn(icon: Icons.grid_off_rounded, onTap: notifier.clearWalls, tooltip: 'Clear walls'),
          const SizedBox(width: 8),
          CtrlBtn(icon: Icons.shuffle_rounded, onTap: notifier.randomizeWalls, tooltip: 'Random walls'),
          const SizedBox(width: 8),
           SpeedSelector(instance:instance),
        ],
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
        width: 52,
        height: 52,
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
          size: 24,
        ),
      ),
    );
  }
}
