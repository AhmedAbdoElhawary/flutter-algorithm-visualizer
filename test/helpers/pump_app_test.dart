import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_auth_remote_data_source.dart';
import 'fakes/fake_problem_remote_data_source.dart';
import 'fakes/fake_profile_remote_data_source.dart';
import 'fakes/in_memory_storage.dart';
import 'pump_app.dart';
import 'screen_matrix.dart';
import 'test_data.dart';

void main() {
  group('pumpApp', () {
    for (final screen in ScreenSize.values) {
      testWidgets('sets the ${screen.name} size and resets it after the test', (tester) async {
        final defaultSize = tester.view.physicalSize;
        // Registered before pumpApp, so it runs after pumpApp's own reset.
        addTearDown(() => expect(tester.view.physicalSize, defaultSize));

        await pumpApp(tester, const SizedBox(), screen: screen);

        expect(tester.view.physicalSize / tester.view.devicePixelRatio, screen.size);
      });
    }

    testWidgets('sets the text scale and resets it after the test', (tester) async {
      addTearDown(() => expect(tester.platformDispatcher.textScaleFactor, 1.0));

      await pumpApp(tester, const SizedBox(), textScale: 2.0);

      expect(tester.platformDispatcher.textScaleFactor, 2.0);
    });

    testWidgets('swaps storage and every remote data source for fakes', (tester) async {
      final container = await pumpApp(tester, const SizedBox());

      expect(container.read(localStorageProvider), isA<InMemoryStorage>());
      expect(container.read(appSettingsStorageProvider), isA<InMemoryStorage>());
      expect(container.read(authRemoteDataSourceProvider), isA<FakeAuthRemoteDataSource>());
      expect(container.read(profileRemoteDataSourceProvider), isA<FakeProfileRemoteDataSource>());
      expect(container.read(problemRemoteDataSourceProvider), isA<FakeProblemRemoteDataSource>());
    });

    testWidgets('is a guest session by default', (tester) async {
      final container = await pumpApp(tester, const SizedBox());

      expect(container.read(currentUserProvider)?.isGuest, isTrue);
      expect(container.read(problemRemoteDataSourceProvider).isSignedIn, isFalse);
    });

    testWidgets('signs in the given user', (tester) async {
      final user = buildTestUser();

      final container = await pumpApp(tester, const SizedBox(), signedInAs: user);

      expect(container.read(currentUserProvider), user);
      expect(container.read(problemRemoteDataSourceProvider).isSignedIn, isTrue);
    });

    testWidgets('pumps the app router when an initial route is given', (tester) async {
      await pumpApp(tester, const SizedBox(), initialRoute: '/no-such-page');
      await tester.pumpAndSettle();

      expect(find.text(StringsManager.unknownPage), findsOneWidget);
    });
  });

  group('testScreenMatrix', () {
    final seen = <String>{};

    tearDownAll(() => expect(seen, hasLength(12)));

    testScreenMatrix('runs once per combination', (tester, variant) async {
      seen.add(variant.toString());
    });
  });

  test('a variant reads like "smallPhone · dark · 2.0x"', () {
    expect(const ScreenVariant(ScreenSize.smallPhone, ThemeMode.dark, 2.0).toString(),
        'smallPhone · dark · 2.0x');
  });
}
