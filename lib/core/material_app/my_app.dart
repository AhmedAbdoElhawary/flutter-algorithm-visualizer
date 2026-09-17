import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/helpers/system_overlay_style.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultSize = MediaQuery.sizeOf(context);

    return ScreenUtilInit(
      designSize: defaultSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer(
          builder: (context, ref, child) {
            /// `.select`, not the whole provider. This `Consumer` sits above
            /// `MaterialApp.router`, so an unscoped watch rebuilt the entire
            /// navigator stack whenever *any* setting changed — including the
            /// language, which this widget does not even use yet.
            final themeMode = ref.watch(appSettingsProvider.select((s) => s.themeMode));
            final router = AppRoutes.instance.routerProvider;

            /// TODO(ahmed): Arabic is wired up but not reachable — the locale
            /// is pinned to English here, `AppLocalizations.delegate` and
            /// `localeResolutionCallback` below are commented out, and
            /// `assets/problems.ar.json` is not declared in `pubspec.yaml`, so
            /// it never ships. Enabling it means turning all four back on
            /// together; until then the Settings language row stays hidden.
            // final locale = Locale(ref.watch(appSettingsProvider.select((s) => s.language)).shortKey);
            const locale = Locale("en");

            /// `MaterialApp` resolves [ThemeMode.system] for the widgets below
            /// it, but the two things painted *outside* it — the system bars
            /// and the wide-screen letterbox — have to resolve it themselves.
            final isDarkMode = switch (themeMode) {
              ThemeMode.system => MediaQuery.platformBrightnessOf(context) == Brightness.dark,
              ThemeMode.dark => true,
              ThemeMode.light => false,
            };
            final ground = isDarkMode ? ColorManager.groundDk : ColorManager.groundLt;

            return LayoutBuilder(
              builder: (context, constraints) {
                final padding =
                    constraints.maxWidth < 450 ? 0.0 : ((constraints.maxWidth - defaultSize.width) / 2.3);

                return SystemOverlay(
                  isBlackTheme: isDarkMode,
                  child: Container(
                    /// The bars down either side on a tablet or a desktop
                    /// window. This is page background, so it takes `ground` —
                    /// the light value used to be `inkPrimaryDk`, pure white,
                    /// which left a visible seam against the `#F4F5F7` page.
                    color: ground,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: MaterialApp.router(
                        title: StringsManager.appName,
                        locale: locale,
                        // supportedLocales: AppLocalizations.supportedLocales,
                        supportedLocales: const [Locale('en'), Locale('ar')],

                        /// `AppLocalizations` carries this app's own table;
                        /// the three `Global*` delegates carry Flutter's —
                        /// month names, the "Paste" on a text selection
                        /// menu, and, the reason RTL needs no work here, the
                        /// `Directionality` that `WidgetsApp` reads back out
                        /// of `GlobalWidgetsLocalizations`. Choosing `ar`
                        /// flips the whole tree by itself.
                        localizationsDelegates: const [
                          // AppLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        // localeResolutionCallback: dynamicTranslate,

                        /// Both themes are handed over and `themeMode` picks
                        /// between them, so `ThemeMode.system` is a real
                        /// option rather than being collapsed to dark here.
                        theme: AppTheme.light,
                        darkTheme: AppTheme.dark,
                        themeMode: themeMode,
                        debugShowCheckedModeBanner: false,
                        routerDelegate: router.routerDelegate,
                        backButtonDispatcher: router.backButtonDispatcher,
                        routeInformationParser: router.routeInformationParser,
                        routeInformationProvider: router.routeInformationProvider,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // /// Matches on **language code only**.
  // ///
  // /// The old body compared whole `Locale` objects, so a device reporting
  // /// `ar_EG` — or this app's own `ar_sa` short key, if it were ever passed
  // /// here — did not equal `const Locale('ar')` and silently fell back to
  // /// English. Arabic is Arabic whatever the country subtag says.
  // Locale? dynamicTranslate(Locale? locale, Iterable<Locale> supportedLocales) {
  //   if (locale == null) return supportedLocales.first;
  //
  //   for (final supported in supportedLocales) {
  //     if (supported.languageCode == locale.languageCode) return supported;
  //   }
  //   return supportedLocales.first;
  // }
}
