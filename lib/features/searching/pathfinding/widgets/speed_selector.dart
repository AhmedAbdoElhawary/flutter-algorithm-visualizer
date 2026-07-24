import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/searching_state.dart';
import '../providers/searching_notifier.dart';

class SpeedSelector extends ConsumerWidget {
  const SpeedSelector({required this.instance,super.key});
  final StateNotifierProvider<SearchingNotifier, SearchingState> instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(instance.select((s) => s.speed));
    final notifier = ref.read(instance.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: context.cardDecoration(),
      child: Row(
        children: PlaybackSpeed.values.map((s) {
          final isSelected = speed == s;
          return GestureDetector(
            onTap: () => notifier.setSpeed(s),
            child: Container(
              width: 22,
              height: 22,
              margin: EdgeInsets.only(right: s != PlaybackSpeed.fast ? 2 : 0),
              decoration: BoxDecoration(
                color: isSelected ? context.accentBg : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  '${s.level}×',
                  style: GoogleFonts.inter(
                    color: isSelected ? context.accent : context.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
