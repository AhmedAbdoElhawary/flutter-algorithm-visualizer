import 'dart:math' as math;

import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/search_contract.dart';

final _algorithms = <String, SearchingNotifier Function()>{
  'bfs': BFSSearchingNotifier.new,
  'dfs': DFSSearchingNotifier.new,
  'a*': AStarSearchingNotifier.new,
};

/// A container plus the provider it holds, torn down after each test.
class _Harness {
  _Harness(SearchingNotifier Function() create)
      : provider = NotifierProvider<SearchingNotifier, SearchingState>(create),
        container = ProviderContainer();

  final NotifierProvider<SearchingNotifier, SearchingState> provider;
  final ProviderContainer container;

  SearchingNotifier get notifier => container.read(provider.notifier);
  SearchingState get state => container.read(provider);

  /// Builds the steps and stops playback immediately, so no timer survives.
  void run() {
    notifier.togglePlay();
    notifier.stepBackward();
  }

  void dispose() => container.dispose();
}

void main() {
  group('playback clauses P1–P6 (FR-013, FR-014, FR-016, SC-005)', () {
    for (final entry in _algorithms.entries) {
      group(entry.key, () {
        late _Harness harness;

        setUp(() => harness = _Harness(entry.value));
        tearDown(() => harness.dispose());

        test('P1: before any run both buttons are disabled', () {
          expect(harness.state.hasSteps, isFalse);
          expect(harness.notifier.backwardValidation, isFalse);
          expect(harness.notifier.forwardValidation, isFalse);
        });

        test('P2: at index 0 Previous is disabled and Next is enabled', () {
          harness.run();

          expect(harness.state.stepIndex, 0);
          expect(harness.notifier.backwardValidation, isFalse);
          expect(harness.notifier.forwardValidation, isTrue);
        });

        test('P3: at the final index Next is disabled and Previous is enabled', () {
          harness.run();
          final total = harness.state.steps!.length;
          for (int i = 0; i < total; i++) {
            harness.notifier.stepForward();
          }

          expect(harness.state.stepIndex, total - 1);
          expect(harness.notifier.forwardValidation, isFalse);
          expect(harness.notifier.backwardValidation, isTrue);
        });

        test('P4: each press moves exactly one step and stops playback', () {
          harness.run();

          for (int i = 1; i < 6; i++) {
            harness.notifier.stepForward();
            expect(harness.state.stepIndex, i);
            expect(harness.state.playing, isFalse);
          }
          for (int i = 4; i >= 0; i--) {
            harness.notifier.stepBackward();
            expect(harness.state.stepIndex, i);
            expect(harness.state.playing, isFalse);
          }
        });

        test('P5: stepping backward restores the exact earlier visited/frontier split', () {
          harness.run();
          for (int i = 0; i < 5; i++) {
            harness.notifier.stepForward();
          }
          final atFive = harness.state.currentStep!;

          harness.notifier.stepForward();
          harness.notifier.stepForward();
          harness.notifier.stepBackward();
          harness.notifier.stepBackward();

          final backAtFive = harness.state.currentStep!;
          expect(harness.state.stepIndex, 5);
          expect(sameCells(backAtFive.visited, atFive.visited), isTrue);
          expect(sameCells(backAtFive.frontier, atFive.frontier), isTrue);
        });

        test('P6: hammering the buttons at either boundary never moves past the ends', () {
          harness.run();
          final total = harness.state.steps!.length;

          for (int i = 0; i < 20; i++) {
            harness.notifier.stepBackward();
            expect(harness.state.stepIndex, 0);
          }

          for (int i = 0; i < total + 20; i++) {
            harness.notifier.stepForward();
          }
          for (int i = 0; i < 20; i++) {
            harness.notifier.stepForward();
            expect(harness.state.stepIndex, total - 1);
          }
        });

        test('SC-004: steps.length equals the positions Next can actually reach', () {
          harness.run();
          final total = harness.state.steps!.length;

          final reached = <int>{harness.state.stepIndex};
          while (harness.notifier.forwardValidation) {
            harness.notifier.stepForward();
            reached.add(harness.state.stepIndex);
          }

          expect(reached.length, total);
        });
      });
    }
  });

  group('stroke clauses S1–S3 (FR-019, FR-020)', () {
    late _Harness harness;

    setUp(() => harness = _Harness(BFSSearchingNotifier.new));
    tearDown(() => harness.dispose());

    test('S1: a stroke starting on an open cell draws for its whole length', () {
      harness.notifier.setWall(5, 5, isGestureStart: true);
      for (int c = 6; c <= 10; c++) {
        harness.notifier.setWall(5, c, isGestureStart: false);
      }

      for (int c = 5; c <= 10; c++) {
        expect(harness.state.walls[5][c], isTrue, reason: 'cell (5, $c)');
      }
    });

    test('S1: a stroke starting on a wall erases for its whole length', () {
      harness.notifier.setWall(5, 5, isGestureStart: true);
      for (int c = 6; c <= 10; c++) {
        harness.notifier.setWall(5, c, isGestureStart: false);
      }

      harness.notifier.setWall(5, 5, isGestureStart: true);
      for (int c = 6; c <= 10; c++) {
        harness.notifier.setWall(5, c, isGestureStart: false);
      }

      for (int c = 5; c <= 10; c++) {
        expect(harness.state.walls[5][c], isFalse, reason: 'cell (5, $c)');
      }
    });

    test('S2: a multi-cell jump fills the gap between the reported points', () {
      harness.notifier.setWall(5, 5, isGestureStart: true);
      harness.notifier.setWall(5, 20, isGestureStart: false);

      for (int c = 5; c <= 20; c++) {
        expect(harness.state.walls[5][c], isTrue, reason: 'cell (5, $c)');
      }
    });

    test('S2: a diagonal jump fills a connected line', () {
      harness.notifier.setWall(2, 2, isGestureStart: true);
      harness.notifier.setWall(9, 9, isGestureStart: false);

      final drawn = <int>[];
      for (int r = 0; r < kPFRows; r++) {
        for (int c = 0; c < kPFCols; c++) {
          if (harness.state.walls[r][c]) drawn.add(pfEncode(r, c));
        }
      }

      expect(drawn.length, 8);
      expect(drawn.first, pfEncode(2, 2));
      expect(drawn.last, pfEncode(9, 9));
    });

    test('S3: re-crossing a cell within one stroke does not toggle it back', () {
      harness.notifier.setWall(5, 5, isGestureStart: true);
      for (int c = 6; c <= 10; c++) {
        harness.notifier.setWall(5, c, isGestureStart: false);
      }
      for (int c = 9; c >= 5; c--) {
        harness.notifier.setWall(5, c, isGestureStart: false);
      }

      for (int c = 5; c <= 10; c++) {
        expect(harness.state.walls[5][c], isTrue, reason: 'cell (5, $c)');
      }
    });

    test('a stroke never draws over either marker', () {
      final startRow = harness.state.startRow;
      harness.notifier.setWall(startRow, 0, isGestureStart: true);
      harness.notifier.setWall(startRow, kPFCols - 1, isGestureStart: false);

      expect(harness.state.walls[startRow][harness.state.startCol], isFalse);
      expect(harness.state.walls[harness.state.endRow][harness.state.endCol], isFalse);
    });
  });

  group('edit clauses E1–E5 (FR-012, FR-021, FR-022, SC-013)', () {
    late _Harness harness;

    setUp(() => harness = _Harness(BFSSearchingNotifier.new));
    tearDown(() => harness.dispose());

    test('E1: drawing a wall while a result is displayed clears it and still applies the edit', () {
      harness.run();
      expect(harness.state.hasSteps, isTrue);

      harness.notifier.setWall(5, 5, isGestureStart: true);

      expect(harness.state.hasSteps, isFalse);
      expect(harness.state.walls[5][5], isTrue);
    });

    test('E2: a marker is pinned while a result is displayed, and moves again after reset', () {
      harness.run();
      final (row, col) = (harness.state.startRow, harness.state.startCol);

      harness.notifier.setStartPoint(3, 3);

      // The answer on screen belongs to the maze that produced it, so the
      // start cannot be dragged out from under it.
      expect(harness.state.hasSteps, isTrue);
      expect((harness.state.startRow, harness.state.startCol), (row, col));

      harness.notifier.reset();
      harness.notifier.setStartPoint(3, 3);

      expect((harness.state.startRow, harness.state.startCol), (3, 3));
    });

    test('E3: clearing and randomizing walls both clear a displayed result', () {
      harness.run();
      harness.notifier.clearWalls();
      expect(harness.state.hasSteps, isFalse);

      harness.run();
      harness.notifier.randomizeWalls();
      expect(harness.state.hasSteps, isFalse);
    });

    test('E4: a marker rubs out a wall it lands on, but is refused onto the other marker', () {
      harness.notifier.setWall(3, 3, isGestureStart: true);
      expect(harness.state.walls[3][3], isTrue);

      harness.notifier.setStartPoint(3, 3);
      expect((harness.state.startRow, harness.state.startCol), (3, 3));
      expect(harness.state.walls[3][3], isFalse);

      harness.notifier.setStartPoint(harness.state.endRow, harness.state.endCol);
      expect(
        (harness.state.startRow, harness.state.startCol),
        isNot((harness.state.endRow, harness.state.endCol)),
      );
    });

    test('E6: no wall may be drawn while the search is playing', () {
      harness.notifier.togglePlay();
      expect(harness.notifier.isPlaying, isTrue);

      harness.notifier.setWall(5, 5, isGestureStart: true);

      expect(harness.state.walls[5][5], isFalse);
      expect(harness.state.hasSteps, isTrue);

      // Pausing hands the grid back, and the edit clears the stale result.
      harness.notifier.togglePlay();
      harness.notifier.setWall(5, 5, isGestureStart: true);

      expect(harness.state.walls[5][5], isTrue);
      expect(harness.state.hasSteps, isFalse);
    });

    test('E5: dragging a marker draws no walls', () {
      final before = harness.state.walls;
      for (int c = 6; c <= 12; c++) {
        harness.notifier.setStartPoint(12, c);
      }

      expect(harness.state.startCol, 12);
      for (int r = 0; r < kPFRows; r++) {
        for (int c = 0; c < kPFCols; c++) {
          expect(harness.state.walls[r][c], before[r][c], reason: 'cell ($r, $c)');
        }
      }
    });

    test('randomized walls never land on either marker', () {
      for (int i = 0; i < 20; i++) {
        harness.notifier.randomizeWalls();
        final state = harness.state;
        expect(state.walls[state.startRow][state.startCol], isFalse);
        expect(state.walls[state.endRow][state.endCol], isFalse);
      }
    });
  });

  group('the grid input carries the learner\'s markers (FR-001)', () {
    late _Harness harness;

    setUp(() => harness = _Harness(BFSSearchingNotifier.new));
    tearDown(() => harness.dispose());

    test('a run after moving both markers searches between the placed ones', () {
      harness.notifier.setStartPoint(2, 2);
      harness.notifier.setEndPoint(20, 27);
      harness.run();

      final steps = harness.state.steps!;
      expect(steps.first.frontier, {pfEncode(2, 2)});
      expect(steps.last.path!.last, pfEncode(20, 27));
    });
  });

  test('the same seed gives the same random walls', () {
    List<List<bool>> randomWalls() {
      final harness = _Harness(() => BFSSearchingNotifier(random: math.Random(1)));
      addTearDown(harness.dispose);
      harness.notifier.randomizeWalls();
      return harness.state.walls;
    }

    expect(randomWalls(), randomWalls());
  });

  group('playback', () {
    final step = PlaybackSpeed.normal.stepSearchingDuration;
    late _Harness harness;

    setUp(() => harness = _Harness(BFSSearchingNotifier.new));

    // A running timer left behind fails a widget test, so every test ends here.
    Future<void> finish(WidgetTester tester) async {
      harness.dispose();
      await tester.pump(const Duration(minutes: 10));
    }

    Future<void> playToTheEnd(WidgetTester tester) async {
      await harness.notifier.togglePlay();
      await tester.pump(const Duration(minutes: 10));
    }

    testWidgets('play runs to the end and stops', (tester) async {
      await playToTheEnd(tester);

      expect(harness.state.isAtEnd, isTrue);
      expect(harness.state.playing, isFalse);
      expect(harness.state.currentStep!.phase, PFPhase.found);
      await finish(tester);
    });

    testWidgets('pause stops the steps', (tester) async {
      await harness.notifier.togglePlay();
      await tester.pump(step * 3);
      await harness.notifier.togglePlay();
      final pausedAt = harness.state.stepIndex;

      await tester.pump(step * 10);

      expect(harness.state.playing, isFalse);
      expect(harness.state.stepIndex, pausedAt);
      await finish(tester);
    });

    testWidgets('step forward moves one step and pauses', (tester) async {
      await harness.notifier.togglePlay();
      harness.notifier.stepForward();

      expect(harness.state.stepIndex, 1);
      expect(harness.state.playing, isFalse);
      await tester.pump(step * 5);
      expect(harness.state.stepIndex, 1);
      await finish(tester);
    });

    testWidgets('a speed change applies from the next step', (tester) async {
      await harness.notifier.togglePlay();
      await tester.pump(step ~/ 3);

      // The speed button moves to the next speed, here normal to fast3.
      harness.notifier.changeSpeed(harness.state.speed);
      final fast = PlaybackSpeed.fast3.stepSearchingDuration;
      expect(harness.state.speed, PlaybackSpeed.fast3);

      await tester.pump(fast);
      expect(harness.state.stepIndex, 1);
      await tester.pump(fast * 2);
      expect(harness.state.stepIndex, 3);
      await finish(tester);
    });

    testWidgets('reset while playing clears the run, and nothing moves after', (tester) async {
      await harness.notifier.togglePlay();
      await tester.pump(step * 3);

      harness.notifier.reset();
      await tester.pump(step * 10);

      expect(harness.state.hasSteps, isFalse);
      expect(harness.state.stepIndex, 0);
      expect(harness.state.playing, isFalse);
      await finish(tester);
    });

    testWidgets('play after the end starts again from the first step', (tester) async {
      await playToTheEnd(tester);

      await harness.notifier.togglePlay();
      expect(harness.state.stepIndex, 0);
      expect(harness.state.playing, isTrue);

      await tester.pump(const Duration(minutes: 10));
      expect(harness.state.isAtEnd, isTrue);
      await finish(tester);
    });

    testWidgets('fast play and pause taps still run only one timer', (tester) async {
      for (var tap = 0; tap < 5; tap++) {
        await harness.notifier.togglePlay();
      }
      expect(harness.state.playing, isTrue);

      await tester.pump(step);

      expect(harness.state.stepIndex, 1, reason: 'two timers would move two steps per tick');
      await finish(tester);
    });

    testWidgets('disposing mid-run stops the timer', (tester) async {
      final notifier = harness.notifier;
      await notifier.togglePlay();
      await tester.pump(step * 2);

      harness.dispose();

      expect(notifier.isDisposed, isTrue);
      await tester.pump(step * 10);
      expect(tester.takeException(), isNull);
    });
  });
}
