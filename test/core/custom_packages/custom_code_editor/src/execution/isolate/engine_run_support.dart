// A plain Dart solution run through a driver, the way the editor would once it grades off the UI thread.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/frontend.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/engine.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';

const addSource = 'int add(int a, int b) {\n  print(a);\n  return a + b;\n}';

RunRequest addRequest(int a, int b) => RunRequest(
      language: EditorLanguage.dart,
      source: addSource,
      functionName: 'add',
      arguments: <Value>[IntValue(a), IntValue(b)],
    );
