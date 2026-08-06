import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AlgoTab extends ConsumerWidget {
  const AlgoTab({required this.label, required this.isSelected, required this.addEndPadding, super.key});
  final String label;
  final bool isSelected;
  final bool addEndPadding;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: REdgeInsets.only(right: addEndPadding ? 8 : 0),
      padding: REdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? context.accentBg : context.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? context.borderAccent : context.borderColor,
        ),
      ),
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 10),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.jetBrainsMono(
            color: isSelected ? context.accent : context.textMuted,
            fontSize: 13.r,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
