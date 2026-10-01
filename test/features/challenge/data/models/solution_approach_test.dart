import 'package:algorithm_visualizer/features/challenge/data/models/solution_approach.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads every field and writes the same JSON back', () {
    final json = <String, dynamic>{'key_observation': 'k', 'algorithm': 'a', 'why_it_works': 'w', 'implementation_notes': 'i'};

    final model = SolutionApproach.fromJson(json);

    expect(model, const SolutionApproach(keyObservation: 'k', algorithm: 'a', whyItWorks: 'w', implementationNotes: 'i'));
    expect(model.toJson(), json);
  });

  test('every field is optional', () {
    expect(SolutionApproach.fromJson(<String, dynamic>{}), const SolutionApproach(keyObservation: null, algorithm: null, whyItWorks: null, implementationNotes: null));
  });

  test('equal fields mean equal and the same hash', () {
    const a = SolutionApproach(keyObservation: 'k', algorithm: 'a', whyItWorks: 'w', implementationNotes: 'i');
    const b = SolutionApproach(keyObservation: 'k', algorithm: 'a', whyItWorks: 'w', implementationNotes: 'i');

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const SolutionApproach(keyObservation: null, algorithm: null, whyItWorks: null, implementationNotes: null)));
  });

  test('a field of the wrong type is a clear error, not a silent wrong value', () {
    final json = <String, dynamic>{'key_observation': 'k', 'algorithm': 'a', 'why_it_works': 'w', 'implementation_notes': 'i'};
    json[json.keys.first] = <Object>[];

    expect(() => SolutionApproach.fromJson(json), throwsA(isA<TypeError>()));
  });
}
