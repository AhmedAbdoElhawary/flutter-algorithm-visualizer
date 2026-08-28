import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// no needed to over engineer and separate theme, just to be different than others view model, but it's clear and not complicated here
/// so, i didn't seperated it to provider and notifier
class HomeData {
  const HomeData({
    required this.greeting,
    required this.continueProblem,
  });

  final String greeting;
  final CodingProblem? continueProblem;
}

final homeDataProvider = Provider<HomeData>((ref) {
  final asyncProblems = ref.watch(problemsProvider);

  return asyncProblems.when(
    data: (problems) {
      final greeting = computeGreeting();
      final continueProblem = _findContinueProblem(problems);

      return HomeData(
        greeting: greeting,
        continueProblem: continueProblem,
      );
    },
    loading: () => HomeData(
      greeting: computeGreeting(),
      continueProblem: null,
    ),
    error: (_, __) => HomeData(
      greeting: computeGreeting(),
      continueProblem: null,
    ),
  );
});

String computeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return StringsManager.goodMorning;
  if (hour < 17) return StringsManager.goodAfternoon;
  return StringsManager.goodEvening;
}

CodingProblem? _findContinueProblem(List<CodingProblem> problems) {
  final attempted = problems.where((p) => !p.isSolved && p.getSolutionsStatus.isNotEmpty).toList();
  if (attempted.isNotEmpty) return attempted.first;

  final unsolved = problems.where((p) => !p.isSolved).toList();
  return unsolved.isNotEmpty ? unsolved.first : null;
}
