import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_problem_repository.dart';
import '../../../../../helpers/pump_app.dart';

/// Pumps one piece of the challenges list with [problems] loaded, keeping the list's own state alive.
Future<({ProviderContainer container, FakeProblemRepository repository})> pumpListPiece(
  WidgetTester tester,
  Widget piece, {
  List<CodingProblem> problems = const [],
  ScreenSize screen = ScreenSize.phone,
  double textScale = 1.0,
}) async {
  final repository = FakeProblemRepository();
  final container = await pumpApp(
    tester,
    Scaffold(body: SingleChildScrollView(child: piece)),
    overrides: [
      problemRepositoryProvider.overrideWithValue(repository),
      problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data(problems)),
    ],
    screen: screen,
    textScale: textScale,
  );
  container.listen(challengesProvider, (previous, next) {});
  await tester.pumpAndSettle();
  return (container: container, repository: repository);
}
