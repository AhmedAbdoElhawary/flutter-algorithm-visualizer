import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DartInterpreterRunner: happy paths', () {
    test('runs the binary search example and captures print output', () {
      const source = '''
int binarySearch(List<int> arr, int target) {
  int left = 0;
  int right = arr.length - 1;
  while (left <= right) {
    int mid = (left + right) ~/ 2;
    if (arr[mid] == target) {
      return mid;
    } else if (arr[mid] < target) {
      left = mid + 1;
    } else {
      right = mid - 1;
    }
  }
  return -1;
}
void main() {
  // Example usage
  final arr = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91];
  final idx = binarySearch(arr, 23);
  print(idx); // → 5
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isTrue);
      expect(result.stdout, ['5']);
    });

    test('supports recursion (factorial)', () {
      const source = '''
int factorial(int n) {
  if (n <= 1) {
    return 1;
  }
  return n * factorial(n - 1);
}
void main() {
  print(factorial(6));
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isTrue);
      expect(result.stdout, ['720']);
    });

    test('supports for-in loops and string interpolation', () {
      const source = r'''
void main() {
  final names = ['a', 'b', 'c'];
  for (var n in names) {
    print('name: $n');
  }
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isTrue);
      expect(result.stdout, ['name: a', 'name: b', 'name: c']);
    });

    test('supports classic for loops with break/continue', () {
      const source = '''
void main() {
  int total = 0;
  for (int i = 0; i < 10; i++) {
    if (i == 5) {
      break;
    }
    if (i % 2 == 0) {
      continue;
    }
    total += i;
  }
  print(total);
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isTrue);
      // i = 1, 3 contribute (0,2,4 skipped via continue; loop breaks at 5)
      expect(result.stdout, ['4']);
    });

    test('supports String.split/indexOf and List.removeLast', () {
      const source = '''
String lastChar(String s) {
  final chars = s.split('');
  final last = chars.removeLast();
  return last;
}
void main() {
  print(lastChar('ab(c'));
  print('hello'.indexOf('ll'));
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isTrue);
      expect(result.stdout, ['c', '2']);
    });
  });

  group('DartInterpreterRunner: syntax errors', () {
    test('reports a missing semicolon with the correct line', () {
      const source = '''
void main() {
  int x = 1
  print(x);
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isFalse);
      expect(result.error!.kind, RunErrorKind.syntax);
      expect(result.error!.line, 3);
    });

    test('reports an unexpected token', () {
      const source = '''
void main() {
  print(@);
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isFalse);
      expect(result.error!.kind, RunErrorKind.syntax);
      expect(result.error!.line, 2);
    });

    test('reports a non-void function that never returns as a syntax error', () {
      const source = '''
List<int> twoSum(List<int> nums, int target) {
}
void main() {
  print(twoSum([1, 2], 3));
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isFalse);
      expect(result.error!.kind, RunErrorKind.syntax);
      expect(result.error!.line, 1);
      expect(result.error!.message, contains("return type of 'List<int>'"));
    });

    test('allows a nullable return type to implicitly return null', () {
      const source = '''
String? maybeName(bool ok) {
  if (ok) {
    return 'a';
  }
}
void main() {
  print(maybeName(false));
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isTrue);
      expect(result.stdout, ['null']);
    });
  });

  group('DartInterpreterRunner: runtime errors', () {
    test('reports index-out-of-range with the correct line', () {
      const source = '''
void main() {
  final arr = [1, 2, 3];
  print(arr[10]);
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isFalse);
      expect(result.error!.kind, RunErrorKind.runtime);
      expect(result.error!.line, 3);
    });

    test('reports division by zero', () {
      const source = '''
void main() {
  int a = 10;
  int b = 0;
  print(a ~/ b);
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isFalse);
      expect(result.error!.message.toLowerCase(), contains('division'));
      expect(result.error!.line, 4);
    });

    test('reports an undefined variable', () {
      const source = '''
void main() {
  print(doesNotExist);
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isFalse);
      expect(result.error!.kind, RunErrorKind.runtime);
      expect(result.error!.line, 2);
    });

    test('preserves stdout printed before a runtime error', () {
      const source = '''
void main() {
  print('before');
  final arr = [1];
  print(arr[5]);
  print('after');
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isFalse);
      expect(result.stdout, ['before']);
    });

    test('the infinite-loop guard trips instead of hanging', () {
      const source = '''
void main() {
  int i = 0;
  while (true) {
    i = i + 1;
  }
}
''';
      final result = const DartInterpreterRunner(maxSteps: 5000).run(source);
      expect(result.success, isFalse);
      expect(result.error!.message.toLowerCase(), contains('too long'));
    });

    test('requires a main() function', () {
      const source = '''
int foo() {
  return 1;
}
''';
      final result = const DartInterpreterRunner().run(source);
      expect(result.success, isFalse);
      expect(result.error!.message.toLowerCase(), contains('main'));
    });
  });

  group('CodeController.execute integration', () {
    test('sets errorLine on a runtime error and clears it on edit', () {
      final controller = CodeController(
        text: 'void main() {\n  final arr = [1];\n  print(arr[9]);\n}\n',
        runner: const DartInterpreterRunner(),
      );
      final result = controller.execute();
      expect(result.success, isFalse);
      expect(controller.errorLine, 2); // 0-indexed line 3

      controller.selection = const TextSelection.collapsed(offset: 0);
      controller.value = TextEditingValue(
        text: 'x${controller.text}',
        selection: const TextSelection.collapsed(offset: 1),
      );
      expect(controller.errorLine, isNull);
    });

    test('execute() with no runner attached is a harmless no-op', () {
      final controller = CodeController(text: 'void main() {}');
      final result = controller.execute();
      expect(result.success, isTrue);
      expect(result.stdout, isEmpty);
    });
  });
}
