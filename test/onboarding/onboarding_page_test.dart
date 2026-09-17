import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/onboarding/view_model/onboarding_store.dart';
import 'package:algorithm_visualizer/features/onboarding/view/onboarding_page.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// The smallest screen the spec calls out (§6.1).
const Size _smallSurface = Size(360, 640);

class _InMemoryStorage implements LocalStorage {
  final Map<String, Object?> values = {};

  @override
  Future<void> write<T>(String key, T value) async => values[key] = value;

  @override
  T? read<T>(String key) => values[key] as T?;

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();

  @override
  bool has(String key) => values.containsKey(key);
}

/// `AppTheme.dark` / `AppTheme.light` call ScreenUtil, so they can only be
/// built once [ScreenUtilInit] has run — never in a top-level initializer.
enum _Theme { dark, light }

Future<_InMemoryStorage> _pumpOnboarding(
  WidgetTester tester, {
  required _Theme theme,
  Size surface = _smallSurface,
  bool disableAnimations = false,
}) async {
  // The view has to match the surface too, or ScreenUtil derives its scale
  // from the default 800x600 test view and every `.sp` comes out 2.2x too big.
  const devicePixelRatio = 3.0;
  await tester.binding.setSurfaceSize(surface);
  tester.view.physicalSize = surface * devicePixelRatio;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(() {
    tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final storage = _InMemoryStorage();

  final router = GoRouter(
    initialLocation: Routes.onboarding.path,
    routes: [
      GoRoute(
        path: Routes.onboarding.path,
        name: Routes.onboarding.name,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: Routes.home.path,
        name: Routes.home.name,
        builder: (context, state) => const Placeholder(key: ValueKey('home')),
      ),
      GoRoute(
        path: Routes.login.path,
        name: Routes.login.name,
        builder: (context, state) => const Placeholder(key: ValueKey('login')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [localStorageProvider.overrideWithValue(storage)],
      child: ScreenUtilInit(
        designSize: surface,
        builder: (context, _) => MediaQuery(
          data: MediaQueryData(size: surface, disableAnimations: disableAnimations),
          child: MaterialApp.router(
            theme: theme == _Theme.dark ? AppTheme.dark : AppTheme.light,
            routerConfig: router,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return storage;
}

/// Swipes to the next page and lets the page-change settle without waiting for
/// the looping visuals, which never settle by design.
Future<void> _swipe(WidgetTester tester) async {
  await tester.drag(find.byType(PageView), const Offset(-400, 0));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final theme in _Theme.values) {
    testWidgets('renders all four pages at 360x640 with no overflow — ${theme.name} theme', (tester) async {
      await _pumpOnboarding(tester, theme: theme);

      final headlines = [
        StringsManager.onboardingSeeItHeadline,
        StringsManager.onboardingExploreHeadline,
        StringsManager.onboardingWriteHeadline,
        StringsManager.onboardingTrackHeadline,
      ];

      for (var page = 0; page < headlines.length; page++) {
        // Let each visual run a little so its painters are exercised.
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 900));

        expect(find.text(headlines[page]), findsOneWidget, reason: 'page $page headline');
        expect(find.text(StringsManager.onboardingSkip), findsOneWidget,
            reason: 'Skip must stay visible on page $page');
        expect(tester.takeException(), isNull, reason: 'page $page must not overflow');

        if (page < headlines.length - 1) await _swipe(tester);
      }
    });
  }

  testWidgets('Skip records onboarding_seen and leaves for home', (tester) async {
    final storage = await _pumpOnboarding(tester, theme: _Theme.dark);

    await tester.tap(find.text(StringsManager.onboardingSkip));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(storage.read<bool>(OnboardingStore.seenKey), isTrue);
    expect(find.byKey(const ValueKey('home')), findsOneWidget);
  });

  testWidgets('the controls cross-fade during the swipe instead of swapping on arrival', (tester) async {
    await _pumpOnboarding(tester, theme: _Theme.dark, disableAnimations: true);

    for (var i = 0; i < 2; i++) {
      await _swipe(tester);
    }
    await tester.pump(const Duration(milliseconds: 400));

    // Page 3: Next owns the strip on its own.
    expect(find.text(StringsManager.onboardingNext), findsOneWidget);
    expect(find.text(StringsManager.onboardingGetStarted), findsNothing);

    // Hold a drag halfway between page 3 and page 4 without releasing.
    final gesture = await tester.startGesture(tester.getCenter(find.byType(PageView)));
    await tester.pump();
    // Stepped, so the drag clears the touch slop and the scroll actually moves.
    for (var i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(-32, 0));
      await tester.pump();
    }

    // Mid-swipe both layouts are on screen at once — that is the cross-fade.
    // Before the fix, Next was still the only child until the page settled.
    expect(find.text(StringsManager.onboardingNext), findsOneWidget);
    expect(find.text(StringsManager.onboardingGetStarted), findsOneWidget);
    expect(find.text(StringsManager.onboardingContinueAsGuest), findsOneWidget);

    // Carry the drag past the halfway mark so it settles on page 4 instead of
    // springing back to page 3.
    for (var i = 0; i < 5; i++) {
      await gesture.moveBy(const Offset(-32, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Landed: Next is gone, the pair owns the strip.
    expect(find.text(StringsManager.onboardingNext), findsNothing);
    expect(find.text(StringsManager.onboardingGetStarted), findsOneWidget);
  });

  testWidgets('the final buttons are usable as soon as the page lands', (tester) async {
    // They used to wait ~1.4 s for the heatmap to finish filling.
    await _pumpOnboarding(tester, theme: _Theme.dark, disableAnimations: true);

    for (var i = 0; i < 3; i++) {
      await _swipe(tester);
    }

    // `FadeTransition`, not `Opacity`: the cross-fade was moved off `Opacity`
    // so the swipe does not force a `saveLayer` on every frame. What is being
    // asserted is unchanged — the pair is fully opaque once the page lands.
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.text(StringsManager.onboardingGetStarted),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, 1.0);
  });

  testWidgets('page 4 buttons share height, radius and label size', (tester) async {
    await _pumpOnboarding(tester, theme: _Theme.dark, disableAnimations: true);

    for (var i = 0; i < 3; i++) {
      await _swipe(tester);
    }
    await tester.pump(const Duration(milliseconds: 600));

    final getStarted = find.widgetWithText(OnboardingButton, StringsManager.onboardingGetStarted);
    final guest = find.widgetWithText(OnboardingButton, StringsManager.onboardingContinueAsGuest);
    expect(getStarted, findsOneWidget);
    expect(guest, findsOneWidget);

    expect(tester.getSize(getStarted).height, tester.getSize(guest).height);

    TextStyle labelOf(Finder button) =>
        tester.widget<Text>(find.descendant(of: button, matching: find.byType(Text))).style!;
    expect(labelOf(getStarted).fontSize, labelOf(guest).fontSize);

    BorderRadius radiusOf(Finder button) {
      final container = tester.widget<Container>(
        find.descendant(of: button, matching: find.byType(Container)).first,
      );
      return (container.decoration! as BoxDecoration).borderRadius! as BorderRadius;
    }

    expect(radiusOf(getStarted), radiusOf(guest));
  });

  testWidgets('Continue as guest records onboarding_seen and leaves for home', (tester) async {
    final storage = await _pumpOnboarding(tester, theme: _Theme.dark, disableAnimations: true);

    for (var i = 0; i < 3; i++) {
      await _swipe(tester);
    }
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text(StringsManager.onboardingContinueAsGuest));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(storage.read<bool>(OnboardingStore.seenKey), isTrue);
    expect(find.byKey(const ValueKey('home')), findsOneWidget);
  });

  testWidgets('Get started records onboarding_seen and leaves for login', (tester) async {
    final storage = await _pumpOnboarding(tester, theme: _Theme.light, disableAnimations: true);

    for (var i = 0; i < 3; i++) {
      await _swipe(tester);
    }
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text(StringsManager.onboardingGetStarted));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(storage.read<bool>(OnboardingStore.seenKey), isTrue);
    expect(find.byKey(const ValueKey('login')), findsOneWidget);
  });
}
