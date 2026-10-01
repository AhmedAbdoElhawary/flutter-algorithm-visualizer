import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/unsynced_problems.dart';
import 'package:algorithm_visualizer/features/challenge/data/repositories/problem_repository_impl.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_problem_remote_data_source.dart';
import '../../../../helpers/fakes/in_memory_storage.dart';
import '../../../../helpers/test_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProblemLocalDataSource local;
  late UnsyncedProblems unsynced;
  late FakeProblemRemoteDataSource remote;
  late ProblemRepositoryImpl repository;

  void build({required bool signedIn}) {
    final storage = InMemoryStorage();
    local = ProblemLocalDataSource(storage);
    unsynced = UnsyncedProblems(storage);
    remote = FakeProblemRemoteDataSource(isSignedIn: signedIn);
    repository = ProblemRepositoryImpl(local, remote, unsynced);
  }

  group('getAllProblems', () {
    setUp(() => build(signedIn: false));

    test('the whole dataset, with no progress when nothing is saved', () async {
      final problems = await repository.getAllProblems();

      expect(problems, hasLength(100));
      expect(problems.every((problem) => problem.problemStatus == null), isTrue);
    });

    test('saved progress is joined onto its problem by id', () async {
      await local.saveProblem(buildTestProblemStorage(problemId: 2, problemStatus: ProblemStatus.solved));

      final problems = await repository.getAllProblems();

      expect(problems.firstWhere((problem) => problem.problemId == 2).isSolved, isTrue);
      expect(problems.where((problem) => problem.isSolved), hasLength(1));
    });

    test('never touches the server', () async {
      await repository.getAllProblems();

      expect(remote.calls, isEmpty);
    });
  });

  for (final signedIn in [false, true]) {
    group(signedIn ? 'signed in' : 'as a guest', () {
      setUp(() => build(signedIn: signedIn));

      final problem = buildTestProblem(problemId: 4, isBookmarked: true);

      test('saving keeps it on the device${signedIn ? ' and marks it for upload' : ''}', () async {
        await repository.saveProblem(problem);

        expect(local.getProblem(4)?.isBookmarked, isTrue);
        expect(unsynced.needsToBeUploadedIds, signedIn ? [4] : isEmpty);
      });

      test('updating does the same', () async {
        await repository.updateProblem(problem.copyWith(problemStatus: ProblemStatus.attempted));

        expect(local.getProblem(4)?.problemStatus, ProblemStatus.attempted);
        expect(unsynced.needsToBeUploadedIds, signedIn ? [4] : isEmpty);
      });

      test('deleting removes it${signedIn ? ' and marks it for deletion' : ''}', () async {
        await repository.saveProblem(problem);

        await repository.deleteProblem(4);

        expect(local.getProblem(4), isNull);
        expect(unsynced.needsToBeDeletedIds, signedIn ? [4] : isEmpty);
        expect(unsynced.needsToBeUploadedIds, isEmpty);
      });

      test('never calls the server directly, the sync does that', () async {
        await repository.saveProblem(problem);
        await repository.deleteProblem(4);

        expect(remote.calls, isEmpty);
      });
    });
  }

  test('a problem without an id is refused and marks nothing', () async {
    build(signedIn: true);
    final noId = CodingProblem.fromJson({...buildTestProblem().toJson(), 'problem_id': null});

    await expectLater(repository.updateProblem(noId), throwsStateError);

    expect(local.getProblems(), isEmpty);
    expect(unsynced.hasAny, isFalse);
  });
}
