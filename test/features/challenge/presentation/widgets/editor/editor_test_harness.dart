import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';

/// Pumps one editor piece with [problem] loaded.
Future<ProviderContainer> pumpEditorPiece(
  WidgetTester tester,
  Widget piece,
  CodingProblem problem, {
  ScreenSize screen = ScreenSize.phone,
  double textScale = 1.0,
}) async {
  final container = await pumpApp(
    tester,
    Scaffold(body: SafeArea(child: piece)),
    overrides: [problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data([problem]))],
    screen: screen,
    textScale: textScale,
  );
  await tester.pumpAndSettle();
  return container;
}
