import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riverpod/misc.dart' show Override;

/// Fixed surface every golden in this feature renders at, so ScreenUtil
/// resolves identically on every run (determinism rule #3,
/// contracts/golden-inventory.md).
const Size goldenSurfaceSize = Size(430, 932);
const double goldenDevicePixelRatio = 3.0;

/// Pumps [child] inside a minimal, deterministic app shell and settles it,
/// enforcing the five determinism rules from contracts/golden-inventory.md:
/// fixed settled frame, seeded content only (the caller's responsibility),
/// fixed surface size + device pixel ratio, no network font fetch.
///
/// The app's real [ScreenUtilInit] derives `designSize` from the current
/// [MediaQuery] size (see `lib/core/material_app/my_app.dart`) — this harness
/// does the same with the fixed [goldenSurfaceSize] so `.r`/`.w`/`.h` resolve
/// to the same 1:1 scale the real app uses at that size.
Future<void> pumpGolden(
  WidgetTester tester,
  Widget child, {
  required Brightness brightness,
  Size surfaceSize = goldenSurfaceSize,
  double devicePixelRatio = goldenDevicePixelRatio,
  List<Override> overrides = const [],
}) async {
  // No network font fetch (determinism rule #5). google_fonts then falls
  // back to Flutter's built-in test-font placeholder for any glyph it can't
  // resolve locally — deterministic and network-free, which is everything
  // the determinism rule requires. It is not real-looking text, but golden
  // tests don't need real glyphs, only stable ones.
  GoogleFonts.config.allowRuntimeFetching = false;

  await tester.binding.setSurfaceSize(surfaceSize);
  tester.view.physicalSize = surfaceSize * devicePixelRatio;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: ScreenUtilInit(
        designSize: surfaceSize,
        minTextAdapt: true,
        // AppTheme.light/dark read ScreenUtil's `.w`/`.r` extensions, so they
        // must be evaluated inside this builder — after ScreenUtilInit has
        // initialized its singleton — not before pumpWidget is called.
        builder: (context, _) => MaterialApp(
          title: StringsManager.appName,
          debugShowCheckedModeBanner: false,
          theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
          home: child,
        ),
      ),
    ),
  );

  // Settle to a fixed frame — no golden may be taken mid-transition.
  await tester.pumpAndSettle();
}

/// Captures [finder] against the committed reference PNG at
/// `test/golden/goldens/<name>.png`.
Future<void> expectGolden(WidgetTester tester, Finder finder, String name) async {
  await expectLater(finder, matchesGoldenFile('goldens/$name.png'));
}
