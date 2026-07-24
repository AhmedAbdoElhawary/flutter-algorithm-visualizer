import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplexityBadges extends StatelessWidget {
  const ComplexityBadges({super.key});

  static const _time = 'O(V+E)';
  static const _space = 'O(V)';
  static const _type = 'Graph';

  @override
  Widget build(BuildContext context) {
    final badges = [
      ('Time', _time, context.accent),
      ('Space', _space, context.accentGreen),
      ('Type', _type, context.accentBlue),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          for (final (label, value, color) in badges)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: context.cardDecoration(),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('$label: ', style: GoogleFonts.inter(color: context.textMuted, fontSize: 12)),
                Text(value,
                    style: GoogleFonts.jetBrainsMono(
                        color: color, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
        ],
      ),
    );
  }
}
