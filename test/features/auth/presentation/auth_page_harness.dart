import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_auth_remote_data_source.dart';
import '../../../helpers/pump_app.dart';

const existingUser = AuthUserDTO(id: 'uid-1', name: 'Ada', email: 'ada@test.dev');
const existingPassword = 'secret-1';

class AuthPageHarness {
  AuthPageHarness(this.tester, this.container);

  final WidgetTester tester;
  final ProviderContainer container;

  FakeAuthRemoteDataSource get remote => container.read(authRemoteDataSourceProvider) as FakeAuthRemoteDataSource;

  Future<void> type(String label, String text) async {
    final field = find.widgetWithText(AuthTextField, label);
    await tester.ensureVisible(field);
    await tester.enterText(field, text);
    await tester.pump();
  }

  /// Scrolls to the text first: on a small phone with large text the form is taller than the screen.
  Future<void> tap(String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pump();
    await tester.tap(find.text(text).last);
    await tester.pump();
    await tester.pump();
  }

  /// Error and success messages stay up for 3 seconds.
  Future<void> drain() => tester.pump(const Duration(seconds: 5));
}

/// Opens [route] in the real app, with one existing account in the auth fake.
Future<AuthPageHarness> openAuthPage(
  WidgetTester tester,
  String route, {
  ScreenSize screen = ScreenSize.phone,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1.0,
}) async {
  final container = await pumpApp(
    tester,
    const SizedBox(),
    initialRoute: route,
    screen: screen,
    theme: theme,
    textScale: textScale,
  );
  final harness = AuthPageHarness(tester, container);
  harness.remote.accounts[existingUser.email] = (user: existingUser, password: existingPassword);
  await tester.pumpAndSettle();
  return harness;
}
