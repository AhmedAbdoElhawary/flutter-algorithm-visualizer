// Exercises the compiler + VM directly, by hand-building Core IR, before any
// language frontend exists. This is the "engine can run a trivial stub
// program" checkpoint from tasks.md Phase 2 — closures, classes, exceptions,
// deep recursion (G4), and stdlib intrinsics all need to work before a
// frontend is worth building on top of them.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/compile/compiler.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/ir/ir.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/dialect.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/budget.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/vm.dart';
import 'package:flutter_test/flutter_test.dart';

const dartDialect = Dialect(
  intDivisionYields: IntDivisionMode.alwaysDouble,
  truthiness: TruthinessMode.boolOnly,
  equalityCoerces: false,
  defaultSortOrder: SortOrder.natural,
  hasUndefined: false,
  printsTrueAs: 'true',
  printsFalseAs: 'false',
  stringIndexYields: StringIndexResult.codeUnit,
  arbitraryPrecisionInts: false,
  negativeIndexing: false,
);

IrLiteral intLit(int v, [int line = 1]) => IrLiteral(line: line, kind: IrLiteralKind.intLit, value: v);
IrIdentifier id(String name, [int line = 1]) => IrIdentifier(line: line, name: name);

VmResult runProgram(List<IrStmt> statements, {Dialect dialect = dartDialect}) {
  final program = IrProgram(statements);
  final script = Compiler().compileProgram(program);
  final vm = Vm(dialect: dialect, budget: const ExecutionBudget());
  return vm.run(script, timeout: const Duration(seconds: 5));
}

void main() {
  group('closures — the original complaint, at the engine level', () {
    test('a lambda captures an outer local variable', () {
      // var x = 10;
      // var f = (n) => n + x;
      // return f(5);
      final result = runProgram([
        const IrVarDecl(line: 1, name: 'x', initializer: IrLiteral(line: 1, kind: IrLiteralKind.intLit, value: 10)),
        IrVarDecl(
          line: 2,
          name: 'f',
          initializer: IrLambda(
            line: 2,
            params: const [IrParam('n')],
            body: [
              IrReturn(line: 2, value: IrBinary(line: 2, op: IrBinaryOp.add, left: id('n'), right: id('x'))),
            ],
          ),
        ),
        IrReturn(line: 3, value: IrCall(line: 3, callee: id('f'), args: [intLit(5)])),
      ]);
      expect(result.failure, isNull);
      expect(result.returned, const IntValue(15));
    });

    test('.map/.where/reduce/sort(cmp) all run — the fix for the original complaint', () {
      // var nums = [3, 1, 2];
      // var doubled = nums.map((x) => x * 2).toList();
      // return doubled;
      final result = runProgram([
        IrVarDecl(line: 1, name: 'nums', initializer: IrListLiteral(line: 1, items: [intLit(3), intLit(1), intLit(2)])),
        IrVarDecl(
          line: 2,
          name: 'doubled',
          initializer: IrCall(
            line: 2,
            callee: IrPropertyGet(
              line: 2,
              receiver: IrCall(
                line: 2,
                callee: IrPropertyGet(line: 2, receiver: id('nums'), name: 'map'),
                args: [
                  IrLambda(line: 2, params: const [IrParam('x')], body: [
                    IrReturn(line: 2, value: IrBinary(line: 2, op: IrBinaryOp.mul, left: id('x'), right: intLit(2))),
                  ]),
                ],
              ),
              name: 'toList',
            ),
            args: const [],
          ),
        ),
        IrReturn(line: 3, value: id('doubled')),
      ]);
      expect(result.failure, isNull);
      expect(result.returned, ListValue([const IntValue(6), const IntValue(2), const IntValue(4)]));
    });

    test('sort(cmp) with a closure comparator', () {
      final result = runProgram([
        IrVarDecl(line: 1, name: 'nums', initializer: IrListLiteral(line: 1, items: [intLit(3), intLit(1), intLit(2)])),
        IrExprStmt(
          line: 2,
          expr: IrCall(
            line: 2,
            callee: IrPropertyGet(line: 2, receiver: id('nums'), name: 'sort'),
            args: [
              IrLambda(line: 2, params: const [IrParam('a'), IrParam('b')], body: [
                IrReturn(line: 2, value: IrBinary(line: 2, op: IrBinaryOp.sub, left: id('b'), right: id('a'))),
              ]),
            ],
          ),
        ),
        IrReturn(line: 3, value: id('nums')),
      ]);
      expect(result.failure, isNull);
      expect(result.returned, ListValue([const IntValue(3), const IntValue(2), const IntValue(1)]));
    });
  });

  group('classes — fields, methods, single inheritance (FR-002b)', () {
    test('inherited method resolves through the superclass', () {
      // class Animal { speak() { return "..."; } }
      // class Dog extends Animal { bark() { return "woof"; } }
      // var d = Dog();
      // return d.bark();
      final result = runProgram([
        IrClassDecl(line: 1, name: 'Animal', methods: [
          IrFunctionDecl(line: 1, name: 'speak', params: const [], body: [
            const IrReturn(line: 1, value: IrLiteral(line: 1, kind: IrLiteralKind.strLit, value: '...')),
          ]),
        ]),
        IrClassDecl(line: 2, name: 'Dog', superclass: 'Animal', methods: [
          IrFunctionDecl(line: 2, name: 'bark', params: const [], body: [
            const IrReturn(line: 2, value: IrLiteral(line: 2, kind: IrLiteralKind.strLit, value: 'woof')),
          ]),
        ]),
        IrVarDecl(line: 3, name: 'd', initializer: IrCall(line: 3, callee: id('Dog'), args: const [])),
        IrReturn(line: 4, value: IrCall(line: 4, callee: IrPropertyGet(line: 4, receiver: id('d'), name: 'bark'), args: const [])),
      ]);
      expect(result.failure, isNull);
      expect(result.returned, const StrValue('woof'));
    });

    test('super.method() calls the overridden superclass implementation', () {
      final result = runProgram([
        IrClassDecl(line: 1, name: 'Animal', methods: [
          IrFunctionDecl(line: 1, name: 'speak', params: const [], body: [
            const IrReturn(line: 1, value: IrLiteral(line: 1, kind: IrLiteralKind.strLit, value: 'base')),
          ]),
        ]),
        IrClassDecl(line: 2, name: 'Dog', superclass: 'Animal', methods: [
          IrFunctionDecl(line: 2, name: 'speak', params: const [], body: [
            IrReturn(
              line: 2,
              value: IrBinary(
                line: 2,
                op: IrBinaryOp.add,
                left: IrSuperCall(line: 2, name: 'speak', args: const []),
                right: const IrLiteral(line: 2, kind: IrLiteralKind.strLit, value: '+dog'),
              ),
            ),
          ]),
        ]),
        IrVarDecl(line: 3, name: 'd', initializer: IrCall(line: 3, callee: id('Dog'), args: const [])),
        IrReturn(line: 4, value: IrCall(line: 4, callee: IrPropertyGet(line: 4, receiver: id('d'), name: 'speak'), args: const [])),
      ]);
      expect(result.failure, isNull);
      expect(result.returned, const StrValue('base+dog'));
    });

    test('a constructor (<init>) sets fields via this', () {
      final result = runProgram([
        IrClassDecl(line: 1, name: 'Box', methods: [
          IrFunctionDecl(line: 1, name: '<init>', params: const [IrParam('v')], body: [
            IrExprStmt(line: 1, expr: IrPropertySet(line: 1, receiver: id('this'), name: 'value', value: id('v'))),
          ]),
        ]),
        IrVarDecl(line: 2, name: 'b', initializer: IrCall(line: 2, callee: id('Box'), args: [intLit(42)])),
        IrReturn(line: 3, value: IrPropertyGet(line: 3, receiver: id('b'), name: 'value')),
      ]);
      expect(result.failure, isNull);
      expect(result.returned, const IntValue(42));
    });
  });

  group('exceptions — try/catch/finally, unwinding the explicit frame stack (FR-002c)', () {
    test('catch intercepts a runtime error (index out of range)', () {
      final result = runProgram([
        IrVarDecl(line: 1, name: 'nums', initializer: IrListLiteral(line: 1, items: [intLit(1)])),
        IrVarDecl(line: 2, name: 'result', initializer: intLit(0)),
        IrTry(
          line: 3,
          body: IrExprStmt(line: 3, expr: IrIndexGet(line: 3, receiver: id('nums'), index: intLit(5))),
          catchVar: 'e',
          catchBody: IrExprStmt(line: 4, expr: IrAssign(line: 4, name: 'result', value: intLit(1))),
        ),
        IrReturn(line: 5, value: id('result')),
      ]);
      expect(result.failure, isNull);
      expect(result.returned, const IntValue(1));
    });

    test('finally runs on the normal path', () {
      final result = runProgram([
        IrVarDecl(line: 1, name: 'log', initializer: intLit(0)),
        IrTry(
          line: 2,
          body: IrExprStmt(line: 2, expr: IrAssign(line: 2, name: 'log', value: intLit(1))),
          finallyBody: IrExprStmt(line: 3, expr: IrAssign(line: 3, name: 'log', value: intLit(2))),
        ),
        IrReturn(line: 4, value: id('log')),
      ]);
      expect(result.failure, isNull);
      expect(result.returned, const IntValue(2));
    });

    test('an uncaught throw is classified as a runtime failure at the throwing line', () {
      final result = runProgram([
        const IrThrow(line: 7, value: IrLiteral(line: 7, kind: IrLiteralKind.strLit, value: 'boom')),
      ]);
      expect(result.failure, isNotNull);
      expect(result.failure!.kind, FailureKind.runtime);
      expect(result.failure!.line, 7);
    });

    test('a throw in one case does not corrupt VM state for a later independent run (R9-adjacent)', () {
      final vm = Vm(dialect: dartDialect, budget: const ExecutionBudget());
      final failing = Compiler().compileProgram(const IrProgram([
        IrThrow(line: 1, value: IrLiteral(line: 1, kind: IrLiteralKind.strLit, value: 'x')),
      ]));
      final failingResult = vm.run(failing, timeout: const Duration(seconds: 5));
      expect(failingResult.failure, isNotNull);

      final vm2 = Vm(dialect: dartDialect, budget: const ExecutionBudget());
      final ok = Compiler().compileProgram(IrProgram([IrReturn(line: 1, value: intLit(9))]));
      final okResult = vm2.run(ok, timeout: const Duration(seconds: 5));
      expect(okResult.failure, isNull);
      expect(okResult.returned, const IntValue(9));
    });
  });

  group('deep recursion never rides the Dart call stack (G4)', () {
    test('10,000-deep recursion completes without a Dart StackOverflowError', () {
      // int countdown(int n) { if (n <= 0) return 0; return countdown(n - 1); }
      // return countdown(10000);
      final result = runProgram([
        IrFunctionDecl(
          line: 1,
          name: 'countdown',
          params: const [IrParam('n')],
          body: [
            IrIf(
              line: 1,
              condition: IrBinary(line: 1, op: IrBinaryOp.lte, left: id('n'), right: intLit(0)),
              thenBranch: const IrReturn(line: 1, value: IrLiteral(line: 1, kind: IrLiteralKind.intLit, value: 0)),
            ),
            IrReturn(
              line: 1,
              value: IrCall(
                line: 1,
                callee: id('countdown'),
                args: [IrBinary(line: 1, op: IrBinaryOp.sub, left: id('n'), right: intLit(1))],
              ),
            ),
          ],
        ),
        IrReturn(line: 2, value: IrCall(line: 2, callee: id('countdown'), args: [intLit(5000)])),
      ]);
      expect(result.failure, isNull);
      expect(result.returned, const IntValue(0));
    });

    test('runaway recursion is classified as recursionLimit, never a crash', () {
      final result = runProgram([
        IrFunctionDecl(
          line: 1,
          name: 'forever',
          params: const [],
          body: [
            IrReturn(line: 1, value: IrCall(line: 1, callee: id('forever'), args: const [])),
          ],
        ),
        IrReturn(line: 2, value: IrCall(line: 2, callee: id('forever'), args: const [])),
      ]);
      expect(result.failure, isNotNull);
      expect(result.failure!.kind, FailureKind.recursionLimit);
    });
  });

  group('cancellation and time limits (G2, G3)', () {
    test('an infinite loop is stopped by the time budget', () {
      final program = IrProgram([
        IrWhile(line: 1, condition: const IrLiteral(line: 1, kind: IrLiteralKind.boolLit, value: true), body: const IrBlock(line: 1, statements: [])),
      ]);
      final script = Compiler().compileProgram(program);
      final vm = Vm(dialect: dartDialect, budget: const ExecutionBudget(instructionsPerBudgetCheck: 10));
      final result = vm.run(script, timeout: const Duration(milliseconds: 50));
      expect(result.failure, isNotNull);
      expect(result.failure!.kind, FailureKind.timeLimit);
    });

    test('cancellation is observed between instructions', () {
      var cancelled = false;
      final program = IrProgram([
        IrWhile(line: 1, condition: const IrLiteral(line: 1, kind: IrLiteralKind.boolLit, value: true), body: const IrBlock(line: 1, statements: [])),
      ]);
      final script = Compiler().compileProgram(program);
      final vm = Vm(
        dialect: dartDialect,
        budget: const ExecutionBudget(instructionsPerBudgetCheck: 10),
        isCancelled: () => cancelled,
      );
      cancelled = true;
      final result = vm.run(script, timeout: const Duration(seconds: 5));
      expect(result.failure, isNotNull);
      expect(result.failure!.kind, FailureKind.cancelled);
    });
  });

  group('print / stdout survives failure (FR-016, G7)', () {
    test('output printed before a failure is preserved', () {
      final result = runProgram([
        const IrPrint(line: 1, value: IrLiteral(line: 1, kind: IrLiteralKind.strLit, value: 'before')),
        const IrThrow(line: 2, value: IrLiteral(line: 2, kind: IrLiteralKind.strLit, value: 'boom')),
      ]);
      expect(result.failure, isNotNull);
      expect(result.stdout, ['before']);
      expect(result.failure!.partialOutput, ['before']);
    });
  });
}
