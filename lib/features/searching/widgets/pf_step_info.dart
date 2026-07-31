import 'package:algorithm_visualizer/features/searching/helper/searching_state.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_model/searching_notifier.dart';

class PFStepInfo extends ConsumerWidget {
  const PFStepInfo({required this.instance,super.key});
  final StateNotifierProvider<SearchingNotifier, SearchingState> instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(instance);
    final step = state.currentStep;
    final description = step?.description ?? 'Tap or drag cells to draw walls, then press ▶ Run';
    final total = state.steps?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: context.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: GoogleFonts.jetBrainsMono(color: context.textSec, fontSize: 12)),
            if (state.hasSteps) ...[
              const SizedBox(height: 4),
              Text(
                'Step ${state.stepIndex + 1} of $total',
                style: GoogleFonts.inter(color: context.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: total > 1 ? state.stepIndex / (total - 1) : 0,
                  minHeight: 3,
                  backgroundColor: context.bgElevated,
                  valueColor: AlwaysStoppedAnimation(context.accent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
