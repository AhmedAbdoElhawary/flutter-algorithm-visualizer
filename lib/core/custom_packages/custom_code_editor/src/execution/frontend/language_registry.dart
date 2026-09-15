/// The one place that knows which languages exist and how to build each
/// one's frontend (FR-032).
///
/// The picker, the starter-code lookup, the syntax highlighting and the
/// execution path all read from here, so adding a fourth language means
/// adding its own directory and one line below — and changing nothing in the
/// compiler, the VM, grading, limits, cancellation, or error presentation
/// (SC-011, FR-031).
library;

import 'dart/dart_harness.dart';
import 'frontend.dart';
import 'javascript/javascript_harness.dart';
import 'python/python_harness.dart';

export 'frontend.dart' show EditorLanguage, LanguageFrontend;

/// Builds the frontend for [language]. A fresh instance each time: a frontend
/// is cheap, and its builtins are mutable maps that must not be shared
/// between runs.
LanguageFrontend frontendFor(EditorLanguage language) => switch (language) {
      EditorLanguage.dart => DartFrontend(),
      EditorLanguage.python => PythonFrontend(),
      EditorLanguage.javascript => JavascriptFrontend(),
    };

/// Every language the editor can run, in the order a picker should show them.
const List<EditorLanguage> supportedLanguages = <EditorLanguage>[
  EditorLanguage.dart,
  EditorLanguage.python,
  EditorLanguage.javascript,
];

extension EditorLanguageX on EditorLanguage {
  /// The key this language uses in `assets/problems.json` — in
  /// `default_code`, `function_signature` and `custom_objects`.
  String get datasetKey => switch (this) {
        EditorLanguage.dart => 'dart',
        EditorLanguage.python => 'python',
        EditorLanguage.javascript => 'javascript',
      };

  /// How the language is written for a learner to read.
  String get displayName => switch (this) {
        EditorLanguage.dart => 'Dart',
        EditorLanguage.python => 'Python',
        EditorLanguage.javascript => 'JavaScript',
      };

  /// The conventional file extension, used as a compact label where a full
  /// name will not fit.
  String get fileExtension => switch (this) {
        EditorLanguage.dart => 'dart',
        EditorLanguage.python => 'py',
        EditorLanguage.javascript => 'js',
      };
}

/// Resolves a dataset key or stored language name back to a language.
/// Returns null for anything unrecognised, so a future dataset that names a
/// language this build does not have simply does not offer it, rather than
/// crashing.
EditorLanguage? languageFromKey(String? key) {
  if (key == null) return null;
  for (final language in supportedLanguages) {
    if (language.datasetKey == key || language.name == key) return language;
  }
  return null;
}
