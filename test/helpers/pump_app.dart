import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show Override;

import 'test_container.dart';

enum ScreenSize {
  smallPhone(320, 568),
  phone(390, 844),
  tablet(820, 1180);

  const ScreenSize(this.width, this.height);

  final double width;
  final double height;

  Size get size => Size(width, height);
}

/// Pumps [child] inside the same ProviderScope → ScreenUtilInit → MaterialApp shape as `MyApp`,
/// with storage and every remote data source swapped for fakes, so nothing reaches disk or Firebase.
///
/// When [initialRoute] is set, the app's real router is pumped instead of [child].
Future<ProviderContainer> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  ScreenSize screen = ScreenSize.phone,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1.0,
  AuthUser? signedInAs,
  String? initialRoute,
}) async {
  tester.view.physicalSize = screen.size * 3.0;
  tester.view.devicePixelRatio = 3.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  final container = createTestContainer(signedInAs: signedInAs, overrides: overrides);

  final router = initialRoute == null ? null : AppRoutes.buildRouter(initialRoute);
  if (router != null) addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: screen.size,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) {
          const localizationsDelegates = [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ];

          if (router != null) {
            return MaterialApp.router(
              title: StringsManager.appName,
              locale: const Locale('en'),
              localizationsDelegates: localizationsDelegates,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: theme,
              debugShowCheckedModeBanner: false,
              routerConfig: router,
            );
          }

          return MaterialApp(
            title: StringsManager.appName,
            locale: const Locale('en'),
            localizationsDelegates: localizationsDelegates,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme,
            debugShowCheckedModeBanner: false,
            home: child,
          );
        },
      ),
    ),
  );

  return container;
}
