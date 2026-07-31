import 'package:algorithm_visualizer/features/searching/helper/searching_state.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_model/searching_notifier.dart';

class SpeedSelector extends ConsumerWidget {
  const SpeedSelector({required this.instance, super.key});
  final StateNotifierProvider<SearchingNotifier, SearchingState> instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(instance.select((s) => s.speed));
    final notifier = ref.read(instance.notifier);

    return Container(
      padding: REdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: context.cardDecoration(),
      child: GestureDetector(
        onTap: () => notifier.setNextSpeed(speed),
        child: Container(
          width: 22.r,
          height: 22.r,
          decoration: BoxDecoration(
            color: context.accentBg,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              '${speed.level}×',
              style: GoogleFonts.inter(
                color: context.accent,
                fontSize: 10.r,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
