import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart' show EditorLanguage;
import 'package:algorithm_visualizer/features/challenge/data/models/custom_object.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/function_signature.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_data.dart';

void main() {
  const signature = FunctionSignature(generic: 'f(x)', dart: 'int f(int x)');

  group('missing fields read as safe defaults', () {
    final empty = CodingProblem.fromJson(<String, dynamic>{});

    test('numbers, text and lists', () {
      expect(empty.getNumber, -1);
      expect(empty.getProblemId, -1);
      expect(empty.getSourceProblemNumber, -1);
      expect(empty.getName, '');
      expect(empty.getSource, '');
      expect(empty.getCategory, '');
      expect(empty.getDescription, '');
      expect(empty.getExpectedTimeComplexity, '');
      expect(empty.getExpectedSpaceComplexity, '');
      expect(empty.getWhatYouLearn, '');
      expect(empty.getKeyPattern, '');
      for (final list in [
        empty.getTags,
        empty.getPatterns,
        empty.getConstraints,
        empty.getExamples,
        empty.getEdgeCases,
        empty.getTestCases,
        empty.getHiddenTestCases,
        empty.getHints,
        empty.getPrerequisites,
        empty.getFollowUpConcepts,
        empty.getCommonMistakes,
        empty.getSimilarQuestions,
        empty.getCustomObjects,
        empty.getSolutionsStatus,
      ]) {
        expect(list, isEmpty);
      }
      expect(empty.getSolutionApproach, isNull);
    });

    test('progress', () {
      expect(empty.getDifficulty, ProblemDifficulty.none);
      expect(empty.getProblemStatus, ProblemStatus.none);
      expect(empty.isSolved, isFalse);
      expect(empty.getIsBookmarked, isFalse);
      expect(empty.isThereAnyCorrectCodeSaved, isFalse);
    });

    test('code: no signature means no starter code', () {
      expect(empty.getFunctionInDart, '');
      expect(empty.getDefaultCode, '');
      expect(empty.getCode, '');
      expect(empty.languagesAvailable, [EditorLanguage.dart]);
    });
  });

  group('starter code and languages', () {
    test('Dart without starter code falls back to a stub from the signature', () {
      final problem = buildTestProblem().copyWith(functionSignature: signature);

      expect(problem.getDefaultCodeFor(EditorLanguage.dart), 'int f(int x){\n\n}');
      expect(problem.getDefaultCodeFor(EditorLanguage.python), '');
    });

    test('only languages with starter code are offered, Dart always', () {
      final problem = buildTestProblem().copyWith(
        defaultCode: {'python': 'def f(x):\n', 'javascript': '   '},
      );

      expect(problem.languagesAvailable, [EditorLanguage.dart, EditorLanguage.python]);
      expect(problem.supportsLanguage(EditorLanguage.javascript), isFalse);
    });

    test('the editor opens with the newest saved draft for that language, else the starter code', () {
      final problem = buildTestProblem(
        solutions: [
          const ProblemSolutionStatusDTO(code: 'newest dart', isCorrect: false),
          const ProblemSolutionStatusDTO(code: 'older dart', isCorrect: true),
          const ProblemSolutionStatusDTO(code: '', isCorrect: false, language: 'python'),
        ],
      ).copyWith(defaultCode: {'dart': 'starter', 'python': 'py starter'});

      expect(problem.getCode, 'newest dart');
      expect(problem.solutionFor(EditorLanguage.python)?.code, '');
      expect(problem.getCodeFor(EditorLanguage.python), 'py starter', reason: 'an empty draft is no draft');
      expect(problem.isThereAnyCorrectCodeSaved, isTrue);
    });

    test('custom objects are the Dart ones', () {
      final problem = buildTestProblem().copyWith(customObjects: {
        'dart': [CustomObject(code: 'class A {}')],
        'python': [CustomObject(code: 'class B: pass')],
      });

      expect(problem.getCustomObjects.single.getCode, 'class A {}');
    });
  });

  group('copyWith, JSON and equality', () {
    final problem = buildTestProblem(problemStatus: ProblemStatus.attempted, isBookmarked: true);

    test('copyWith changes only what it is given', () {
      final solved = problem.copyWith(problemStatus: ProblemStatus.solved);

      expect(solved.isSolved, isTrue);
      expect(solved.getIsBookmarked, isTrue);
      expect(solved.getName, problem.getName);
      expect(problem.copyWith(), problem);
    });

    test('round trips through JSON', () {
      final again = CodingProblem.fromJson(problem.toJson());

      expect(again, problem);
      expect(again.hashCode, problem.hashCode);
    });

    test('progress makes problems different', () {
      expect(problem.copyWith(isBookmarked: false), isNot(problem));
      expect(problem.copyWith(problemStatus: ProblemStatus.solved), isNot(problem));
    });
  });

  test('the name with the language name in it', () {
    expect(buildTestProblem(name: 'Two Sum').getNameWithLanguageName, isA<String>());
  });
}
