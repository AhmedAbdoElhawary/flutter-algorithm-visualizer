import 'package:algorithm_visualizer/core/helpers/link_launcher.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../helpers/fakes/fake_url_launcher.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeUrlLauncher launcher;
  late UrlLauncherPlatform original;

  setUp(() {
    original = UrlLauncherPlatform.instance;
    launcher = FakeUrlLauncher();
    UrlLauncherPlatform.instance = launcher;
  });

  tearDown(() => UrlLauncherPlatform.instance = original);

  Future<BuildContext> pumpContext(WidgetTester tester) async {
    await pumpApp(tester, const Scaffold(body: SizedBox()));
    return tester.element(find.byType(SizedBox).last);
  }

  group('openLink', () {
    testWidgets('opens in the app by default', (tester) async {
      final context = await pumpContext(tester);

      await context.openLink('https://algodive.app/privacy');
      await tester.pump();

      expect(launcher.urls, ['https://algodive.app/privacy']);
      expect(launcher.modes, [PreferredLaunchMode.inAppBrowserView]);
      expect(find.text(StringsManager.linkCouldNotOpen), findsNothing);
    });

    testWidgets('an external link goes to the app that owns it', (tester) async {
      final context = await pumpContext(tester);

      await context.openLink('https://github.com', target: LinkTarget.external);

      expect(launcher.modes, [PreferredLaunchMode.externalApplication]);
    });

    testWidgets('says so when nothing can open it', (tester) async {
      final context = await pumpContext(tester);
      launcher.succeed = false;

      await context.openLink('https://algodive.app');
      await tester.pump();

      expect(find.text(StringsManager.linkCouldNotOpen), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('says so when the launcher throws, as it does with no browser', (tester) async {
      final context = await pumpContext(tester);
      launcher.throws = true;

      await context.openLink('https://algodive.app');
      await tester.pump();

      expect(find.text(StringsManager.linkCouldNotOpen), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('a broken URL is reported, never launched', (tester) async {
      final context = await pumpContext(tester);

      await context.openLink('http://[broken');
      await tester.pump();

      expect(launcher.urls, isEmpty);
      expect(find.text(StringsManager.linkCouldNotOpen), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('a page closed before the launcher answers shows nothing', (tester) async {
      final context = await pumpContext(tester);
      launcher.succeed = false;

      final opening = context.openLink('https://algodive.app');
      await tester.pumpWidget(const SizedBox());
      await opening;

      expect(tester.takeException(), isNull);
    });
  });

  group('sendEmail', () {
    testWidgets('opens the mail app with the address and the subject', (tester) async {
      final context = await pumpContext(tester);

      await context.sendEmail('hi@algodive.app', subject: 'Bug & idea');

      expect(launcher.urls, ['mailto:hi@algodive.app?subject=Bug%20%26%20idea']);
      expect(launcher.modes, [PreferredLaunchMode.externalApplication]);
    });

    testWidgets('without a subject, only the address', (tester) async {
      final context = await pumpContext(tester);

      await context.sendEmail('hi@algodive.app');

      expect(launcher.urls, ['mailto:hi@algodive.app']);
    });

    for (final (label, setUpFailure) in [
      ('no mail app answers', (FakeUrlLauncher l) => l.succeed = false),
      ('the launcher throws', (FakeUrlLauncher l) => l.throws = true),
    ]) {
      testWidgets('says there is no mail app when $label', (tester) async {
        final context = await pumpContext(tester);
        setUpFailure(launcher);

        await context.sendEmail('hi@algodive.app');
        await tester.pump();

        expect(find.text(StringsManager.linkNoMailApp), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
      });
    }
  });
}
