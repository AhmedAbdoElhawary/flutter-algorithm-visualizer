import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_contact_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../../helpers/fakes/fake_url_launcher.dart';
import '../../../helpers/pump_app.dart';

/// Records what the app asked the platform to open, instead of opening it.
void main() {
  late FakeUrlLauncher launcher;

  setUp(() {
    launcher = FakeUrlLauncher();
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
