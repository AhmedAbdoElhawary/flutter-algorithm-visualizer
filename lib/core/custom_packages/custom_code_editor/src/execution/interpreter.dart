import 'ast.dart';

/// Thrown for any error that occurs while *running* already-parsed code:
/// undefined variables/functions, type mismatches, index-out-of-range,
/// division by zero, infinite-loop protection tripping, etc. Carries the
/// 1-indexed source [line] responsible.
class InterpreterError implements Exception {
  InterpreterError(this.message, this.line);
  final String message;
  final int line;

  @override
  String toString() => 'RuntimeError: $message (line $line)';
}

/// Internal, non-local control-flow signals. These are implementation
/// details of [Interpreter] and never escape it as public API.
class _ReturnSignal {
  _ReturnSignal(this.value);
  final dynamic value;
}

class _BreakSignal {
  _BreakSignal(this.line);
  final int line;
}

class _ContinueSignal {
  _ContinueSignal(this.line);
  final int line;
}

/// A lexical scope. Variable lookup/assignment walks up [parent] scopes,
/// matching Dart's own block-scoping rules closely enough for this
/// subset (each `{ ... }` body gets its own [Environment]).
class Environment {
  Environment([this.parent]);

  final Environment? parent;
  final Map<String, dynamic> _vars = <String, dynamic>{};

  void define(String name, dynamic value) {
    _vars[name] = value;
  }

  dynamic get(String name, int line) {
    if (_vars.containsKey(name)) return _vars[name];
    if (parent != null) return parent!.get(name, line);
    throw InterpreterError("Undefined variable '$name'", line);
  }

  void assign(String name, dynamic value, int line) {
    if (_vars.containsKey(name)) {
      _vars[name] = value;
      return;
    }
    if (parent != null) {
      parent!.assign(name, value, line);
      return;
    }
    throw InterpreterError("Undefined variable '$name'", line);
  }
}

/// Tree-walking interpreter for the AST produced by [Parser].
///
/// Values are represented using native Dart types directly (`int`,
/// `double`, `String`, `bool`, `null`, `List<dynamic>`) — since the
/// interpreter itself runs inside a real Dart VM, arithmetic, comparison,
/// and collection operations just delegate to Dart's own operators
/// instead of reimplementing them, which keeps this file focused on
/// *control flow and scoping* rather than numeric semantics.
class Interpreter {
  Interpreter({this.maxSteps = 2000000});

  /// A crude, cheap infinite-loop guard: the interpreter aborts with a
  /// friendly [InterpreterError] rather than hanging forever once this
  /// many statements/expressions have been evaluated.
  final int maxSteps;
  int _steps = 0;

  final Map<String, FunctionDecl> _functions = <String, FunctionDecl>{};
  late Environment _globals;

  /// Captured `print(...)` output, one entry per call, in call order.
  final List<String> output = <String>[];

  /// Runs [program]'s `main()` function. Throws [InterpreterError] on any
  /// runtime failure (undefined name, type mismatch, index error,
  /// division by zero, infinite-loop guard, stray break/continue, ...).
  void run(Program program) {
    for (final FunctionDecl fn in program.functions) {
      _functions[fn.name] = fn;
    }

    _globals = Environment();
    for (final VarDeclStmt v in program.topLevelVars) {
      _globals.define(
        v.name,
        v.initializer == null ? null : _eval(v.initializer!, _globals),
      );
    }

    final FunctionDecl? main = _functions['main'];
    if (main == null) {
      throw InterpreterError(
        'No main() function found. Add a "void main() { ... }" entry point.',
        1,
      );
    }
    if (main.params.isNotEmpty) {
      throw InterpreterError('main() must not take any parameters', main.line);
    }

    try {
      _callUserFunction(main, const <dynamic>[]);
    } on _BreakSignal catch (b) {
      throw InterpreterError('"break" used outside of a loop', b.line);
    } on _ContinueSignal catch (c) {
      throw InterpreterError('"continue" used outside of a loop', c.line);
    }
  }

  void _tick(int line) {
    _steps++;
    if (_steps > maxSteps) {
      throw InterpreterError(
        'Execution took too long (possible infinite loop)',
        line,
      );
    }
  }

  // ---------------------------------------------------------------------
  // Functions
  // ---------------------------------------------------------------------

  dynamic _callUserFunction(FunctionDecl fn, List<dynamic> args) {
    final Environment env = Environment(_globals);
    for (int i = 0; i < fn.params.length; i++) {
      env.define(fn.params[i].name, i < args.length ? args[i] : null);
    }
    try {
      _execBlock(fn.body, env);
    } on _ReturnSignal catch (r) {
      return r.value;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Statements
  // ---------------------------------------------------------------------

  void _execBlock(Block block, Environment env) {
    for (final Stmt stmt in block.statements) {
      _execStmt(stmt, env);
    }
  }

  void _execStmt(Stmt stmt, Environment env) {
    _tick(stmt.line);

    if (stmt is Block) {
      _execBlock(stmt, Environment(env));
      return;
    }
    if (stmt is VarDeclStmt) {
      env.define(
        stmt.name,
        stmt.initializer == null ? null : _eval(stmt.initializer!, env),
      );
      return;
    }
    if (stmt is ExprStmt) {
      _eval(stmt.expr, env);
      return;
    }
    if (stmt is IfStmt) {
      if (_truthy(_eval(stmt.condition, env), stmt.line)) {
        _execStmt(stmt.thenBranch, env);
      } else if (stmt.elseBranch != null) {
        _execStmt(stmt.elseBranch!, env);
      }
      return;
    }
    if (stmt is WhileStmt) {
      while (_truthy(_eval(stmt.condition, env), stmt.line)) {
        _tick(stmt.line);
        try {
          _execStmt(stmt.body, env);
        } on _BreakSignal {
          break;
        } on _ContinueSignal {
          continue;
        }
      }
      return;
    }
    if (stmt is ForStmt) {
      final Environment loopEnv = Environment(env);
      if (stmt.init != null) _execStmt(stmt.init!, loopEnv);
      while (true) {
        if (stmt.condition != null && !_truthy(_eval(stmt.condition!, loopEnv), stmt.line)) {
          break;
        }
        _tick(stmt.line);
        bool broke = false;
        try {
          _execStmt(stmt.body, loopEnv);
        } on _BreakSignal {
          broke = true;
        } on _ContinueSignal {
          // fall through to the update expression below
        }
        if (broke) break;
        if (stmt.update != null) _eval(stmt.update!, loopEnv);
      }
      return;
    }
    if (stmt is ForInStmt) {
      final dynamic iterable = _eval(stmt.iterable, env);
      if (iterable is! Iterable) {
        throw InterpreterError(
          'for-in requires an iterable (e.g. a List), got ${_typeName(iterable)}',
          stmt.line,
        );
      }
      for (final dynamic item in iterable) {
        _tick(stmt.line);
        final Environment iterEnv = Environment(env);
        iterEnv.define(stmt.varName, item);
        try {
          _execStmt(stmt.body, iterEnv);
        } on _BreakSignal {
          break;
        } on _ContinueSignal {
          continue;
        }
      }
      return;
    }
    if (stmt is ReturnStmt) {
      throw _ReturnSignal(stmt.value == null ? null : _eval(stmt.value!, env));
    }
    if (stmt is BreakStmt) throw _BreakSignal(stmt.line);
    if (stmt is ContinueStmt) throw _ContinueSignal(stmt.line);

    throw InterpreterError('Unsupported statement', stmt.line);
  }

  bool _truthy(dynamic v, int line) {
    if (v is bool) return v;
    throw InterpreterError(
      'Condition must be a boolean value (got ${_typeName(v)})',
      line,
    );
  }

  // ---------------------------------------------------------------------
  // Expressions
  // ---------------------------------------------------------------------

  dynamic _eval(Expr expr, Environment env) {
    _tick(expr.line);

    if (expr is IntLiteral) return expr.value;
    if (expr is DoubleLiteral) return expr.value;
    if (expr is BoolLiteral) return expr.value;
    if (expr is NullLiteral) return null;

    if (expr is StringLiteral) {
      final StringBuffer buf = StringBuffer();
      for (final Object part in expr.parts) {
        if (part is String) {
          buf.write(part);
        } else if (part is Expr) {
          buf.write(_stringify(_eval(part, env)));
        }
      }
      return buf.toString();
    }

    if (expr is ListLiteral) {
      return expr.elements.map((Expr e) => _eval(e, env)).toList();
    }

    if (expr is Identifier) return env.get(expr.name, expr.line);

    if (expr is UnaryExpr) return _evalUnary(expr, env);
    if (expr is BinaryExpr) return _evalBinary(expr, env);

    if (expr is ConditionalExpr) {
      return _truthy(_eval(expr.condition, env), expr.line) ? _eval(expr.thenExpr, env) : _eval(expr.elseExpr, env);
    }

    if (expr is AssignExpr) return _evalAssign(expr, env);
    if (expr is PostfixExpr) return _evalPostfix(expr, env);

    if (expr is IndexExpr) {
      final dynamic target = _eval(expr.target, env);
      final dynamic index = _eval(expr.index, env);
      try {
        return (target as dynamic)[index];
      } catch (e) {
        throw InterpreterError(_friendlyIndexError(e, target, index), expr.line);
      }
    }

    if (expr is PropertyAccess) return _evalProperty(expr, env);
    if (expr is CallExpr) return _evalCall(expr, env);

    throw InterpreterError('Unsupported expression', expr.line);
  }

  dynamic _evalUnary(UnaryExpr expr, Environment env) {
    final dynamic v = _eval(expr.operand, env);
    try {
      if (expr.op == '!') return !(v as bool);
      if (expr.op == '-') return -(v as num);
    } catch (_) {
      throw InterpreterError(
        'Cannot apply unary "${expr.op}" to ${_typeName(v)}',
        expr.line,
      );
    }
    throw InterpreterError('Unknown unary operator "${expr.op}"', expr.line);
  }

  dynamic _evalBinary(BinaryExpr expr, Environment env) {
    if (expr.op == '&&') {
      return _truthy(_eval(expr.left, env), expr.line) && _truthy(_eval(expr.right, env), expr.line);
    }
    if (expr.op == '||') {
      return _truthy(_eval(expr.left, env), expr.line) || _truthy(_eval(expr.right, env), expr.line);
    }
    final dynamic l = _eval(expr.left, env);
    final dynamic r = _eval(expr.right, env);
    return _applyBinaryOp(expr.op, l, r, expr.line);
  }

  dynamic _applyBinaryOp(String op, dynamic l, dynamic r, int line) {
    try {
      switch (op) {
        case '+':
          return l + r;
        case '-':
          return l - r;
        case '*':
          return l * r;
        case '/':
          return l / r;
        case '~/':
          return l ~/ r;
        case '%':
          return l % r;
        case '==':
          return l == r;
        case '!=':
          return l != r;
        case '<':
          return l < r;
        case '>':
          return l > r;
        case '<=':
          return l <= r;
        case '>=':
          return l >= r;
        default:
          throw InterpreterError('Unknown operator "$op"', line);
      }
    } on InterpreterError {
      rethrow;
    } catch (e) {
      if (e is UnsupportedError) {
        throw InterpreterError('Division by zero', line);
      }
      throw InterpreterError(
        'Cannot apply "$op" to ${_typeName(l)} and ${_typeName(r)}',
        line,
      );
    }
  }

  dynamic _evalAssign(AssignExpr expr, Environment env) {
    final dynamic value = _eval(expr.value, env);
    dynamic newValue = value;
    if (expr.op != '=') {
      final dynamic current = _evalTarget(expr.target, env);
      final String op = expr.op.substring(0, expr.op.length - 1);
      newValue = _applyBinaryOp(op, current, value, expr.line);
    }
    _assignTarget(expr.target, newValue, env, expr.line);
    return newValue;
  }

  dynamic _evalPostfix(PostfixExpr expr, Environment env) {
    final dynamic current = _evalTarget(expr.target, env);
    final int delta = expr.op == '++' ? 1 : -1;
    dynamic newValue;
    try {
      newValue = (current as num) + delta;
    } catch (_) {
      throw InterpreterError(
        'Cannot apply "${expr.op}" to ${_typeName(current)}',
        expr.line,
      );
    }
    _assignTarget(expr.target, newValue, env, expr.line);
    return current;
  }

  dynamic _evalTarget(Expr target, Environment env) {
    if (target is Identifier) return env.get(target.name, target.line);
    if (target is IndexExpr) {
      final dynamic t = _eval(target.target, env);
      final dynamic idx = _eval(target.index, env);
      try {
        return (t as dynamic)[idx];
      } catch (e) {
        throw InterpreterError(_friendlyIndexError(e, t, idx), target.line);
      }
    }
    throw InterpreterError('Invalid assignment target', target.line);
  }

  void _assignTarget(Expr target, dynamic value, Environment env, int line) {
    if (target is Identifier) {
      env.assign(target.name, value, line);
      return;
    }
    if (target is IndexExpr) {
      final dynamic t = _eval(target.target, env);
      final dynamic idx = _eval(target.index, env);
      try {
        (t as dynamic)[idx] = value;
      } catch (e) {
        throw InterpreterError(_friendlyIndexError(e, t, idx), line);
      }
      return;
    }
    throw InterpreterError('Invalid assignment target', line);
  }

  dynamic _evalProperty(PropertyAccess expr, Environment env) {
    final dynamic target = _eval(expr.target, env);
    switch (expr.name) {
      case 'length':
        if (target is List || target is String) {
          return (target as dynamic).length;
        }
        break;
      case 'isEmpty':
        if (target is List || target is String) {
          return (target as dynamic).isEmpty;
        }
        break;
      case 'isNotEmpty':
        if (target is List || target is String) {
          return (target as dynamic).isNotEmpty;
        }
        break;
      case 'first':
        if (target is List) return target.first;
        break;
      case 'last':
        if (target is List) return target.last;
        break;
    }
    throw InterpreterError(
      '"${_typeName(target)}" has no property "${expr.name}"',
      expr.line,
    );
  }

  dynamic _evalCall(CallExpr expr, Environment env) {
    if (expr.callee is Identifier && (expr.callee as Identifier).name == 'print') {
      final List<dynamic> args = expr.args.map((Expr a) => _eval(a, env)).toList();
      output.add(args.isEmpty ? '' : _stringify(args.first));
      return null;
    }

    if (expr.callee is PropertyAccess) {
      final PropertyAccess prop = expr.callee as PropertyAccess;
      final dynamic target = _eval(prop.target, env);
      final List<dynamic> args = expr.args.map((Expr a) => _eval(a, env)).toList();
      return _callBuiltinMethod(target, prop.name, args, expr.line);
    }

    if (expr.callee is Identifier) {
      final String name = (expr.callee as Identifier).name;
      final FunctionDecl? fn = _functions[name];
      if (fn == null) {
        throw InterpreterError("Undefined function '$name'", expr.line);
      }
      if (expr.args.length != fn.params.length) {
        throw InterpreterError(
          "'$name' expects ${fn.params.length} argument(s) but got ${expr.args.length}",
          expr.line,
        );
      }
      final List<dynamic> args = expr.args.map((Expr a) => _eval(a, env)).toList();
      return _callUserFunction(fn, args);
    }

    throw InterpreterError('Expression is not callable', expr.line);
  }

  dynamic _callBuiltinMethod(
    dynamic target,
    String name,
    List<dynamic> args,
    int line,
  ) {
    try {
      if (target is List) {
        switch (name) {
          case 'add':
            target.add(args[0]);
            return null;
          case 'removeAt':
            return target.removeAt(args[0] as int);
          case 'remove':
            return target.remove(args[0]);
          case 'contains':
            return target.contains(args[0]);
          case 'indexOf':
            return target.indexOf(args[0]);
          case 'toString':
            return _stringify(target);
        }
      }
      if (target is String) {
        switch (name) {
          case 'toUpperCase':
            return target.toUpperCase();
          case 'toLowerCase':
            return target.toLowerCase();
          case 'trim':
            return target.trim();
          case 'contains':
            return target.contains(args[0] as String);
          case 'substring':
            return args.length == 1
                ? target.substring(args[0] as int)
                : target.substring(args[0] as int, args[1] as int);
          case 'toString':
            return target;
        }
      }
      if (name == 'toString') return _stringify(target);
    } catch (e) {
      throw InterpreterError('Error calling "$name": $e', line);
    }
    throw InterpreterError(
      'Unknown method "$name" on ${_typeName(target)}',
      line,
    );
  }

  String _friendlyIndexError(Object e, dynamic target, dynamic index) {
    if (e is RangeError) {
      return 'Index $index is out of range for a ${_typeName(target)}'
          '${target is List ? ' of length ${target.length}' : ''}';
    }
    return 'Cannot index into ${_typeName(target)}';
  }

  String _stringify(dynamic v) {
    if (v == null) return 'null';
    if (v is List) return '[${v.map(_stringify).join(', ')}]';
    return v.toString();
  }

  String _typeName(dynamic v) {
    if (v == null) return 'Null';
    if (v is int) return 'int';
    if (v is double) return 'double';
    if (v is bool) return 'bool';
    if (v is String) return 'String';
    if (v is List) return 'List';
    return v.runtimeType.toString();
  }
}
