/// AST node types for the subset-of-Dart interpreter.
///
/// Every node carries a 1-indexed [line] so that runtime errors can be
/// reported against the exact source line that caused them.
library;

abstract class Node {
  const Node(this.line);
  final int line;
}

// ---------------------------------------------------------------------
// Top level
// ---------------------------------------------------------------------

class Program extends Node {
  Program(this.functions, this.topLevelVars, int line) : super(line);
  final List<FunctionDecl> functions;
  final List<VarDeclStmt> topLevelVars;
}

class Param {
  const Param(this.name);
  final String name;
}

class FunctionDecl extends Node {
  FunctionDecl(this.name, this.params, this.body, int line) : super(line);
  final String name;
  final List<Param> params;
  final Block body;
}

// ---------------------------------------------------------------------
// Statements
// ---------------------------------------------------------------------

abstract class Stmt extends Node {
  const Stmt(super.line);
}

class Block extends Stmt {
  Block(this.statements, int line) : super(line);
  final List<Stmt> statements;
}

class VarDeclStmt extends Stmt {
  VarDeclStmt(this.name, this.initializer, int line) : super(line);
  final String name;
  final Expr? initializer;
}

class ExprStmt extends Stmt {
  ExprStmt(this.expr, int line) : super(line);
  final Expr expr;
}

class IfStmt extends Stmt {
  IfStmt(this.condition, this.thenBranch, this.elseBranch, int line)
      : super(line);
  final Expr condition;
  final Stmt thenBranch;
  final Stmt? elseBranch;
}

class WhileStmt extends Stmt {
  WhileStmt(this.condition, this.body, int line) : super(line);
  final Expr condition;
  final Stmt body;
}

class ForStmt extends Stmt {
  ForStmt(this.init, this.condition, this.update, this.body, int line)
      : super(line);
  final Stmt? init; // VarDeclStmt or ExprStmt
  final Expr? condition;
  final Expr? update;
  final Stmt body;
}

class ForInStmt extends Stmt {
  ForInStmt(this.varName, this.iterable, this.body, int line) : super(line);
  final String varName;
  final Expr iterable;
  final Stmt body;
}

class ReturnStmt extends Stmt {
  ReturnStmt(this.value, int line) : super(line);
  final Expr? value;
}

class BreakStmt extends Stmt {
  BreakStmt(super.line);
}

class ContinueStmt extends Stmt {
  ContinueStmt(super.line);
}

// ---------------------------------------------------------------------
// Expressions
// ---------------------------------------------------------------------

abstract class Expr extends Node {
  const Expr(super.line);
}

class IntLiteral extends Expr {
  IntLiteral(this.value, int line) : super(line);
  final int value;
}

class DoubleLiteral extends Expr {
  DoubleLiteral(this.value, int line) : super(line);
  final double value;
}

class BoolLiteral extends Expr {
  BoolLiteral(this.value, int line) : super(line);
  final bool value;
}

class NullLiteral extends Expr {
  NullLiteral(super.line);
}

/// A string literal, pre-split into literal text chunks and interpolated
/// expressions (`$name` / `${expr}`), so interpolation errors surface at
/// parse time rather than being re-parsed on every evaluation.
class StringLiteral extends Expr {
  StringLiteral(this.parts, int line) : super(line);

  /// Each part is either a [String] (literal text) or an [Expr]
  /// (interpolated value).
  final List<Object> parts;
}

class ListLiteral extends Expr {
  ListLiteral(this.elements, int line) : super(line);
  final List<Expr> elements;
}

class Identifier extends Expr {
  Identifier(this.name, int line) : super(line);
  final String name;
}

class BinaryExpr extends Expr {
  BinaryExpr(this.op, this.left, this.right, int line) : super(line);
  final String op;
  final Expr left;
  final Expr right;
}

class UnaryExpr extends Expr {
  UnaryExpr(this.op, this.operand, int line) : super(line);
  final String op;
  final Expr operand;
}

class ConditionalExpr extends Expr {
  ConditionalExpr(this.condition, this.thenExpr, this.elseExpr, int line)
      : super(line);
  final Expr condition;
  final Expr thenExpr;
  final Expr elseExpr;
}

class AssignExpr extends Expr {
  AssignExpr(this.target, this.op, this.value, int line) : super(line);
  final Expr target; // Identifier or IndexExpr
  final String op; // '=', '+=', '-=', '*=', '/='
  final Expr value;
}

class PostfixExpr extends Expr {
  PostfixExpr(this.target, this.op, int line) : super(line);
  final Expr target; // Identifier or IndexExpr
  final String op; // '++' or '--'
}

class IndexExpr extends Expr {
  IndexExpr(this.target, this.index, int line) : super(line);
  final Expr target;
  final Expr index;
}

class PropertyAccess extends Expr {
  PropertyAccess(this.target, this.name, int line) : super(line);
  final Expr target;
  final String name;
}

class CallExpr extends Expr {
  CallExpr(this.callee, this.args, int line) : super(line);
  final Expr callee; // Identifier or PropertyAccess
  final List<Expr> args;
}
