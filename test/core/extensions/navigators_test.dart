import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view/login_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/signup/view/sign_up_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/challenge_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';

void main() {
  /// Some pages keep a spinner or a looping hint going, so this waits a fixed time instead of settling.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> openApp(WidgetTester tester, [String route = '/home']) async {
    await pumpApp(tester, const SizedBox(), initialRoute: route);
    await settle(tester);
  }

  BuildContext contextOf(WidgetTester tester, Type page) => tester.element(find.byType(page).last);

  List<ProblemPage> problemPages(WidgetTester tester) =>
      tester.widgetList<ProblemPage>(find.byType(ProblemPage, skipOffstage: false)).toList();

  testWidgets('pushTo opens the page on top, and back returns', (tester) async {
    await openApp(tester);

    contextOf(tester, HomePage).pushTo(Routes.login);
    await settle(tester);
    expect(find.byType(LoginPage), findsOneWidget);

    contextOf(tester, LoginPage).back();
    await settle(tester);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('back with nothing under it does nothing', (tester) async {
    await openApp(tester);

    contextOf(tester, HomePage).back();
    await settle(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pushTo closes the keyboard first', (tester) async {
    await openApp(tester, Routes.login.path);
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    final field = FocusManager.instance.primaryFocus!;
    expect(field.hasFocus, isTrue);

    contextOf(tester, LoginPage).pushTo(Routes.signUp);
    await settle(tester);

    expect(find.byType(SignUpPage), findsOneWidget);
    expect(field.hasFocus, isFalse);
  });

  testWidgets('goTo switches tab without stacking a page', (tester) async {
    await openApp(tester);

    contextOf(tester, HomePage).goTo(Routes.practice);
    await settle(tester);

    expect(find.byType(ChallengePage), findsOneWidget);
    expect(GoRouter.of(contextOf(tester, ChallengePage)).canPop(), isFalse);
  });

  testWidgets('pushAndRemoveAll leaves only the new page', (tester) async {
    await openApp(tester);
    contextOf(tester, HomePage).pushTo(Routes.login);
    await settle(tester);
    contextOf(tester, LoginPage).pushTo(Routes.signUp);
    await settle(tester);

    contextOf(tester, SignUpPage).pushAndRemoveAll(Routes.home);
    await settle(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(SignUpPage), findsNothing);
    expect(GoRouter.of(contextOf(tester, HomePage)).canPop(), isFalse);
  });

  group('pushProblem', () {
    testWidgets('from another tab, it moves to the problem tab and opens the problem there', (tester) async {
      await openApp(tester);

      contextOf(tester, HomePage).pushProblem('7');
      await settle(tester);

      expect(problemPages(tester).last.problemId, 7);
      expect(problemPages(tester).last.showBackButton, isTrue);
    });

    testWidgets('on the problem tab, it opens the problem on top', (tester) async {
      await openApp(tester, '${Routes.problem.path}?problem_id=3');

      contextOf(tester, ProblemPage).pushProblem('7');
      await settle(tester);

      expect(problemPages(tester).map((page) => page.problemId), [3, 7]);
    });

    testWidgets('the problem already open is not opened twice', (tester) async {
      await openApp(tester, '${Routes.problem.path}?problem_id=3');

      contextOf(tester, ProblemPage).pushProblem('3');
      await settle(tester);

      expect(problemPages(tester), hasLength(1));
    });
  });
}
