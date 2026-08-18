import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
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
  final Future<void> Function(BuildContext context) onTap;
  const _PlayButton({required this.playing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => await onTap(context),
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              context.getColor(ThemeEnum.accent),
              ColorManager.pinkColor,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: context.getColor(ThemeEnum.accent).withValues(alpha: 0.25),
              blurRadius: 1,
              spreadRadius: 0.4,
              offset: const Offset(0, 0),
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

class CtrlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? messageTip;
  final double size;
  const CtrlButton({super.key, required this.icon, required this.onTap, this.size = 20, this.messageTip});

  bool get _disabled => onTap == null;

  @override
  Widget build(BuildContext context) {
    return SimpleGlassButton(
      onTap: onTap,
      messageTip: messageTip,
      child: Icon(icon,
          size: size.r,
          color:
              _disabled ? context.getColor(ThemeEnum.hoverSecond) : context.getColor(ThemeEnum.textSecond)),
    );
  }
}

class SpeedSelector extends ConsumerWidget {
  const SpeedSelector(
      {required this.interface, required this.expandSpeedEscalator, required this.getSpeed, super.key});
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
    return SimpleGlassButton(
      padding: 7,
      child: expandSpeedEscalator
          ? Row(
              children: getPlaybackSpeedsForSorting()
                  .map((e) => Padding(
                        padding: REdgeInsetsDirectional.only(end: 5),
                        child: _BuildChildForSpeedSelector(
                            interface: interface,
                            selectedSpeed: getSpeed,
                            speed: e,
                            onTap: () => interface.changeSpeed(e)),
                      ))
                  .toList(),
            )
          : _BuildChildForSpeedSelector(
              interface: interface,
              selectedSpeed: getSpeed,
              speed: getSpeed,
              onTap: () => interface.changeSpeed(getSpeed)),
    );
  }
}

class _BuildChildForSpeedSelector extends StatelessWidget {
  const _BuildChildForSpeedSelector({
    required this.interface,
    required this.selectedSpeed,
    required this.speed,
    this.onTap,
  });

  final AlgorithmControlInterface interface;
  final PlaybackSpeed selectedSpeed;
  final PlaybackSpeed speed;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 22.r,
        height: 22.r,
        decoration: speed != selectedSpeed
            ? null
            : BoxDecoration(
                color: context.getColor(ThemeEnum.accentBg),
                borderRadius: BorderRadius.circular(5),
              ),
        child: Center(
          child: MediumText(
            '${speed.level}×',
            color: speed != selectedSpeed ? ThemeEnum.textDarkColor : ThemeEnum.accent,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
