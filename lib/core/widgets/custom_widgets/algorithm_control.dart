import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/segmented_control_quiet.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_control_interface.dart';
import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlgorithmControls extends ConsumerWidget {
  const AlgorithmControls({
    required this.interface,
    required this.backwardValidation,
    required this.forwardValidation,
    required this.isPlaying,
    required this.getSpeed,
    this.expandSpeedEscalator = false,
    this.endOptionButtons = const [],
    super.key,
  });
  final AlgorithmControlInterface interface;
  final List<CtrlButton> endOptionButtons;
  final bool expandSpeedEscalator;
  final bool backwardValidation;
  final bool forwardValidation;
  final bool isPlaying;
  final PlaybackSpeed getSpeed;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double width = expandSpeedEscalator ? 8 : 6;
    final double iconSize = expandSpeedEscalator ? 20 : 18;

    return Padding(
      padding: REdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CtrlButton(icon: Icons.restart_alt_rounded, size: iconSize, onTap: interface.reset),
              RSizedBox(width: width),
              CtrlButton(
                icon: Icons.skip_previous_rounded,
                size: iconSize,
                onTap: backwardValidation ? interface.stepBackward : null,
              ),
              RSizedBox(width: width),
              _PlayButton(playing: isPlaying, onTap: interface.togglePlay),
              RSizedBox(width: width),
              CtrlButton(
                icon: Icons.skip_next_rounded,
                size: iconSize,
                onTap: forwardValidation ? interface.stepForward : null,
              ),
              RSizedBox(width: width),
              ...endOptionButtons.map(
                (button) => Padding(
                  padding: REdgeInsetsDirectional.only(end: width),
                  child: button,
                ),
              ),
              SpeedSelector(
                  interface: interface, getSpeed: getSpeed, expandSpeedEscalator: expandSpeedEscalator),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool playing;
  final Future<void> Function() onTap;
  const _PlayButton({required this.playing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButtonQuiet(
      icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
      onTap: onTap,
      size: 44,
      iconSize: 22,
      filled: true,
    );
  }
}

class CtrlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? messageTip;
  final double size;
  const CtrlButton({super.key, required this.icon, required this.onTap, this.size = 22, this.messageTip});

  @override
  Widget build(BuildContext context) {
    final button = IconButtonQuiet(icon: icon, onTap: onTap, size: 36, iconSize: size);
    return messageTip != null ? Tooltip(message: messageTip!, child: button) : button;
  }
}

class SpeedSelector extends ConsumerWidget {
  const SpeedSelector({
    required this.interface,
    required this.expandSpeedEscalator,
    required this.getSpeed,
    super.key,
  });
  final AlgorithmControlInterface interface;
  final PlaybackSpeed getSpeed;
  final bool expandSpeedEscalator;

  List<PlaybackSpeed> getPlaybackSpeedsForSorting() => [
        PlaybackSpeed.slow,
        PlaybackSpeed.normal,
        PlaybackSpeed.fast3,
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speeds = expandSpeedEscalator ? getPlaybackSpeedsForSorting() : [getSpeed];
    final selectedIndex = speeds.indexOf(getSpeed).clamp(0, speeds.length - 1);

    return SegmentedControlQuiet(
      labels: speeds.map((e) => '${e.level}×').toList(),
      selectedIndex: selectedIndex,
      onChanged: (i) => interface.changeSpeed(speeds[i]),
    );
  }
}
