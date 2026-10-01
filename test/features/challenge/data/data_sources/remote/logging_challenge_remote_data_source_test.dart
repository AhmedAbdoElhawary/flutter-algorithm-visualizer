import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/logging_challenge_remote_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_problem_remote_data_source.dart';
import '../../../../../helpers/test_data.dart';

void main() {
  late FakeProblemRemoteDataSource source;
  late LoggingProblemRemoteDataSource logging;

  for (final enabled in [false, true]) {
    group(enabled ? 'with logging on' : 'with logging off', () {
      setUp(() {
        final wasEnabled = FirebaseLogConfig.enabled;
        final originalDebugPrint = debugPrint;
        FirebaseLogConfig.enabled = enabled;
        debugPrint = (message, {wrapWidth}) {};
        addTearDown(() {
          FirebaseLogConfig.enabled = wasEnabled;
          debugPrint = originalDebugPrint;
        });

        source = FakeProblemRemoteDataSource(problems: [buildTestProblemStorage(problemId: 1)]);
        logging = LoggingProblemRemoteDataSource(source);
      });

      test('every call reaches the real source and returns its result', () async {
        expect(logging.isSignedIn, isTrue);
        expect(await logging.getProblems(), hasLength(1));
        await logging.saveProblem(buildTestProblemStorage(problemId: 2));
        await logging.updateProblem(buildTestProblemStorage(problemId: 2, isBookmarked: true));
        await logging.deleteProblem(1);
        await logging.batchSaveProblems([buildTestProblemStorage(problemId: 3)]);
        await logging.batchDeleteProblems([3]);
        await logging.deleteAllProblems();

        expect(source.calls, [
          'getProblems',
          'saveProblem',
          'updateProblem',
          'deleteProblem',
          'batchSaveProblems',
          'batchDeleteProblems',
          'deleteAllProblems',
        ]);
        expect(source.problems, isEmpty);
      });

      test('errors come back unchanged', () async {
        final error = Exception('permission-denied');
        source.failWith = error;

        await expectLater(logging.getProblems(), throwsA(same(error)));
      });
    });
  }
}
