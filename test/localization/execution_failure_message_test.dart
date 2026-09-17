// The engine hands presentation a `code` plus the values involved, never a
// sentence (`contracts/execution-contract.md`, FR-014/FR-015). Building that
// sentence used to happen inside `problem_runner.dart`, which had no
// `BuildContext` and so could only ever produce English.
//
// Two things need guarding now that the sentence is built at render time:
// that the English is *byte for byte* what it was (the grading tests and the
// debug logs still read it), and that Arabic actually reaches the blanks.

import 'package:algorithm_visualizer/core/localization/translations/ar_translations.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:flutter_test/flutter_test.dart';

String _ar(String source) => kArTranslations[source] ?? source;

void main() {
  group('English, unchanged by the refactor', () {
    const cases = <(String, Map<String, Object?>, String)>[
      ('undefinedVariable', {'name': 'nums'}, "Undefined variable 'nums'"),
      ('undefinedFunction', {'name': 'helper'}, "Undefined function 'helper'"),
      ('indexOutOfRange', {'index': 5, 'length': 3}, 'Index 5 is out of range for a list of length 3'),
      ('keyNotFound', {'key': 'a'}, "Key 'a' was not found"),
      ('divisionByZero', <String, Object?>{}, 'Division by zero'),
      ('typeMismatch', {'expected': 'int', 'actual': 'String'}, 'Expected int but got String'),
      ('wrongArgumentCount', {'expected': 2, 'actual': 3}, 'Expected 2 argument(s) but got 3'),
      ('uncaughtThrow', {'message': 'boom'}, 'Uncaught error: boom'),
      ('unsupportedConstruct', {'construct': 'async'}, "'async' isn't supported in this editor yet"),
      ('notAvailableInThisEnvironment', {'name': 'dart:io'}, "'dart:io' isn't available in this environment"),
      (
        'indentationError',
        {'reason': 'mixedTabsAndSpaces'},
        'This line mixes tabs and spaces, so its indentation is ambiguous'
      ),
      (
        'indentationError',
        {'reason': 'unexpectedIndent'},
        "This line's indentation doesn't line up with any block above it"
      ),
      ('indentationError', {'reason': 'other'}, 'Inconsistent indentation'),
      ('missingEntryPoint', {'name': 'twoSum'}, "Couldn't find a function named 'twoSum' to run"),
      ('timeLimitExceeded', <String, Object?>{}, 'This ran for too long and was stopped'),
      ('memoryLimitExceeded', <String, Object?>{}, 'This used too much memory and was stopped'),
      ('recursionLimitExceeded', <String, Object?>{}, 'This recursed too deeply and was stopped'),
      ('cancelled', <String, Object?>{}, 'Cancelled'),
      ('somethingNobodyCodedFor', <String, Object?>{}, 'Something went wrong while running this code'),
    ];

    for (final (code, data, expected) in cases) {
      test('$code -> "$expected"', () {
        expect(StringsManager.executionFailureMessage(code, data), expected);
      });
    }

    test('the headline keeps its old shape', () {
      expect(
        StringsManager.executionFailureHeadline(
          kind: 'runtime',
          line: 7,
          code: 'divisionByZero',
          data: const <String, Object?>{},
        ),
        'runtime error (line 7): Division by zero',
      );
    });
  });

  group('Arabic', () {
    test('fills the blanks with the values, in Arabic word order', () {
      expect(
        StringsManager.executionFailureMessage(
          'indexOutOfRange',
          const {'index': 5, 'length': 3},
          tr: _ar,
        ),
        'الموضع 5 خارج نطاق قائمة طولها 3',
      );
    });

    test('translates the headline, the kind and the sentence together', () {
      expect(
        StringsManager.executionFailureHeadline(
          kind: 'runtime',
          line: 7,
          code: 'divisionByZero',
          data: const <String, Object?>{},
          tr: _ar,
        ),
        'خطأ تشغيل (السطر 7): القسمة على صفر',
      );
    });

    test('keeps the learner\'s own identifier untouched inside the sentence', () {
      final message = StringsManager.executionFailureMessage(
        'undefinedVariable',
        const {'name': 'nums'},
        tr: _ar,
      );
      expect(message, contains("'nums'"));
      expect(message, contains('متغيّر'));
    });

    test('every failure code has an Arabic template', () {
      const codes = <String>[
        'undefinedVariable',
        'undefinedFunction',
        'indexOutOfRange',
        'keyNotFound',
        'divisionByZero',
        'typeMismatch',
        'wrongArgumentCount',
        'uncaughtThrow',
        'unsupportedConstruct',
        'notAvailableInThisEnvironment',
        'indentationError',
        'customObjectsInThisLanguage',
        'missingEntryPoint',
        'timeLimitExceeded',
        'memoryLimitExceeded',
        'recursionLimitExceeded',
        'cancelled',
        'anythingElse',
      ];
      for (final code in codes) {
        final template = StringsManager.executionFailureTemplate(code, const <String, Object?>{});
        expect(kArTranslations.containsKey(template), isTrue,
            reason: 'No Arabic for the "$code" template: "$template"');
      }
    });

    test('every FailureKind has an Arabic word', () {
      for (final kind in <String>[
        'syntax',
        'runtime',
        'unsupported',
        'timeLimit',
        'memoryLimit',
        'recursionLimit',
        'cancelled',
      ]) {
        final word = StringsManager.executionFailureKind(kind);
        expect(kArTranslations.containsKey(word), isTrue, reason: 'No Arabic for the "$kind" kind: "$word"');
      }
    });
  });

  test('a placeholder with no value is left alone, never printed as null', () {
    expect(
      StringsManager.executionFailureMessage('undefinedVariable', const <String, Object?>{}),
      isNot(contains('null')),
    );
  });
}
