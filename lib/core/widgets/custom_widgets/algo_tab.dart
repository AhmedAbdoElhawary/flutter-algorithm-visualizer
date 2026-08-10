import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AlgoTab extends ConsumerWidget {
  const AlgoTab({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.addEndPadding,
    this.verticalPadding = 0,
    super.key,
  });
  final String label;
  final bool isSelected;
  final bool addEndPadding;
  final IconData? icon;
  final double verticalPadding;
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
        padding: REdgeInsets.symmetric(horizontal: 10,vertical: verticalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon!,color: isSelected ? context.accent : context.textMuted,size: 20.r), RSizedBox(width: 5)],
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                color: isSelected ? context.accent : context.textMuted,
                fontSize: 13.r,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
