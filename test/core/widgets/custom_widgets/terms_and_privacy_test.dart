import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/terms_and_privacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../../helpers/fakes/fake_url_launcher.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeUrlLauncher launcher;

  setUp(() {
    final original = UrlLauncherPlatform.instance;
    launcher = FakeUrlLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = original);
  });

  testWidgets('each link opens its own page', (tester) async {
    await pumpApp(tester, const LegalConsent());

    await tester.tap(find.text(StringsManager.termsOfService));
    await tester.tap(find.text(StringsManager.privacyPolicy));

    expect(launcher.urls, [kTermsOfServiceUrl, kPrivacyPolicyUrl]);
  });

  testWidgets('the sentence wraps on a small screen with large text', (tester) async {
    await pumpApp(tester, const LegalConsent(), screen: ScreenSize.smallPhone, textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
