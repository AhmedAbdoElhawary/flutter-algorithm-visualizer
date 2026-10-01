import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/dart/dart_harness.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/javascript/javascript_harness.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/language_registry.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/python/python_harness.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each language has its own frontend', () {
    expect(frontendFor(EditorLanguage.dart), isA<DartFrontend>());
    expect(frontendFor(EditorLanguage.python), isA<PythonFrontend>());
    expect(frontendFor(EditorLanguage.javascript), isA<JavascriptFrontend>());
    for (final language in supportedLanguages) {
      expect(frontendFor(language).language, language);
    }
  });

  test('names, keys and file extensions', () {
    expect(supportedLanguages.map((l) => l.datasetKey), ['dart', 'python', 'javascript']);
    expect(supportedLanguages.map((l) => l.displayName), ['Dart', 'Python', 'JavaScript']);
    expect(supportedLanguages.map((l) => l.fileExtension), ['dart', 'py', 'js']);
  });

  test('a key reads back to its language, anything else to none', () {
    for (final language in supportedLanguages) {
      expect(languageFromKey(language.datasetKey), language);
    }
    expect(languageFromKey(null), isNull);
    expect(languageFromKey('ruby'), isNull);
  });
}
