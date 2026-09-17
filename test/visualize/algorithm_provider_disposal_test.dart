import 'dart:async';

import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// The sorting and searching notifiers are handed out by auto-disposing
/// providers, so leaving the visualize tab releases them — possibly while an
/// animation loop is still awaiting between frames. These tests pin both halves
/// of that contract: the provider really is released once nothing watches it,
/// and a running loop notices and stops instead of writing to a dead notifier.
void main() {
  setUpAll(() {
    // Same reason as sorting_notifier_test.dart: non-widget tests never run
    // through ScreenUtilInit, but the position math reads ScreenUtil directly.
    ScreenUtil.configure(
      data: const MediaQueryData(size: Size(430, 932)),
      designSize: const Size(430, 932),
      splitScreenMode: false,
      minTextAdapt: false,
    );
  });

  test('a sorting provider is released once nothing listens to it', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final instance = BaseViewModel.sortingCards(SortingAlgoCards.bubble).instance;
    final subscription = container.listen(instance, (_, __) {});
    final notifier = container.read(instance.notifier);

    expect(notifier.isDisposed, isFalse);

    subscription.close();
    await container.pump();

    expect(notifier.isDisposed, isTrue, reason: 'the sorting provider is not auto-disposing');
  });

  test('a searching provider is released once nothing listens to it', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final instance = BaseViewModel.searchingCards(SearchingAlgoCards.bfs).instance;
    final subscription = container.listen(instance, (_, __) {});
    final notifier = container.read(instance.notifier);

    expect(notifier.isDisposed, isFalse);

    subscription.close();
    await container.pump();

    expect(notifier.isDisposed, isTrue, reason: 'the searching provider is not auto-disposing');
  });

  test('a sorting run stops instead of throwing when the provider is disposed', () async {
    SortingNotifier.debugInitialListOverride = SortingNotifier.initState().list;
    addTearDown(() => SortingNotifier.debugInitialListOverride = null);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final instance = BaseViewModel.sortingCards(SortingAlgoCards.bubble).instance;
    final subscription = container.listen(instance, (_, __) {});
    final notifier = container.read(instance.notifier);

    // `_startSelectedSorting` swallows failures into `debugPrint`, so an
    // unguarded write to the disposed notifier would never reach the zone —
    // it would only show up here.
    final logged = <String>[];
    final previousDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => logged.add(message ?? '');
    addTearDown(() => debugPrint = previousDebugPrint);

    Object? uncaught;

    await runZonedGuarded(() async {
      unawaited(notifier.togglePlay());
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(notifier.isPlaying, isTrue, reason: 'the run never started, so nothing is proven');

      // The visualize tab goes away mid-animation.
      subscription.close();
      await container.pump();
      expect(notifier.isDisposed, isTrue);

      // Long enough for every pending `await` inside the play loop to resume.
      await Future<void>.delayed(const Duration(milliseconds: 800));
    }, (error, stack) => uncaught ??= error);

    expect(uncaught, isNull, reason: 'the play loop threw after the provider was disposed');
    expect(
      logged.where((message) => message.contains('something wrong with sorting')),
      isEmpty,
      reason: 'the play loop kept writing to a disposed notifier',
    );
  });
}
