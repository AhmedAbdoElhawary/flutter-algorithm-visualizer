// The Arabic table is keyed by English *text*, not by constant name, so a
// wrong key fails silently: the look-up misses, `tr` hands back the source,
// and the app quietly stays English in one spot. Nothing throws, nothing is
// logged, and a screenshot of the right screen is the only way to notice.
//
// So this suite reads both source files and compares them directly. It is the
// only place in the test tree that parses Dart source, and that is deliberate
// — the thing being checked *is* a relationship between two source files.

import 'dart:io';

import 'package:algorithm_visualizer/core/localization/translations/ar_translations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every string literal `StringsManager` declares as a `static const String`,
/// with Dart escapes resolved so `Day\n Streak` compares as a real newline.
///
/// Hand-scanned rather than matched with one big regular expression: the
/// declarations include adjacent literals split over two lines, both quote
/// styles and escaped quotes inside, and a regex covering all of that is
/// harder to trust than the twenty lines below.
Set<String> _stringsManagerValues() {
  final source = File('lib/core/resources/strings_manager.dart').readAsStringSync();
  final declaration = RegExp(r'static const String [a-zA-Z0-9_]+ =');
  final values = <String>{};

  for (final match in declaration.allMatches(source)) {
    final buffer = StringBuffer();
    var i = match.end;

    // Consume `"a"` / `'a'` runs until the terminating semicolon. Anything
    // that is not a literal (an alias such as `= compare;`) ends the scan
    // with an empty buffer and is skipped.
    while (i < source.length && source[i] != ';') {
      final char = source[i];
      if (char == '"' || char == "'") {
        i++;
        while (i < source.length && source[i] != char) {
          if (source[i] == r'\') {
            buffer.write(_unescape(source[i + 1]));
            i += 2;
            continue;
          }
          buffer.write(source[i]);
          i++;
        }
      }
      i++;
    }
    if (buffer.isNotEmpty) values.add(buffer.toString());
  }
  return values;
}

String _unescape(String escaped) => switch (escaped) {
      'n' => '\n',
      't' => '\t',
      _ => escaped,
    };

void main() {
  late Set<String> englishValues;

  setUpAll(() => englishValues = _stringsManagerValues());

  test('the file parses into something plausible at all', () {
    // Guards the regexes above: if they ever stop matching, every other test
    // here would pass vacuously.
    expect(englishValues.length, greaterThan(250));
    expect(englishValues, contains('Settings'));
  });

  test('every Arabic key matches an English string byte for byte', () {
    final orphans = kArTranslations.keys.where((k) => !englishValues.contains(k)).toList();

    expect(
      orphans,
      isEmpty,
      reason: 'These keys translate nothing — the English text they name no longer exists, '
          'or never did. Most often a trailing space or colon was dropped: '
          "'Time: ' and 'Time' are different keys.\n${orphans.join('\n')}",
    );
  });

  test('nothing is translated to itself, or to nothing', () {
    for (final entry in kArTranslations.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: 'Empty translation for "${entry.key}"');
      expect(
        entry.value,
        isNot(entry.key),
        reason: '"${entry.key}" maps to itself — drop the row instead, a missing key '
            'already falls back to English.',
      );
    }
  });

  test('a key that ends in a space or colon keeps it in Arabic', () {
    // These are concatenated at the call site (`'Time: ' + '2.4s'`), so losing
    // the separator glues two words together.
    for (final entry in kArTranslations.entries) {
      if (entry.key.endsWith(' ')) {
        expect(entry.value.endsWith(' '), isTrue,
            reason: '"${entry.key}" ends in a space; its Arabic must too.');
      }
      if (entry.key.startsWith(' ')) {
        expect(entry.value.startsWith(' '), isTrue,
            reason: '"${entry.key}" starts with a space; its Arabic must too.');
      }
      if (entry.key.endsWith(':')) {
        expect(entry.value.endsWith(':'), isTrue,
            reason: '"${entry.key}" ends in a colon; its Arabic must too.');
      }
    }
  });

  test('a template keeps every placeholder it started with', () {
    final placeholder = RegExp(r'\{[a-zA-Z]+\}');
    for (final entry in kArTranslations.entries) {
      final want = placeholder.allMatches(entry.key).map((m) => m.group(0)!).toSet();
      if (want.isEmpty) continue;

      final got = placeholder.allMatches(entry.value).map((m) => m.group(0)!).toSet();
      expect(got, want, reason: 'Placeholders changed translating "${entry.key}"');
    }
  });

  test('code, identifiers and proper nouns are absent on purpose', () {
    // If one of these ever gains a translation it is a mistake, not a feature:
    // the app would then be showing a file name or a language name that does
    // not exist.
    const mustStayEnglish = <String>[
      'AlgoDive',
      'Dart',
      'GitHub',
      'LinkedIn',
      'two_sum.dart',
      'twoSum',
      'name@example.com',
      'Ahmed Elhawary',
    ];
    for (final term in mustStayEnglish) {
      expect(kArTranslations.containsKey(term), isFalse, reason: '"$term" must not be translated');
    }
  });
}
