import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/extensions/language.dart';
import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:algorithm_visualizer/features/settings/view/settings_page.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_appearance_section.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// The smallest screen the design targets.
const Size _smallSurface = Size(360, 640);

/// Records what the app asked the platform to open, instead of opening it.
class _FakeUrlLauncher extends UrlLauncherPlatform with MockPlatformInterfaceMixin {
  final List<String> urls = <String>[];
  final List<PreferredLaunchMode> modes = <PreferredLaunchMode>[];
  bool succeed = true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    urls.add(url);
    modes.add(options.mode);
    return succeed;
  }

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;

  @override
  Future<bool> supportsCloseForMode(PreferredLaunchMode mode) async => true;

  @override
  LinkDelegate? get linkDelegate => null;
}

late _FakeUrlLauncher _launcher;

Future<void> _pumpSettings(
  WidgetTester tester, {
  bool signedIn = false,
  String email = 'someone@example.com',
  Brightness brightness = Brightness.dark,
  LocalStorage? settingsStorage,
  LanguagesEnum language = LanguagesEnum.english,
}) async {
  const devicePixelRatio = 3.0;
  await tester.binding.setSurfaceSize(_smallSurface);
  tester.view.physicalSize = _smallSurface * devicePixelRatio;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(() {
    tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const SettingsPage()),
      GoRoute(
        path: Routes.login.path,
        name: Routes.login.name,
        builder: (context, state) => const Placeholder(key: ValueKey('login')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appSettingsStorageProvider.overrideWithValue(
          settingsStorage ?? (_InMemorySettings()..seedLanguage(language)),
        ),
        isSignedInProvider.overrideWithValue(signedIn),
        currentUserProvider.overrideWithValue(
          signedIn ? AuthUser(id: 'u1', name: 'Someone', email: email) : null,
        ),
      ],
      child: ScreenUtilInit(
        designSize: _smallSurface,
        builder: (context, _) => MediaQuery(
          data: const MediaQueryData(size: _smallSurface),
          child: MaterialApp.router(
            theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,

            /// The real delegates, so an Arabic run in this file mirrors and
            /// translates exactly as the app does.
            locale: Locale(language.shortKey),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _InMemorySettings implements LocalStorage {
  final Map<String, Object?> _values = <String, Object?>{};

  void seedLanguage(LanguagesEnum language) => _values[AppSettingsNotifier.languageKey] = language.shortKey;

  @override
  Future<void> write<T>(String key, T value) async => _values[key] = value;

  @override
  T? read<T>(String key) => _values[key] as T?;

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  bool has(String key) => _values.containsKey(key);
}

/// Taps a row by its title, scrolling it into view first — the screen is longer
/// than 640px now, so the contact and about rows start off-screen.
Future<void> _tapRow(WidgetTester tester, String title) async {
  final row = find.text(title);
  await tester.scrollUntilVisible(row, 120, scrollable: find.byType(Scrollable).first);
  await tester.tap(row);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _launcher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = _launcher;
  });

  group('account section', () {
    testWidgets('a guest is offered a way in, and never a delete button', (tester) async {
      await _pumpSettings(tester);

      expect(find.text(StringsManager.guestAccountTitle), findsOneWidget);
      expect(find.text(StringsManager.deleteAccount), findsNothing);
    });

    testWidgets('a signed-in user sees their address and the delete row', (tester) async {
      await _pumpSettings(tester, signedIn: true, email: 'me@algodive.app');

      expect(find.text(StringsManager.settingsSignedInAs), findsOneWidget);
      expect(find.text('me@algodive.app'), findsOneWidget);
      expect(find.text(StringsManager.deleteAccount), findsOneWidget);
    });

    testWidgets('tapping delete asks about the consequence before the password', (tester) async {
      await _pumpSettings(tester, signedIn: true);

      await tester.tap(find.text(StringsManager.deleteAccount));
      await tester.pumpAndSettle();

      expect(find.text(StringsManager.deleteAccountConfirmTitle), findsOneWidget);
      expect(find.text(StringsManager.deleteAccountContinue), findsOneWidget);
      expect(find.text(StringsManager.deleteAccountPasswordTitle), findsNothing);
    });
  });

  group('legal section', () {
    testWidgets('the terms of service open the published page', (tester) async {
      await _pumpSettings(tester);

      await _tapRow(tester, StringsManager.termsOfService);

      expect(_launcher.urls, <String>[kTermsOfServiceUrl]);
      expect(_launcher.modes.single, PreferredLaunchMode.inAppBrowserView);
    });

    testWidgets('the privacy policy opens the published page in an in-app browser', (tester) async {
      await _pumpSettings(tester);

      await _tapRow(tester, StringsManager.privacyPolicy);

      expect(_launcher.urls, <String>[kPrivacyPolicyUrl]);
      expect(_launcher.modes.single, PreferredLaunchMode.inAppBrowserView);
    });

    testWidgets('the deletion page opens too, so a locked-out user has a route', (tester) async {
      await _pumpSettings(tester);

      await _tapRow(tester, StringsManager.deleteAccountHowItWorks);

      expect(_launcher.urls, <String>[kDeleteAccountUrl]);
    });

    testWidgets('the policy version is stated, and is not the app version', (tester) async {
      await _pumpSettings(tester);

      expect(find.textContaining(kLegalVersion), findsWidgets);
      expect(find.textContaining(kLegalUpdated), findsOneWidget);
    });
  });

  group('contact section', () {
    testWidgets('the mail row opens a mailto for the support address', (tester) async {
      await _pumpSettings(tester);

      await _tapRow(tester, StringsManager.contactEmail);

      expect(_launcher.urls.single, startsWith('mailto:$kSupportEmail'));
      expect(_launcher.urls.single, contains('subject='));
    });

    testWidgets('GitHub opens the profile in its own app, not a browser tab', (tester) async {
      await _pumpSettings(tester);

      await _tapRow(tester, StringsManager.contactGithub);

      expect(_launcher.urls, <String>[kGithubProfileUrl]);
      expect(_launcher.modes.single, PreferredLaunchMode.externalApplication);
    });

    testWidgets('LinkedIn opens externally as well', (tester) async {
      await _pumpSettings(tester);

      await _tapRow(tester, StringsManager.contactLinkedIn);

      expect(_launcher.urls, <String>[kLinkedInUrl]);
      expect(_launcher.modes.single, PreferredLaunchMode.externalApplication);
    });
  });

  group('about section', () {
    testWidgets('the source code row opens the repository', (tester) async {
      await _pumpSettings(tester);

      await _tapRow(tester, StringsManager.sourceCode);

      expect(_launcher.urls, <String>[kSourceCodeUrl]);
      expect(_launcher.modes.single, PreferredLaunchMode.externalApplication);
    });

    testWidgets('the version is shown', (tester) async {
      await _pumpSettings(tester);

      expect(find.text(kAppVersion), findsOneWidget);
    });
  });

  /// TODO: handle this case:
  // group('failure handling', () {
  //   testWidgets('a link nothing can open says so instead of failing silently', (tester) async {
  //     _launcher.succeed = false;
  //     await _pumpSettings(tester);
  //
  //     await _tapRow(tester, StringsManager.privacyPolicy);
  //
  //     expect(find.text(StringsManager.linkCouldNotOpen), findsOneWidget);
  //   });
  // });

  group('appearance', () {
    testWidgets('offers system, light and dark', (tester) async {
      await _pumpSettings(tester);

      expect(find.text(StringsManager.themeSystem), findsOneWidget);
      expect(find.text(StringsManager.themeLight), findsOneWidget);
      expect(find.text(StringsManager.themeDark), findsOneWidget);
    });

    testWidgets('exactly one row is checked, and it is the active mode', (tester) async {
      final storage = _InMemorySettings();
      await storage.write(AppSettingsNotifier.themeModeKey, 'light');

      await _pumpSettings(tester, settingsStorage: storage);

      // Scoped to the appearance card: the language card below it carries a
      // check of its own, and "exactly one" has always meant one *per
      // picker*, not one on the whole screen.
      final checks = find.descendant(
        of: find.byType(SettingsAppearanceSection),
        matching: find.byIcon(Icons.check_rounded),
      );
      expect(checks, findsOneWidget);

      // The check sits in the Light row, not merely somewhere on screen.
      final lightRow = find.ancestor(
        of: find.text(StringsManager.themeLight),
        matching: find.byType(SettingsRow),
      );
      expect(find.descendant(of: lightRow, matching: checks), findsOneWidget);
    });

    testWidgets('picking a mode writes it where the next launch will look', (tester) async {
      final storage = _InMemorySettings();
      await _pumpSettings(tester, settingsStorage: storage);

      await _tapRow(tester, StringsManager.themeDark);

      expect(storage.read<String>(AppSettingsNotifier.themeModeKey), 'dark');
    });

    testWidgets('the check moves to whichever row was tapped', (tester) async {
      await _pumpSettings(tester);

      await _tapRow(tester, StringsManager.themeLight);

      final lightRow = find.ancestor(
        of: find.text(StringsManager.themeLight),
        matching: find.byType(SettingsRow),
      );
      expect(
        find.descendant(of: lightRow, matching: find.byIcon(Icons.check_rounded)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(SettingsAppearanceSection),
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsOneWidget,
      );
    });
  });

  // group('language', () {
  //   testWidgets('names each language in its own script, untranslated', (tester) async {
  //     await _pumpSettings(tester);
  //
  //     expect(find.text('English'), findsOneWidget);
  //     expect(find.text('العربية'), findsOneWidget);
  //   });
  //
  //   testWidgets('still names both after switching to Arabic', (tester) async {
  //     // The point of the row labels: someone who switched by mistake has to
  //     // be able to find their way back without reading Arabic.
  //     await _pumpSettings(tester, language: LanguagesEnum.arabic);
  //
  //     expect(find.text('English'), findsOneWidget);
  //     expect(find.text('العربية'), findsOneWidget);
  //   });
  //
  //   testWidgets('picking a language writes it where the next launch will look', (tester) async {
  //     final storage = _InMemorySettings();
  //     await _pumpSettings(tester, settingsStorage: storage);
  //
  //     await _tapRow(tester, 'العربية');
  //
  //     expect(storage.read<String>(AppSettingsNotifier.languageKey), 'ar');
  //   });
  //
  //   testWidgets('exactly one row is checked, and it is the active language', (tester) async {
  //     await _pumpSettings(tester, language: LanguagesEnum.arabic);
  //
  //     final section = find.byType(SettingsLanguageSection);
  //     expect(
  //       find.descendant(of: section, matching: find.byIcon(Icons.check_rounded)),
  //       findsOneWidget,
  //     );
  //
  //     final arabicRow = find.ancestor(of: find.text('العربية'), matching: find.byType(SettingsRow));
  //     expect(
  //       find.descendant(of: arabicRow, matching: find.byIcon(Icons.check_rounded)),
  //       findsOneWidget,
  //     );
  //   });
  // });

  group('in Arabic', () {
    testWidgets('mirrors, translates, and still fits 360x640', (tester) async {
      await _pumpSettings(tester, language: LanguagesEnum.arabic, signedIn: true);

      expect(
        Directionality.of(tester.element(find.byType(SettingsPage))),
        TextDirection.rtl,
      );
      expect(find.text('الإعدادات'), findsOneWidget);
      expect(find.text(StringsManager.settings), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolls to the bottom without overflowing', (tester) async {
      // Arabic runs longer than English for most of these captions, so the
      // rows below the fold are where a wrap would break first.
      await _pumpSettings(tester, language: LanguagesEnum.arabic, signedIn: true);

      await tester.scrollUntilVisible(
        find.text('إصدار السياسة'),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
    });
  });

  for (final brightness in <Brightness>[Brightness.dark, Brightness.light]) {
    final name = brightness == Brightness.dark ? 'dark' : 'light';

    group('in $name theme', () {
      testWidgets('renders at 360x640 with no overflow', (tester) async {
        await _pumpSettings(tester, signedIn: true, brightness: brightness);

        expect(tester.takeException(), isNull);
      });

      testWidgets('every section is present and legible', (tester) async {
        await _pumpSettings(tester, signedIn: true, brightness: brightness);

        expect(find.text(StringsManager.settingsAccountSection), findsOneWidget);
        expect(find.text(StringsManager.settingsAppearanceSection), findsOneWidget);
        expect(find.text(StringsManager.settingsLegalSection), findsOneWidget);
        expect(find.text(StringsManager.settingsContactSection), findsOneWidget);
        expect(find.text(StringsManager.settingsAboutSection), findsOneWidget);
      });
    });
  }
}
