// Consent belongs where consent is given. Creating the account is the moment
// personal data starts being stored, so the policy has to be reachable from
// that screen — not only from a settings page the user may never open.

import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/signup/view/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Wider than a real phone on purpose. `flutter_test` renders every glyph as a
/// full em square, so text measures roughly twice its real width, and the auth
/// screen's own header and footer rows already overflow under that font at
/// 360pt — a pre-existing quirk of the test font, not of the app. This test is
/// about what the screen says and where the link goes, so it steps around that
/// rather than asserting layout it does not own.
const Size _surface = Size(640, 900);

class _FakeUrlLauncher extends UrlLauncherPlatform with MockPlatformInterfaceMixin {
  final List<String> urls = <String>[];

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    urls.add(url);
    return true;
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

class _InMemoryStorage implements LocalStorage {
  final Map<String, Object?> _values = <String, Object?>{};

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

late _FakeUrlLauncher _launcher;

Future<void> _pumpSignUp(WidgetTester tester) async {
  const devicePixelRatio = 3.0;
  await tester.binding.setSurfaceSize(_surface);
  tester.view.physicalSize = _surface * devicePixelRatio;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(() {
    tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[GoRoute(path: '/', builder: (context, state) => const SignUpPage())],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [localStorageProvider.overrideWithValue(_InMemoryStorage())],
      child: ScreenUtilInit(
        designSize: _surface,
        builder: (context, _) => MediaQuery(
          data: const MediaQueryData(size: _surface),
          child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _launcher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = _launcher;
  });

  testWidgets('the sign up screen names both documents it is asking agreement to', (tester) async {
    await _pumpSignUp(tester);

    expect(find.text(StringsManager.signUpConsentPrefix), findsOneWidget);
    expect(find.text(StringsManager.termsOfService), findsOneWidget);
    expect(find.text(StringsManager.privacyPolicy), findsOneWidget);
  });

  testWidgets('the terms are one tap away from there', (tester) async {
    await _pumpSignUp(tester);

    await _tapLink(tester, StringsManager.termsOfService);

    expect(_launcher.urls, <String>[kTermsOfServiceUrl]);
  });

  testWidgets('and so is the privacy policy', (tester) async {
    await _pumpSignUp(tester);

    await _tapLink(tester, StringsManager.privacyPolicy);

    expect(_launcher.urls, <String>[kPrivacyPolicyUrl]);
  });
}

Future<void> _tapLink(WidgetTester tester, String label) async {
  final link = find.text(label);
  await tester.scrollUntilVisible(link, 120, scrollable: find.byType(Scrollable).first);
  await tester.tap(link);
  await tester.pumpAndSettle();
}
