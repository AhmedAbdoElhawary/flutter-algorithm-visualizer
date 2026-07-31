import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PFLegend extends StatelessWidget {
  const PFLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (context.accentGreen, 'Start'),
      (context.accentRed, 'End'),
      (context.isDark ? const Color(0xFF1A2540) : const Color(0xFF334155), 'Wall'),
      (context.accentYellow.withValues(alpha: 0.55), 'Visited'),
      (context.accentBlue.withValues(alpha: 0.70), 'Frontier'),
      (context.accent, 'Path'),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Wrap(
          spacing: 12,
          runSpacing: 4,
          children: items.map((item) {
            final (color, label) = item;
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 4),
              Text(label, style: GoogleFonts.inter(color: context.textMuted, fontSize: 10)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
