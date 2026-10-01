// The Core IR nodes that exist for Python and JavaScript but that the Dart
// frontend never emits, so nothing exercised them until now: slicing, tuples,
// destructuring, and spread. These are shared engine capabilities — they live
// in the compiler and VM, not in any one frontend — so they are tested here
// against hand-built IR, the same way `vm_core_test.dart` tests the rest of
// the engine, rather than through whichever frontend happens to use them.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/compile/compiler.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/ir/ir.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/dialect.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/budget.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/vm.dart';
import 'package:flutter_test/flutter_test.dart';

/// Slicing and negative indexing are Python-shaped, so these tests run under a
/// Python-shaped dialect.
const pythonish = Dialect(
  intDivisionYields: IntDivisionMode.floorFloat,
  truthiness: TruthinessMode.pythonic,
  equalityCoerces: false,
  defaultSortOrder: SortOrder.natural,
  hasUndefined: false,
  printsTrueAs: 'True',
  printsFalseAs: 'False',
  stringIndexYields: StringIndexResult.oneCharString,
  arbitraryPrecisionInts: true,
  negativeIndexing: true,
);

IrLiteral intLit(int v) => IrLiteral(line: 1, kind: IrLiteralKind.intLit, value: v);
IrLiteral strLit(String v) => IrLiteral(line: 1, kind: IrLiteralKind.strLit, value: v);
IrIdentifier id(String name) => IrIdentifier(line: 1, name: name);
IrListLiteral listOf(List<int> xs) => IrListLiteral(line: 1, items: [for (final x in xs) intLit(x)]);

VmResult runProgram(List<IrStmt> statements) {
  final script = Compiler().compileProgram(IrProgram(statements));
  return Vm(dialect: pythonish, budget: const ExecutionBudget())
      .run(script, timeout: const Duration(seconds: 5));
}

/// Runs `return <expr>` and returns the canonical-ish plain Dart shape of the
/// result, so assertions read as plain literals.
Object? evalToPlain(IrExpr expr) {
  final result = runProgram([IrReturn(line: 1, value: expr)]);
  expect(result.failure, isNull, reason: 'program failed: ${result.failure?.code}');
  return plain(result.returned!);
}

Object? plain(Value v) => switch (v) {
      IntValue(:final value) => value,
      NumValue(:final value) => value,
      BoolValue(:final value) => value,
      StrValue(:final value) => value,
      NullValue() => null,
      ListValue(:final items) => [for (final i in items) plain(i)],
      TupleValue(:final items) => [for (final i in items) plain(i)],
      SetValue(:final items) => {for (final i in items) plain(i)},
      _ => v,
    };

void main() {
  group('slicing', () {
    final xs = listOf([0, 1, 2, 3, 4, 5]);

    test('a[1:4] takes the half-open range', () {
      expect(evalToPlain(IrSlice(line: 1, receiver: xs, start: intLit(1), end: intLit(4))), [1, 2, 3]);
    });

    test('a[:3] and a[3:] default the missing bound', () {
      expect(evalToPlain(IrSlice(line: 1, receiver: xs, end: intLit(3))), [0, 1, 2]);
      expect(evalToPlain(IrSlice(line: 1, receiver: xs, start: intLit(3))), [3, 4, 5]);
    });

    test('a[:] copies the whole list', () {
      expect(evalToPlain(IrSlice(line: 1, receiver: xs)), [0, 1, 2, 3, 4, 5]);
    });

    test('negative bounds count from the end', () {
      expect(evalToPlain(IrSlice(line: 1, receiver: xs, start: intLit(-2))), [4, 5]);
      expect(evalToPlain(IrSlice(line: 1, receiver: xs, end: intLit(-2))), [0, 1, 2, 3]);
    });

    test('a[::-1] reverses — the idiom this whole opcode exists for', () {
      expect(evalToPlain(IrSlice(line: 1, receiver: xs, step: intLit(-1))), [5, 4, 3, 2, 1, 0]);
    });

    test('a positive step skips elements', () {
      expect(evalToPlain(IrSlice(line: 1, receiver: xs, step: intLit(2))), [0, 2, 4]);
    });

    test('out-of-range bounds clamp instead of raising, unlike plain indexing', () {
      expect(evalToPlain(IrSlice(line: 1, receiver: xs, start: intLit(2), end: intLit(999))), [2, 3, 4, 5]);
      expect(evalToPlain(IrSlice(line: 1, receiver: xs, start: intLit(99))), <int>[]);
    });

    test('an inverted range yields empty rather than counting backwards', () {
      expect(evalToPlain(IrSlice(line: 1, receiver: xs, start: intLit(4), end: intLit(1))), <int>[]);
    });

    test('strings slice to strings, including reversal', () {
      expect(
          evalToPlain(IrSlice(line: 1, receiver: strLit('hello'), start: intLit(1), end: intLit(4))), 'ell');
      expect(evalToPlain(IrSlice(line: 1, receiver: strLit('hello'), step: intLit(-1))), 'olleh');
    });

    test('slicing a tuple yields a tuple, not a list', () {
      final tuple = IrTupleLiteral(line: 1, items: [intLit(1), intLit(2), intLit(3)]);
      final result = runProgram([
        IrReturn(line: 1, value: IrSlice(line: 1, receiver: tuple, start: intLit(1))),
      ]);
      expect(result.returned, isA<TupleValue>());
    });

    test('a zero step is a runtime error, not a hang', () {
      final result = runProgram([
        IrReturn(line: 1, value: IrSlice(line: 1, receiver: xs, step: intLit(0))),
      ]);
      expect(result.failure, isNotNull);
      expect(result.failure!.code, 'typeMismatch');
    });

    test('slicing leaves the original list untouched', () {
      final result = runProgram([
        IrVarDecl(line: 1, name: 'a', initializer: listOf([1, 2, 3])),
        IrExprStmt(line: 2, expr: IrSlice(line: 2, receiver: id('a'), start: intLit(1))),
        IrReturn(line: 3, value: id('a')),
      ]);
      expect(plain(result.returned!), [1, 2, 3]);
    });
  });

  group('tuples', () {
    test('a tuple literal builds a TupleValue', () {
      final result = runProgram([
        IrReturn(line: 1, value: IrTupleLiteral(line: 1, items: [intLit(1), strLit('a')])),
      ]);
      expect(result.returned, isA<TupleValue>());
      expect(plain(result.returned!), [1, 'a']);
    });

    test('tuple elements are readable by index', () {
      expect(
        evalToPlain(IrIndexGet(
          line: 1,
          receiver: IrTupleLiteral(line: 1, items: [intLit(7), intLit(8)]),
          index: intLit(1),
        )),
        8,
      );
    });
  });

  group('destructuring', () {
    test('positional unpacking binds each name to its position', () {
      final result = runProgram([
        IrDestructure(line: 1, names: const ['a', 'b'], value: listOf([10, 20])),
        IrReturn(line: 2, value: IrBinary(line: 2, op: IrBinaryOp.add, left: id('a'), right: id('b'))),
      ]);
      expect(plain(result.returned!), 30);
    });

    test('a, b = b, a swaps existing variables rather than shadowing them', () {
      final result = runProgram([
        IrVarDecl(line: 1, name: 'a', initializer: intLit(1)),
        IrVarDecl(line: 2, name: 'b', initializer: intLit(2)),
        IrDestructure(
            line: 3, names: const ['a', 'b'], value: IrTupleLiteral(line: 3, items: [id('b'), id('a')])),
        IrReturn(line: 4, value: IrListLiteral(line: 4, items: [id('a'), id('b')])),
      ]);
      expect(plain(result.returned!), [2, 1]);
    });

    test('the right-hand side is evaluated exactly once', () {
      // A counter the destructured call increments; if the compiler evaluated
      // the RHS once per name it would read 2, not 1.
      final result = runProgram([
        IrVarDecl(line: 1, name: 'calls', initializer: intLit(0)),
        IrFunctionDecl(line: 2, name: 'pair', params: const [], body: [
          IrExprStmt(
            line: 3,
            expr: IrAssign(
                line: 3,
                name: 'calls',
                value: IrBinary(line: 3, op: IrBinaryOp.add, left: id('calls'), right: intLit(1))),
          ),
          IrReturn(line: 4, value: listOf([1, 2])),
        ]),
        IrDestructure(
            line: 5, names: const ['x', 'y'], value: IrCall(line: 5, callee: id('pair'), args: const [])),
        IrReturn(line: 6, value: id('calls')),
      ]);
      expect(plain(result.returned!), 1);
    });

    test('destructuring works inside a function body, not just at top level', () {
      final result = runProgram([
        IrFunctionDecl(line: 1, name: 'f', params: const [], body: [
          IrDestructure(line: 2, names: const ['a', 'b'], value: listOf([3, 4])),
          IrReturn(line: 3, value: IrBinary(line: 3, op: IrBinaryOp.mul, left: id('a'), right: id('b'))),
        ]),
        IrReturn(line: 4, value: IrCall(line: 4, callee: id('f'), args: const [])),
      ]);
      expect(plain(result.returned!), 12);
    });

    test('byProperty unpacks named fields — JavaScript object destructuring', () {
      final result = runProgram([
        IrClassDecl(line: 1, name: 'P', methods: [
          IrFunctionDecl(line: 2, name: '<init>', params: const [
            IrParam('x'),
            IrParam('y')
          ], body: [
            IrExprStmt(
                line: 3, expr: IrPropertySet(line: 3, receiver: id('this'), name: 'x', value: id('x'))),
            IrExprStmt(
                line: 4, expr: IrPropertySet(line: 4, receiver: id('this'), name: 'y', value: id('y'))),
          ]),
        ]),
        IrDestructure(
          line: 5,
          names: const ['x', 'y'],
          byProperty: true,
          value: IrCall(line: 5, callee: id('P'), args: [intLit(8), intLit(9)]),
        ),
        IrReturn(line: 6, value: IrListLiteral(line: 6, items: [id('x'), id('y')])),
      ]);
      expect(plain(result.returned!), [8, 9]);
    });
  });

  group('spread', () {
    test('spread in a list literal flattens, in order, around plain items', () {
      final result = runProgram([
        IrVarDecl(line: 1, name: 'a', initializer: listOf([2, 3])),
        IrReturn(
          line: 2,
          value: IrListLiteral(line: 2, items: [
            intLit(1),
            IrSpread(line: 2, value: id('a')),
            intLit(4),
          ]),
        ),
      ]);
      expect(plain(result.returned!), [1, 2, 3, 4]);
    });

    test('two spreads concatenate', () {
      final result = runProgram([
        IrReturn(
          line: 1,
          value: IrListLiteral(line: 1, items: [
            IrSpread(line: 1, value: listOf([1, 2])),
            IrSpread(line: 1, value: listOf([3])),
          ]),
        ),
      ]);
      expect(plain(result.returned!), [1, 2, 3]);
    });

    test('spreading copies rather than aliasing the source list', () {
      final result = runProgram([
        IrVarDecl(line: 1, name: 'a', initializer: listOf([1, 2])),
        IrVarDecl(
            line: 2,
            name: 'b',
            initializer: IrListLiteral(line: 2, items: [IrSpread(line: 2, value: id('a'))])),
        IrExprStmt(
            line: 3, expr: IrIndexSet(line: 3, receiver: id('b'), index: intLit(0), value: intLit(99))),
        IrReturn(line: 4, value: id('a')),
      ]);
      expect(plain(result.returned!), [1, 2]);
    });

    test('spread in a set literal dedupes', () {
      final result = runProgram([
        IrReturn(
          line: 1,
          value: IrSetLiteral(line: 1, items: [
            intLit(1),
            IrSpread(line: 1, value: listOf([1, 2, 2])),
          ]),
        ),
      ]);
      expect(result.returned, isA<SetValue>());
      expect(plain(result.returned!), {1, 2});
    });

    test('spread as a call argument expands to separate parameters', () {
      // f(a, b) called as f(...[3, 4]) — this is `Math.max(...xs)` in JS.
      final result = runProgram([
        IrFunctionDecl(line: 1, name: 'f', params: const [
          IrParam('a'),
          IrParam('b')
        ], body: [
          IrReturn(line: 2, value: IrBinary(line: 2, op: IrBinaryOp.sub, left: id('a'), right: id('b'))),
        ]),
        IrReturn(
          line: 3,
          value: IrCall(line: 3, callee: id('f'), args: [
            IrSpread(line: 3, value: listOf([10, 4])),
          ]),
        ),
      ]);
      expect(plain(result.returned!), 6);
    });

    test('spread mixes with plain arguments in the right order', () {
      final result = runProgram([
        IrFunctionDecl(line: 1, name: 'f', params: const [
          IrParam('a'),
          IrParam('b'),
          IrParam('c')
        ], body: [
          IrReturn(line: 2, value: IrListLiteral(line: 2, items: [id('a'), id('b'), id('c')])),
        ]),
        IrReturn(
          line: 3,
          value: IrCall(line: 3, callee: id('f'), args: [
            intLit(1),
            IrSpread(line: 3, value: listOf([2, 3])),
          ]),
        ),
      ]);
      expect(plain(result.returned!), [1, 2, 3]);
    });

    test('spreading the wrong argument count still reports wrongArgumentCount', () {
      final result = runProgram([
        IrFunctionDecl(line: 1, name: 'f', params: const [
          IrParam('a')
        ], body: [
          IrReturn(line: 2, value: id('a')),
        ]),
        IrReturn(
          line: 3,
          value: IrCall(line: 3, callee: id('f'), args: [
            IrSpread(line: 3, value: listOf([1, 2, 3])),
          ]),
        ),
      ]);
      expect(result.failure, isNotNull);
      expect(result.failure!.code, 'wrongArgumentCount');
    });

    test('spreading a string spreads its characters', () {
      final result = runProgram([
        IrReturn(
          line: 1,
          value: IrListLiteral(line: 1, items: [IrSpread(line: 1, value: strLit('ab'))]),
        ),
      ]);
      expect(plain(result.returned!), ['a', 'b']);
    });

    test('spreading a non-iterable is a typeMismatch, not a crash', () {
      final result = runProgram([
        IrReturn(
          line: 1,
          value: IrListLiteral(line: 1, items: [IrSpread(line: 1, value: intLit(5))]),
        ),
      ]);
      expect(result.failure, isNotNull);
      expect(result.failure!.code, 'typeMismatch');
    });
  });
}
