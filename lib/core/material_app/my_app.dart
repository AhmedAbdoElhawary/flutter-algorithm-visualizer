import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/extensions/language.dart';
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
            final controller = ref.watch(appSettingsProvider);
            final router = AppRoutes.instance.routerProvider;
            final themeMode = controller.themeMode;

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
                        locale: Locale(controller.language.shortKey),
                        supportedLocales: const [Locale('en'), Locale('ar')],
                        localizationsDelegates: const [
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        localeResolutionCallback: dynamicTranslate,

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

  Locale? dynamicTranslate(Locale? locale, Iterable<Locale> supportedLocales) {
    if (locale != null && supportedLocales.contains(locale)) return locale;
    return supportedLocales.first;
  }
}
