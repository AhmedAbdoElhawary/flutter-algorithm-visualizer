import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/language.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/helpers/system_overlay_style.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:algorithm_visualizer/config/themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const defaultSize = Size(360, 690);

    return ScreenUtilInit(
      designSize: defaultSize,
      minTextAdapt: true,
      splitScreenMode: true,
      fontSizeResolver: (fontSize, instance) {
        final size = fontSize;
        final width = MediaQuery.of(context).size.width;
        // Size(501.7, 669.0)

        if (width <= 450) return size.toDouble() * (instance.scaleText);

        return size.toDouble() * (instance.scaleText / 1.35);
      },
      builder: (context, child) {
        return Consumer(
          builder: (context, ref, child) {
            final controller = ref.watch(appSettingsProvider);
            bool isDarkMode = controller.themeMode != ThemeMode.light;
            final theme = isDarkMode ? AppTheme.dark : AppTheme.light;
            final themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

            return LayoutBuilder(
              builder: (context, constraints) {
                final padding = constraints.maxWidth < 450
                    ? 0.0
                    : ((constraints.maxWidth - defaultSize.width) / 2.3);

                return SystemOverlay(
                  isBlackTheme: isDarkMode,
                  child: Container(
                    color: isDarkMode ? ColorManager.black : ColorManager.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: MaterialApp.router(
                        title: StringsManager.appName,
                        // defaultTransition: Transition.noTransition,
                        // translations: TranslationHandler(),
                        locale: Locale(controller.language.shortKey),
                        // fallbackLocale:
                        // Locale(LanguagesEnum.english.shortKey),
                        localeResolutionCallback: dynamicTranslate,
                        theme: theme,
                        darkTheme: AppTheme.dark,
                        themeMode: themeMode,
                        debugShowCheckedModeBanner: false,
                        routerDelegate: AppRoutes.router.routerDelegate,
                        backButtonDispatcher:
                            AppRoutes.router.backButtonDispatcher,
                        routeInformationParser:
                            AppRoutes.router.routeInformationParser,
                        routeInformationProvider:
                            AppRoutes.router.routeInformationProvider,
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
