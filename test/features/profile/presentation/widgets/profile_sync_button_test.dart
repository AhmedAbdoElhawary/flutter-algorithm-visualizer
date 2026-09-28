import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/domain/services/problem_sync_service.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/sync_hint_store.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_sync_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_problem_remote_data_source.dart';
import '../../../../helpers/fakes/fake_problem_repository.dart';
import '../../../../helpers/fakes/in_memory_storage.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late InMemoryStorage hintStorage;

  setUp(() => hintStorage = InMemoryStorage());

  /// Never settles while the hint's border spins, so these tests pump by time instead.
  Future<ProviderContainer> pumpButton(WidgetTester tester, {bool signedIn = true, bool hintSeen = true}) async {
    if (hintSeen) await hintStorage.write(SyncHintStore.seenKey, true);
    final container = await pumpApp(
      tester,
      const Scaffold(body: Center(child: ProfileSyncButton())),
      overrides: [
        problemRepositoryProvider.overrideWithValue(FakeProblemRepository()),
        syncHintStoreProvider.overrideWithValue(SyncHintStore(hintStorage)),
      ],
      signedInAs: signedIn ? buildTestUser() : null,
    );
    await tester.pump();
    return container;
  }

  FakeProblemRemoteDataSource remoteOf(ProviderContainer container) =>
      container.read(problemRemoteDataSourceProvider) as FakeProblemRemoteDataSource;

  final syncIcon = find.byIcon(Icons.sync_rounded);
  final spinner = find.byType(CircularProgressIndicator);
  final unsyncedDot = find.byWidgetPredicate((widget) => widget.runtimeType.toString() == '_UnsyncedDot');

  /// The seconds left on the cooldown card. The cooldown runs on the real clock, so it is read, not assumed.
  int secondsLeft(WidgetTester tester) {
    final text = tester.widget<Text>(find.textContaining('You can sync again in')).data!;
    return int.parse(RegExp(r'in (\d+)s').firstMatch(text)!.group(1)!);
  }

  testWidgets('a guest has nothing to sync, so there is no button', (tester) async {
    await pumpButton(tester, signedIn: false);

    expect(syncIcon, findsNothing);
  });

  group('syncing', () {
    testWidgets('idle, then a spinner while it runs, then done', (tester) async {
      final container = await pumpButton(tester);
      remoteOf(container).delay = const Duration(seconds: 1);

      await tester.tap(syncIcon);
      await tester.pump();
      expect(spinner, findsOneWidget);
      expect(syncIcon, findsNothing);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(spinner, findsNothing);
      expect(syncIcon, findsOneWidget);
      expect(find.text(StringsManager.syncSuccess), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('tapping again while it runs is ignored', (tester) async {
      final container = await pumpButton(tester);
      final remote = remoteOf(container)..delay = const Duration(seconds: 1);

      await tester.tap(syncIcon);
      await tester.pump();
      await tester.tap(spinner, warnIfMissed: false);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(remote.calls, ['getProblems']);
      expect(find.text(StringsManager.syncFailure), findsNothing);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('a failed upload says so, keeps the unsynced mark, and a retry goes through', (tester) async {
      final container = await pumpButton(tester);
      await container.read(unsyncedProblemsProvider).needsToBeUploaded(1);
      container.read(problemSyncProvider.notifier).refreshUnsyncedFlag();
      await tester.pump();
      expect(unsyncedDot, findsOneWidget);

      remoteOf(container).failWith = Exception('offline');
      await tester.tap(syncIcon);
      await tester.pump();
      await tester.pump();

      expect(find.text(StringsManager.syncFailure), findsOneWidget);
      expect(unsyncedDot, findsOneWidget);

      await tester.tap(syncIcon);
      await tester.pump();
      await tester.pump();

      expect(find.text(StringsManager.syncSuccess), findsOneWidget);
      expect(unsyncedDot, findsNothing);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  group('the cooldown', () {
    Future<ProviderContainer> syncOnce(WidgetTester tester) async {
      final container = await pumpButton(tester);
      await tester.tap(syncIcon);
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      return container;
    }

    testWidgets('a second sync too soon shows how long to wait, and does not call the server', (tester) async {
      final container = await syncOnce(tester);
      final calls = remoteOf(container).calls.length;

      await tester.tap(syncIcon);
      await tester.pump();

      expect(find.text(StringsManager.syncCooldownTitle), findsOneWidget);
      expect(secondsLeft(tester), inInclusiveRange(1, ProblemSyncService.cooldown.inSeconds));
      expect(remoteOf(container).calls, hasLength(calls));

      await tester.tap(find.text(StringsManager.syncCooldownConfirm));
      await tester.pumpAndSettle();
      expect(find.text(StringsManager.syncCooldownTitle), findsNothing);
    });

    testWidgets('the card counts down and closes itself', (tester) async {
      await syncOnce(tester);

      await tester.tap(syncIcon);
      await tester.pump();
      final start = secondsLeft(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(secondsLeft(tester), start - 1);

      // A second at a time, with a frame between ticks like on a phone.
      for (var i = 1; i < start; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();
      expect(find.text(StringsManager.syncCooldownTitle), findsNothing);
    });

    testWidgets('leaving the page stops its countdown', (tester) async {
      await syncOnce(tester);
      await tester.tap(syncIcon);
      await tester.pump();

      // A timer still running after this fails the test.
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('the first-time hint', () {
    testWidgets('shows on a first visit, then fades and counts as seen after ten seconds', (tester) async {
      await pumpButton(tester, hintSeen: false);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(StringsManager.syncHint), findsOneWidget);
      expect(SyncHintStore(hintStorage).isSeen, isFalse);

      await tester.pump(const Duration(seconds: 10));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(StringsManager.syncHint), findsNothing);
      expect(SyncHintStore(hintStorage).isSeen, isTrue);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('tapping the button dismisses it at once', (tester) async {
      await pumpButton(tester, hintSeen: false);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(syncIcon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(StringsManager.syncHint), findsNothing);
      expect(SyncHintStore(hintStorage).isSeen, isTrue);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('stays hidden once seen', (tester) async {
      await pumpButton(tester);
      await tester.pumpAndSettle();

      expect(find.text(StringsManager.syncHint), findsNothing);
    });

    testWidgets('leaving before the ten seconds are up does not count it as seen', (tester) async {
      await pumpButton(tester, hintSeen: false);
      await tester.pump(const Duration(seconds: 2));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 10));

      expect(SyncHintStore(hintStorage).isSeen, isFalse);
    });
  });
}
