import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderChannel,
      (call) async {
        switch (call.method) {
          case 'getApplicationDocumentsDirectory':
            return '/tmp/algorithm_visualizer_problem_local_data_source_test';

          default:
            return null;
        }
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderChannel,
      null,
    );
  });

  late GetStorage getStorage;
  late GetStorageService storage;
  late ProblemLocalDataSource dataSource;

  setUp(() async {
    await GetStorage.init('problem_local_data_source_test');

    getStorage = GetStorage('problem_local_data_source_test');

    await getStorage.erase();

    storage = GetStorageService(getStorage);
    dataSource = ProblemLocalDataSource(storage);
  });

  tearDown(() async {
    await getStorage.erase();
  });

  group('ProblemLocalDataSource', () {
    group('loadProblemsAssets()', () {
      test('loads problems from the problems asset', () async {
        final dataset = await dataSource.loadProblemsAssets();

        expect(dataset, isNotNull);
      });

      test('loads a dataset containing problems', () async {
        final dataset = await dataSource.loadProblemsAssets();

        expect(dataset.problems, isNotEmpty);
      });

      test('loads the expected dataset size', () async {
        final dataset = await dataSource.loadProblemsAssets();

        expect(dataset.problems?.length, dataset.totalProblems);
      });
    });

    group('getProblems() that saved in local storage', () {
      test('returns an empty list when no problems are stored', () {
        final result = dataSource.getProblems();

        expect(result, isEmpty);
      });

      test('returns all stored problems', () async {
        final problem1 = _createProblem(problemId: 1);
        final problem2 = _createProblem(problemId: 2);

        // to be separated if saved problem brooked
        await storage.write(
          'problems',
          [
            problem1.toJson(),
            problem2.toJson(),
          ],
        );

        final result = dataSource.getProblems();

        expect(result, [problem1, problem2]);
      });

      test('correctly deserializes stored problems', () async {
        final problem = _createProblem(
          problemId: 10,
          problemStatus: ProblemStatus.solved,
          isBookmarked: true,
        );
        // to be separated if saved problem brooked

        await storage.write(
          'problems',
          [problem.toJson()],
        );

        final result = dataSource.getProblems();

        expect(result.length, 1);
        expect(result.first.problemId, 10);
        expect(
          result.first.problemStatus,
          ProblemStatus.solved,
        );
        expect(result.first.isBookmarked, true);
      });

      test('returns a new list containing stored problems', () async {
        final problem = _createProblem(problemId: 1);
        // to be separated if saved problem brooked

        await storage.write(
          'problems',
          [problem.toJson()],
        );

        final firstResult = dataSource.getProblems();
        final secondResult = dataSource.getProblems();

        expect(firstResult, secondResult);
      });
    });

    group('getProblem()', () {
      test('returns the problem with the requested ID', () async {
        final problem1 = _createProblem(problemId: 1);
        final problem2 = _createProblem(problemId: 2);
        // to be separated if saved problem brooked

        await storage.write(
          'problems',
          [
            problem1.toJson(),
            problem2.toJson(),
          ],
        );

        final result = dataSource.getProblem(2);

        expect(result, problem2);
      });

      test('returns null when the problem does not exist', () async {
        await dataSource.saveProblem(
          _createProblem(problemId: 1),
        );

        final result = dataSource.getProblem(999);

        expect(result, isNull);
      });

      test('returns the first matching problem', () async {
        final problem = _createProblem(problemId: 1);
        // to be separated if saved problem brooked

        await storage.write(
          'problems',
          [problem.toJson()],
        );

        final result = dataSource.getProblem(1);

        expect(result, problem);
      });
    });

    group('saveProblem()', () {
      test('saves a new problem', () async {
        final problem = _createProblem(problemId: 1);

        await dataSource.saveProblem(problem);

        expect(dataSource.getProblems(), [problem]);
      });

      test('saves multiple different problems', () async {
        final problem1 = _createProblem(problemId: 1);
        final problem2 = _createProblem(problemId: 2);
        final problem3 = _createProblem(problemId: 3);

        await dataSource.saveProblem(problem1);
        await dataSource.saveProblem(problem2);
        await dataSource.saveProblem(problem3);

        expect(
          dataSource.getProblems(),
          [
            problem1,
            problem2,
            problem3,
          ],
        );
      });

      test('throws StateError when saving a duplicate problem ID', () async {
        final problem = _createProblem(problemId: 1);

        await dataSource.saveProblem(problem);

        await expectLater(
          dataSource.saveProblem(problem),
          throwsA(isA<StateError>()),
        );
      });

      test('duplicate problem is not added to storage', () async {
        final problem = _createProblem(problemId: 1);

        await dataSource.saveProblem(problem);

        try {
          await dataSource.saveProblem(problem);
        } catch (e) {
          //
        }

        expect(dataSource.getProblems(), [problem]);
      });

      test('keeps existing problems when adding a new problem', () async {
        final existingProblem = _createProblem(problemId: 1);
        final newProblem = _createProblem(problemId: 2);

        await dataSource.saveProblem(existingProblem);

        await dataSource.saveProblem(newProblem);

        expect(
          dataSource.getProblems(),
          [existingProblem, newProblem],
        );
      });

      test('supports a null problemId', () async {
        const problem = ProblemStorageDTO(
          problemId: null,
          problemStatus: ProblemStatus.none,
          isBookmarked: false,
          solutionsStatus: [],
        );

        await expectLater(dataSource.saveProblem(problem), throwsA(isA<StateError>()));
      });
    });

    group('updateProblem()', () {
      test('updates an existing problem', () async {
        final original = _createProblem(
          problemId: 1,
          problemStatus: ProblemStatus.none,
          isBookmarked: false,
        );

        final updated = _createProblem(
          problemId: 1,
          problemStatus: ProblemStatus.solved,
          isBookmarked: true,
        );

        await dataSource.saveProblem(original);

        await dataSource.updateProblem(updated);

        expect(dataSource.getProblems(), [updated]);
      });

      test('updates only the matching problem', () async {
        final firstProblem = _createProblem(problemId: 1);
        final secondProblem = _createProblem(
          problemId: 2,
          problemStatus: ProblemStatus.none,
          isBookmarked: false,
        );

        final updatedSecondProblem = _createProblem(
          problemId: 2,
          problemStatus: ProblemStatus.solved,
          isBookmarked: true,
        );

        await dataSource.saveProblem(firstProblem);
        await dataSource.saveProblem(secondProblem);

        await dataSource.updateProblem(updatedSecondProblem);

        expect(
          dataSource.getProblems(),
          [
            firstProblem,
            updatedSecondProblem,
          ],
        );
      });

      test('inserts the problem when it does not already exist', () async {
        final problem = _createProblem(problemId: 1);

        await dataSource.updateProblem(problem);

        expect(dataSource.getProblems(), [problem]);
      });

      test('does not create a duplicate when updating an existing problem', () async {
        final original = _createProblem(problemId: 1);

        final updated = _createProblem(
          problemId: 1,
          problemStatus: ProblemStatus.solved,
        );

        await dataSource.saveProblem(original);

        await dataSource.updateProblem(updated);

        expect(dataSource.getProblems().length, 1);
        expect(dataSource.getProblem(1), updated);
      });

      test('preserves the order of problems when updating', () async {
        final first = _createProblem(problemId: 1);
        final second = _createProblem(problemId: 2);
        final third = _createProblem(problemId: 3);

        final updatedSecond = _createProblem(problemId: 2, problemStatus: ProblemStatus.solved);

        await dataSource.saveProblem(first);
        await dataSource.saveProblem(second);
        await dataSource.saveProblem(third);

        await dataSource.updateProblem(updatedSecond);

        expect(
          dataSource.getProblems().map((problem) => problem.problemId),
          [1, 2, 3],
        );
      });
    });

    group('deleteProblem()', () {
      test('deletes an existing problem', () async {
        final problem = _createProblem(problemId: 1);

        await dataSource.saveProblem(problem);

        await dataSource.deleteProblem(1);

        expect(dataSource.getProblems(), isEmpty);
      });

      test('deletes only the matching problem', () async {
        final first = _createProblem(problemId: 1);
        final second = _createProblem(problemId: 2);
        final third = _createProblem(problemId: 3);

        await dataSource.saveProblem(first);
        await dataSource.saveProblem(second);
        await dataSource.saveProblem(third);

        await dataSource.deleteProblem(2);

        expect(
          dataSource.getProblems(),
          [
            first,
            third
          ],
        );
      });

      test('does nothing when the problem does not exist', () async {
        final problem = _createProblem(problemId: 1);

        await dataSource.saveProblem(problem);

        await dataSource.deleteProblem(999);

        expect(dataSource.getProblems(), [problem]);
      });

      test('can delete the first problem', () async {
        final first = _createProblem(problemId: 1);
        final second = _createProblem(problemId: 2);

        await dataSource.saveProblem(first);
        await dataSource.saveProblem(second);

        await dataSource.deleteProblem(1);

        expect(
          dataSource.getProblems(),
          [second],
        );
      });

      test('can delete the last problem', () async {
        final first = _createProblem(problemId: 1);
        final second = _createProblem(problemId: 2);

        await dataSource.saveProblem(first);
        await dataSource.saveProblem(second);

        await dataSource.deleteProblem(2);

        expect(
          dataSource.getProblems(),
          [first],
        );
      });
    });
  });
}

ProblemStorageDTO _createProblem({
  int? problemId = 1,
  ProblemStatus? problemStatus = ProblemStatus.none,
  bool? isBookmarked = false,
  List<ProblemSolutionStatusDTO>? solutionsStatus,
}) {
  return ProblemStorageDTO(
    problemId: problemId,
    problemStatus: problemStatus,
    isBookmarked: isBookmarked,
    solutionsStatus: solutionsStatus ?? const [],
  );
}
