/// The shared Core IR every language frontend targets. Everything after this
/// point (compiler, VM, budgets, cancellation) is shared by all languages —
/// this is the mechanism behind FR-031/SC-011.
///
/// **Invariant**: every node carries a 1-indexed line in the learner's own
/// source. Nodes the harness generates are flagged [synthetic] and are never
/// reported to the learner (FR-017).
///
/// See `specs/007-multi-language-interpreter/data-model.md` §5.
library;

import '../values/value.dart';

sealed class IrNode {
  const IrNode({required this.line, this.synthetic = false});
  final int line;
  final bool synthetic;
}

sealed class IrExpr extends IrNode {
  const IrExpr({required super.line, super.synthetic});
}

sealed class IrStmt extends IrNode {
  const IrStmt({required super.line, super.synthetic});
}

/// A whole compiled unit: top-level statements (functions, classes, and any
/// top-level code the harness appends).
class IrProgram {
  const IrProgram(this.statements);
  final List<IrStmt> statements;
}

// ---------------------------------------------------------------------------
// Expressions
// ---------------------------------------------------------------------------

enum IrLiteralKind { intLit, numLit, boolLit, strLit, nullLit }

class IrLiteral extends IrExpr {
  const IrLiteral({required super.line, super.synthetic, required this.kind, required this.value});
  final IrLiteralKind kind;
  final Object? value;
}

/// Embeds an already-constructed runtime [Value] directly, bypassing
/// [IrLiteral]'s primitive-only kinds. Not produced by any parser — only by
/// `LanguageFrontend.buildHarness` implementations, which receive their
/// arguments as real `Value`s (already parsed from the test case), not
/// source text.
class IrRawValue extends IrExpr {
  const IrRawValue({required super.line, super.synthetic, required this.value});
  final Value value;
}

class IrIdentifier extends IrExpr {
  const IrIdentifier({required super.line, super.synthetic, required this.name});
  final String name;
}

/// `floorDiv` is Python's `//` (mathematical floor); `truncDiv` is Dart's
/// `~/` (truncation toward zero) — genuinely different for negative operands.
enum IrBinaryOp { add, sub, mul, div, floorDiv, truncDiv, mod, eq, notEq, lt, lte, gt, gte, and, or, ifNull }

class IrBinary extends IrExpr {
  const IrBinary(
      {required super.line, super.synthetic, required this.op, required this.left, required this.right});
  final IrBinaryOp op;
  final IrExpr left;
  final IrExpr right;
}

enum IrUnaryOp { negate, not }

class IrUnary extends IrExpr {
  const IrUnary({required super.line, super.synthetic, required this.op, required this.operand});
  final IrUnaryOp op;
  final IrExpr operand;
}

class IrConditional extends IrExpr {
  const IrConditional(
      {required super.line,
      super.synthetic,
      required this.condition,
      required this.thenExpr,
      required this.elseExpr});
  final IrExpr condition;
  final IrExpr thenExpr;
  final IrExpr elseExpr;
}

/// `target = value` where `target` is an identifier.
class IrAssign extends IrExpr {
  const IrAssign({required super.line, super.synthetic, required this.name, required this.value});
  final String name;
  final IrExpr value;
}

/// `receiver[index]`.
class IrIndexGet extends IrExpr {
  const IrIndexGet({required super.line, super.synthetic, required this.receiver, required this.index});
  final IrExpr receiver;
  final IrExpr index;
}

/// `receiver[index] = value`.
class IrIndexSet extends IrExpr {
  const IrIndexSet(
      {required super.line,
      super.synthetic,
      required this.receiver,
      required this.index,
      required this.value});
  final IrExpr receiver;
  final IrExpr index;
  final IrExpr value;
}

/// `a[start:end]` — Python slicing, including negative indices (IrSlice).
class IrSlice extends IrExpr {
  const IrSlice(
      {required super.line, super.synthetic, required this.receiver, this.start, this.end, this.step});
  final IrExpr receiver;
  final IrExpr? start;
  final IrExpr? end;
  final IrExpr? step;
}

/// `receiver.name`.
class IrPropertyGet extends IrExpr {
  const IrPropertyGet({required super.line, super.synthetic, required this.receiver, required this.name});
  final IrExpr receiver;
  final String name;
}

/// `receiver.name = value`.
class IrPropertySet extends IrExpr {
  const IrPropertySet(
      {required super.line,
      super.synthetic,
      required this.receiver,
      required this.name,
      required this.value});
  final IrExpr receiver;
  final String name;
  final IrExpr value;
}

/// `callee(args)`. `callee` is usually an [IrIdentifier] or [IrPropertyGet],
/// but any expression producing a callable is allowed.
class IrCall extends IrExpr {
  const IrCall({required super.line, super.synthetic, required this.callee, required this.args});
  final IrExpr callee;
  final List<IrExpr> args;
}

/// `super.name(args)`.
class IrSuperCall extends IrExpr {
  const IrSuperCall({required super.line, super.synthetic, required this.name, required this.args});
  final String name;
  final List<IrExpr> args;
}

class IrListLiteral extends IrExpr {
  const IrListLiteral({required super.line, super.synthetic, required this.items});
  final List<IrExpr> items;
}

/// Python only — immutable list literal.
class IrTupleLiteral extends IrExpr {
  const IrTupleLiteral({required super.line, super.synthetic, required this.items});
  final List<IrExpr> items;
}

class IrMapLiteral extends IrExpr {
  const IrMapLiteral({required super.line, super.synthetic, required this.keys, required this.values});
  final List<IrExpr> keys;
  final List<IrExpr> values;
}

class IrSetLiteral extends IrExpr {
  const IrSetLiteral({required super.line, super.synthetic, required this.items});
  final List<IrExpr> items;
}

/// `*args` / `...rest` inside a call or collection literal.
class IrSpread extends IrExpr {
  const IrSpread({required super.line, super.synthetic, required this.value});
  final IrExpr value;
}

/// `receiver..method(args)` / `receiver..name = value`, possibly chained.
/// Evaluates [receiver] once, performs each operation against it in order
/// (discarding each operation's own result), and yields the receiver.
class IrCascade extends IrExpr {
  const IrCascade({required super.line, super.synthetic, required this.receiver, required this.operations});
  final IrExpr receiver;
  final List<IrCascadeOp> operations;
}

class IrCascadeOp {
  const IrCascadeOp.call(this.name, this.callArgs) : setValue = null;
  const IrCascadeOp.set(this.name, IrExpr value)
      : callArgs = null,
        setValue = value;
  final String name;
  final List<IrExpr>? callArgs;
  final IrExpr? setValue;
}

/// Function expression / arrow / `lambda` (FR-002a).
class IrLambda extends IrExpr {
  const IrLambda(
      {required super.line,
      super.synthetic,
      this.name,
      required this.params,
      required this.body,
      this.isExpressionBody = false});
  final String? name;
  final List<IrParam> params;

  /// A block of statements, or — when [isExpressionBody] — exactly one
  /// implicit-return expression statement.
  final List<IrStmt> body;
  final bool isExpressionBody;
}

/// Reference to a variable captured from an enclosing function scope,
/// resolved by the compiler at compile time (not by the frontend — O5/O1).
class IrClosureRef extends IrExpr {
  const IrClosureRef({required super.line, super.synthetic, required this.name});
  final String name;
}

/// String interpolation across all three syntaxes.
class IrTemplateString extends IrExpr {
  const IrTemplateString({required super.line, super.synthetic, required this.parts});

  /// Alternating literal `String` segments and `IrExpr` interpolations.
  final List<Object> parts;
}

/// List/dict/set comprehension (desugaring to `IrLambda` + loop is also a
/// legal frontend strategy per the frontend contract — this node exists for
/// frontends that prefer not to desugar).
class IrComprehension extends IrExpr {
  const IrComprehension({
    required super.line,
    super.synthetic,
    required this.element,
    this.keyElement,
    required this.loopVar,
    required this.iterable,
    this.condition,
    required this.kind,
  });
  final IrExpr element;

  /// Set when this is a dict comprehension (`{k: v for ...}`).
  final IrExpr? keyElement;
  final String loopVar;
  final IrExpr iterable;
  final IrExpr? condition;
  final IrComprehensionKind kind;
}

enum IrComprehensionKind { list, set, map }

// ---------------------------------------------------------------------------
// Statements
// ---------------------------------------------------------------------------

class IrExprStmt extends IrStmt {
  const IrExprStmt({required super.line, super.synthetic, required this.expr});
  final IrExpr expr;
}

class IrBlock extends IrStmt {
  const IrBlock({required super.line, super.synthetic, required this.statements});
  final List<IrStmt> statements;
}

/// A flat sequence of statements that, unlike [IrBlock], introduces **no**
/// new scope — for `var a = 1, b = 2;`, where every declarator must land in
/// the surrounding scope, not a nested one.
class IrStmtGroup extends IrStmt {
  const IrStmtGroup({required super.line, super.synthetic, required this.statements});
  final List<IrStmt> statements;
}

class IrVarDecl extends IrStmt {
  const IrVarDecl({required super.line, super.synthetic, required this.name, this.initializer});
  final String name;
  final IrExpr? initializer;
}

/// Tuple unpacking / array + object destructuring:
/// `a, b = 1, 2` / `[a, b] = xs` / `{x, y} = point`.
class IrDestructure extends IrStmt {
  const IrDestructure({required super.line, super.synthetic, required this.names, required this.value});
  final List<String> names;
  final IrExpr value;
}

class IrIf extends IrStmt {
  const IrIf(
      {required super.line,
      super.synthetic,
      required this.condition,
      required this.thenBranch,
      this.elseBranch});
  final IrExpr condition;
  final IrStmt thenBranch;
  final IrStmt? elseBranch;
}

class IrWhile extends IrStmt {
  const IrWhile({required super.line, super.synthetic, required this.condition, required this.body});
  final IrExpr condition;
  final IrStmt body;
}

/// Classic C-style `for (init; condition; increment)`.
class IrFor extends IrStmt {
  const IrFor(
      {required super.line, super.synthetic, this.init, this.condition, this.increment, required this.body});
  final IrStmt? init;
  final IrExpr? condition;
  final IrExpr? increment;
  final IrStmt body;
}

/// `for (x in xs)` / `for x in xs:` / `for (const x of xs)`.
class IrForIn extends IrStmt {
  const IrForIn(
      {required super.line,
      super.synthetic,
      required this.varName,
      required this.iterable,
      required this.body});
  final String varName;
  final IrExpr iterable;
  final IrStmt body;
}

class IrReturn extends IrStmt {
  const IrReturn({required super.line, super.synthetic, this.value});
  final IrExpr? value;
}

class IrBreak extends IrStmt {
  const IrBreak({required super.line, super.synthetic});
}

class IrContinue extends IrStmt {
  const IrContinue({required super.line, super.synthetic});
}

class IrParam {
  const IrParam(this.name, {this.defaultValue});
  final String name;
  final IrExpr? defaultValue;
}

class IrFunctionDecl extends IrStmt {
  const IrFunctionDecl(
      {required super.line, super.synthetic, required this.name, required this.params, required this.body});
  final String name;
  final List<IrParam> params;
  final List<IrStmt> body;
}

class IrClassDecl extends IrStmt {
  const IrClassDecl(
      {required super.line,
      super.synthetic,
      required this.name,
      this.superclass,
      required this.methods,
      this.fieldNames = const <String>[]});
  final String name;

  /// Single inheritance (FR-002b).
  final String? superclass;
  final List<IrFunctionDecl> methods;

  /// Field names declared without an initializer (e.g. Dart's
  /// `final int val;`), so the compiler knows to zero-initialize them.
  final List<String> fieldNames;
}

/// `try { ... } catch (e) { ... } finally { ... }` (FR-002c).
class IrTry extends IrStmt {
  const IrTry(
      {required super.line,
      super.synthetic,
      required this.body,
      this.catchVar,
      this.catchBody,
      this.finallyBody});
  final IrStmt body;
  final String? catchVar;
  final IrStmt? catchBody;
  final IrStmt? finallyBody;
}

/// `throw` / `raise` (FR-002c).
class IrThrow extends IrStmt {
  const IrThrow({required super.line, super.synthetic, this.value});
  final IrExpr? value;
}

/// The learner's `print`-equivalent call is compiled like any other call
/// against a stdlib builtin, so no dedicated print node is needed; this node
/// exists only for frontends that want to keep it distinct in their own IR
/// generation before lowering to a call (rare — most frontends should emit
/// `IrCall` against the `print` builtin directly).
class IrPrint extends IrStmt {
  const IrPrint({required super.line, super.synthetic, required this.value});
  final IrExpr value;
}
