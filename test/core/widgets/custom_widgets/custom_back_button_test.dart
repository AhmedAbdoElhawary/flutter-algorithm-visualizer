import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<GoRouter> pumpRouter(WidgetTester tester, {TextDirection direction = TextDirection.ltr}) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Scaffold(body: CustomBackButton())),
        GoRoute(
          path: '/inner',
          builder: (context, state) => const Scaffold(body: Center(child: CustomBackButton())),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(800, 600),
        builder: (context, child) => MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => Directionality(textDirection: direction, child: child!),
        ),
      ),
    );
    return router;
  }

  final arrow = find.byIcon(Icons.arrow_back_ios_new_rounded);

  testWidgets('with nothing to go back to, it is not shown', (tester) async {
    await pumpRouter(tester);

    expect(arrow, findsNothing);
  });

  testWidgets('on a pushed page, it goes back', (tester) async {
    final router = await pumpRouter(tester);
    router.push('/inner');
    await tester.pumpAndSettle();

    await tester.tap(arrow);
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/');
    expect(arrow, findsNothing);
  });

  testWidgets('in Arabic, the arrow points the other way', (tester) async {
    final router = await pumpRouter(tester, direction: TextDirection.rtl);
    router.push('/inner');
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(Icon), matching: find.byType(Transform)), findsOneWidget);
  });
}
