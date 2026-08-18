import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_difficulty_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeDifficultyProgress extends ConsumerWidget {
  const HomeDifficultyProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnlyPadding(
      bottomPadding: 14,
      child: ProfileDifficultyProgress(titleColor: ThemeEnum.textPrimary),
    );
  }
}
