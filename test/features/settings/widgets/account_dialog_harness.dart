import 'package:algorithm_visualizer/core/widgets/custom_widgets/animated_popup.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_profile_remote_data_source.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

const accountPassword = 'secret-1';

class AccountDialogHarness {
  AccountDialogHarness(this.tester, this.container);

  final WidgetTester tester;
  final ProviderContainer container;
  int closed = 0;

  FakeProfileRemoteDataSource get remote =>
      container.read(profileRemoteDataSourceProvider) as FakeProfileRemoteDataSource;

  /// On a small phone with large text the dialog is taller than the screen, so the button may need scrolling to.
  Future<void> tap(String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pump();
    await tester.pump();
  }

  /// The result message stays up for 3 seconds, and closing the popup animates.
  Future<void> drain() => tester.pump(const Duration(seconds: 5));
}

/// Opens the dialog the way Settings does, inside [AnimatedPopup], which scrolls a dialog taller than the
/// screen and lifts it above the keyboard.
Future<AccountDialogHarness> pumpAccountDialog(
  WidgetTester tester,
  Widget Function(VoidCallback onClose) dialog, {
  ScreenSize screen = ScreenSize.phone,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1.0,
}) async {
  late AccountDialogHarness harness;
  final container = await pumpApp(
    tester,
    Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => AnimatedPopup.show(
            context,
            builder: (removeOverlay) => dialog(() {
              harness.closed++;
              removeOverlay();
            }),
          ),
          child: const Text('open'),
        ),
      ),
    ),
    signedInAs: buildTestUser(),
    screen: screen,
    theme: theme,
    textScale: textScale,
  );
  harness = AccountDialogHarness(tester, container);
  harness.remote.password = accountPassword;
  // The dialogs read the user once; keep the auto-disposing profile alive so it is the same one after.
  container.listen(profileProvider, (previous, next) {});

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return harness;
}
