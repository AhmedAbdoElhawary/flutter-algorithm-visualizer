import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_difficulty_progress.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_difficulty_progress.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/screen_matrix.dart';
import 'home_test_problems.dart';

void main() {
  for (final solved in [false, true]) {
    testScreenMatrix('renders the difficulty progress, solved: $solved', (tester, variant) async {
      await pumpApp(
        tester,
        const HomeDifficultyProgress(),
        overrides: [
          problemsOverride([
            if (solved) ...[
              submitted(1, ago: Duration.zero, solved: true, difficulty: ProblemDifficulty.easy),
              submitted(2, ago: Duration.zero, solved: true, difficulty: ProblemDifficulty.medium),
              submitted(3, ago: Duration.zero, solved: true, difficulty: ProblemDifficulty.hard),
            ],
          ]),
        ],
        screen: variant.screen,
        theme: variant.theme,
        textScale: variant.textScale,
      );

      expect(find.byType(ProfileDifficultyProgress), findsOneWidget);
    });
  }
}
