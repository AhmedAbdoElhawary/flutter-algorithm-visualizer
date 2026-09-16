// The overlay only matters if it survives the whole trip: asset -> merge ->
// DTO -> domain entity. `problems_overlay_test.dart` checks the file is
// well-formed; this checks the loader actually uses it, and — the part worth
// guarding — that it leaves the grader's inputs alone while doing so.

import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_dto.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoStorage implements LocalStorage {
  @override
  Future<void> write<T>(String key, T value) async {}

  @override
  T? read<T>(String key) => null;

  @override
  Future<void> remove(String key) async {}

  @override
  Future<void> clear() async {}

  @override
  bool has(String key) => false;
}

/// True when the text contains at least one Arabic letter.
bool _isArabic(String? text) => text != null && RegExp(r'[؀-ۿ]').hasMatch(text);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProblemLocalDataSource source;
  late List<ProblemDTO> english;
  late List<ProblemDTO> arabic;

  setUpAll(() async {
    source = ProblemLocalDataSource(_NoStorage());
    english = (await source.loadProblemsAssets()).problems!;
    arabic = (await source.loadProblemsAssets(arabic: true)).problems!;
  });

  test('both languages load the same 100 problems, in the same order', () {
    expect(english.length, 100);
    expect(arabic.length, english.length);
    for (var i = 0; i < english.length; i++) {
      expect(arabic[i].problemId, english[i].problemId);
    }
  });

  test('every description and hint comes back in Arabic', () {
    for (final problem in arabic) {
      expect(_isArabic(problem.description), isTrue,
          reason: 'problem ${problem.problemId} still has an English description');

      for (final hint in problem.hints ?? const <String>[]) {
        expect(_isArabic(hint), isTrue,
            reason: 'problem ${problem.problemId} still has an English hint: "$hint"');
      }
    }
  });

  test('nothing the grader reads changes between the two languages', () {
    // If this ever fails, a correct solution has become wrong for Arabic
    // readers — which is the one failure mode that would make the whole
    // overlay a bad idea.
    for (var i = 0; i < english.length; i++) {
      final en = english[i];
      final ar = arabic[i];
      final id = en.problemId;

      expect(ar.name, en.name, reason: 'problem $id: the name must stay English');
      expect(ar.constraints, en.constraints, reason: 'problem $id: constraints changed');
      expect(ar.difficulty, en.difficulty, reason: 'problem $id: difficulty changed');
      expect(ar.tags, en.tags, reason: 'problem $id: tags changed');

      expect(ar.testCases?.length, en.testCases?.length, reason: 'problem $id: test case count');
      for (var t = 0; t < (en.testCases?.length ?? 0); t++) {
        expect(ar.testCases![t].input, en.testCases![t].input, reason: 'problem $id: test $t input');
        expect(ar.testCases![t].expectedOutput, en.testCases![t].expectedOutput,
            reason: 'problem $id: test $t expected output');
      }

      for (var t = 0; t < (en.hiddenTestCases?.length ?? 0); t++) {
        expect(ar.hiddenTestCases![t].expectedOutput, en.hiddenTestCases![t].expectedOutput,
            reason: 'problem $id: hidden test $t expected output');
      }

      // Examples keep their literals; only the prose explanation is replaced.
      for (var e = 0; e < (en.examples?.length ?? 0); e++) {
        expect(ar.examples![e].input, en.examples![e].input, reason: 'problem $id: example $e input');
        expect(ar.examples![e].output, en.examples![e].output, reason: 'problem $id: example $e output');
      }
    }
  });

  test('English still loads as English when the overlay is not asked for', () {
    for (final problem in english) {
      expect(_isArabic(problem.description), isFalse,
          reason: 'problem ${problem.problemId} leaked Arabic into the English load');
    }
  });
}
