import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final run = ProblemSolutionStatusDTO(
    code: 'int f() => 1;',
    isCorrect: true,
    submittedAt: DateTime(2026, 9, 1, 14, 5),
    language: 'python',
  );

  group('ProblemStorageDTO', () {
    final saved = ProblemStorageDTO(
      problemId: 3,
      problemStatus: ProblemStatus.solved,
      isBookmarked: true,
      solutionsStatus: [run],
    );

    test('round trips through JSON', () {
      final again = ProblemStorageDTO.fromJson(saved.toJson());

      expect(again, saved);
      expect(again.hashCode, saved.hashCode);
      expect(again.solutionsStatus, [run]);
    });

    test('different runs make a different save', () {
      const other = ProblemStorageDTO(
        problemId: 3,
        problemStatus: ProblemStatus.solved,
        isBookmarked: true,
        solutionsStatus: [],
      );

      expect(other, isNot(saved));
    });

    test('a save from before any field existed still reads', () {
      final old = ProblemStorageDTO.fromJson(<String, dynamic>{'problem_id': 3});

      expect(old.problemId, 3);
      expect(old.problemStatus, isNull);
      expect(old.isBookmarked, isNull);
      expect(old.solutionsStatus, isNull);
    });

    test('a status this version does not know reads as none, keeping the rest', () {
      final json = saved.toJson()..['problem_status'] = 'mastered';

      final read = ProblemStorageDTO.fromJson(json);

      expect(read.problemStatus, isNull);
      expect(read.isBookmarked, isTrue);
      expect(read.solutionsStatus, hasLength(1));
    });
  });

  group('ProblemSolutionStatusDTO', () {
    test('round trips with its language', () {
      final again = ProblemSolutionStatusDTO.fromJson(run.toJson());

      expect(again, run);
      expect(again.hashCode, run.hashCode);
      expect(again.languageKey, 'python');
    });

    test('a run saved before languages existed reads as Dart', () {
      final old = ProblemSolutionStatusDTO.fromJson(<String, dynamic>{'code': 'x', 'is_correct': false});

      expect(old.language, isNull);
      expect(old.languageKey, 'dart');
      expect(old.submittedAt, isNull);
      expect(old, const ProblemSolutionStatusDTO(code: 'x', isCorrect: false, language: 'dart'));
    });
  });
}
