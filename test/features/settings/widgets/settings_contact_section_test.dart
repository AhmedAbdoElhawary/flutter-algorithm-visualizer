import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_contact_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../../helpers/pump_app.dart';

/// Records what the app asked the platform to open, instead of opening it.
class _FakeUrlLauncher extends UrlLauncherPlatform with MockPlatformInterfaceMixin {
  final urls = <String>[];
  final modes = <PreferredLaunchMode>[];
  bool succeed = true;
  bool throws = false;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    if (throws) throw Exception('no app can open this');
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

void main() {
  late _FakeUrlLauncher launcher;

  setUp(() {
    launcher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = launcher;
  });

  Future<void> tapRow(WidgetTester tester, String title) async {
    await pumpApp(tester, const Scaffold(body: SettingsContactSection()));
    await tester.tap(find.text(title));
    await tester.pump();
  }

  testWidgets('mail opens the support address with a subject', (tester) async {
    await tapRow(tester, StringsManager.contactEmail);

    expect(launcher.urls.single, startsWith('mailto:$kSupportEmail?subject='));
  });

  testWidgets('GitHub and LinkedIn open in their own apps', (tester) async {
    await tapRow(tester, StringsManager.contactGithub);
    await tester.tap(find.text(StringsManager.contactLinkedIn));
    await tester.pump();

    expect(launcher.urls, [kGithubProfileUrl, kLinkedInUrl]);
    expect(launcher.modes, everyElement(PreferredLaunchMode.externalApplication));
  });

  testWidgets('no mail app says so', (tester) async {
    launcher.succeed = false;

    await tapRow(tester, StringsManager.contactEmail);

    expect(find.text(StringsManager.linkNoMailApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('a launcher that throws is reported, not crashed on', (tester) async {
    launcher.throws = true;

    await tapRow(tester, StringsManager.contactGithub);

    expect(find.text(StringsManager.linkCouldNotOpen), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
}
