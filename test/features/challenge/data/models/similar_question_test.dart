import 'package:algorithm_visualizer/features/challenge/data/models/similar_question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads every field and writes the same JSON back', () {
    final json = <String, dynamic>{'problem_id': 8, 'name': 'Two Sum II', 'reason': 'Sorted input.'};

    final model = SimilarQuestion.fromJson(json);

    expect(model, const SimilarQuestion(problemId: 8, name: 'Two Sum II', reason: 'Sorted input.'));
    expect(model.toJson(), json);
  });

  test('every field is optional', () {
    expect(SimilarQuestion.fromJson(<String, dynamic>{}), const SimilarQuestion(problemId: null, name: null, reason: null));
  });

  test('equal fields mean equal and the same hash', () {
    const a = SimilarQuestion(problemId: 8, name: 'Two Sum II', reason: 'Sorted input.');
    const b = SimilarQuestion(problemId: 8, name: 'Two Sum II', reason: 'Sorted input.');

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const SimilarQuestion(problemId: null, name: null, reason: null)));
  });

  test('a field of the wrong type is a clear error, not a silent wrong value', () {
    final json = <String, dynamic>{'problem_id': 8, 'name': 'Two Sum II', 'reason': 'Sorted input.'};
    json[json.keys.first] = <Object>[];

    expect(() => SimilarQuestion.fromJson(json), throwsA(isA<TypeError>()));
  });
}
