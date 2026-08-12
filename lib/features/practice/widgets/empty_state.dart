import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ChallengesEmptyState extends StatelessWidget {
  const ChallengesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: REdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RegularText('🔍', fontSize: 40),
            const RSizedBox(height: 12),
            Text(
              'No problems found',
              style: GoogleFonts.inter(color: context.getColor(ThemeEnum.textSecond), fontSize: 15.r, fontWeight: FontWeight.w600),
            ),
            const RSizedBox(height: 4),
            Text('Try a different search or filter',
                style: GoogleFonts.inter(color: context.getColor(ThemeEnum.hover), fontSize: 13.r)),
          ],
        ),
      ),
    );
  }
}
