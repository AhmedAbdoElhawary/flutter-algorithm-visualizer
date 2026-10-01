import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a frontend failure becomes a failure on the same line, with the output so far', () {
    const failure =
        FrontendFailure(kind: FailureKind.syntax, code: 'expectedSemicolon', line: 3, data: {'near': ')'});

    final converted = failure.toFailure(partialOutput: const ['hi']);

    expect(converted.kind, FailureKind.syntax);
    expect(converted.code, 'expectedSemicolon');
    expect(converted.line, 3);
    expect(converted.data, {'near': ')'});
    expect(converted.partialOutput, ['hi']);
  });

  test('each kind prints what it is', () {
    expect(
      const Failure(kind: FailureKind.runtime, code: 'divisionByZero', line: 2).toString(),
      'Failure(kind: FailureKind.runtime, code: divisionByZero, line: 2, data: {})',
    );
    const error = VmRuntimeError('keyNotFound', {'key': 'a'});
    expect(error.toString(), 'VmRuntimeError(keyNotFound, {key: a})');
    expect(
      const FrontendFailure(kind: FailureKind.unsupported, code: 'bitwise', line: 1).toString(),
      'FrontendFailure(kind: FailureKind.unsupported, code: bitwise, line: 1, data: {})',
    );
  });
}
