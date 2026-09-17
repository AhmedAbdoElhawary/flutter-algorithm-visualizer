// The Arabic problem statements are data, not a lookup table, so they arrive
// by a different route from every other string in the app: a second asset
// merged over the first at load time.
//
// Two properties matter, and neither is visible on screen:
//
//   * the overlay replaces only prose. `test_cases`, `expected_output`,
//     `function_signature` and `default_code` must be byte-identical in both
//     languages, because the offline grader checks answers against them.
//   * a problem the overlay has not reached yet still renders, in English.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readJson(String path) =>
    json.decode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  late List<dynamic> english;
  late Map<String, dynamic> overlay;

  setUpAll(() {
    english = _readJson('assets/problems.json')['problems'] as List<dynamic>;
    overlay = _readJson('assets/problems.ar.json')['problems'] as Map<String, dynamic>;
  });

  test('every overlay key names a problem that exists', () {
    final ids = {for (final p in english) '${p['problem_id']}'};
    for (final key in overlay.keys) {
      expect(ids, contains(key), reason: 'problems.ar.json has an entry for unknown problem $key');
    }
  });

  test('the overlay carries prose only, never anything the grader reads', () {
    const forbidden = <String>[
      'test_cases',
      'hidden_test_cases',
      'expected_output',
      'function_signature',
      'default_code',
      'custom_objects',
      'constraints',
      'name',
      'examples',
    ];

    overlay.forEach((id, value) {
      final fields = (value as Map<String, dynamic>).keys.toSet();
      for (final key in forbidden) {
        expect(fields, isNot(contains(key)),
            reason: 'problem $id: "$key" belongs to problems.json. Putting it in the overlay '
                'would let the two languages disagree about what a correct answer is.');
      }
      expect(fields.difference({'description', 'hints', 'example_explanations'}), isEmpty,
          reason: 'problem $id has a field the loader does not merge');
    });
  });

  test('hint and explanation counts line up with the English', () {
    final byId = {for (final p in english) '${p['problem_id']}': p as Map<String, dynamic>};

    overlay.forEach((id, value) {
      final fields = value as Map<String, dynamic>;
      final source = byId[id]!;

      if (fields['hints'] != null) {
        expect((fields['hints'] as List).length, (source['hints'] as List? ?? []).length,
            reason: 'problem $id: the hints are merged by position, so the counts must match');
      }
      if (fields['example_explanations'] != null) {
        expect((fields['example_explanations'] as List).length, (source['examples'] as List? ?? []).length,
            reason: 'problem $id: explanations are merged by position onto examples');
      }
    });
  });

  test('every translated string is actually Arabic, and none is left empty', () {
    final arabic = RegExp(r'[؀-ۿ]');

    overlay.forEach((id, value) {
      final fields = value as Map<String, dynamic>;

      void check(String label, String? text) {
        if (text == null) return;
        expect(text.trim(), isNotEmpty, reason: 'problem $id: $label is empty');
        expect(arabic.hasMatch(text), isTrue, reason: 'problem $id: $label has no Arabic in it — "$text"');
      }

      check('description', fields['description'] as String?);
      for (final (i, h) in (fields['hints'] as List? ?? []).indexed) {
        check('hint $i', h as String?);
      }
      // An explanation may legitimately be pure arithmetic ("0 + 0 = 0"), so
      // those are allowed through without an Arabic letter in them.
      for (final (i, e) in (fields['example_explanations'] as List? ?? []).indexed) {
        expect((e as String).trim(), isNotEmpty, reason: 'problem $id: explanation $i is empty');
      }
    });
  });

  test('coverage is reported, so what is left is never a surprise', () {
    final done = overlay.length;
    // ignore: avoid_print
    print('Arabic problem coverage: $done / ${english.length}');
    expect(done, greaterThan(0));
  });
}
