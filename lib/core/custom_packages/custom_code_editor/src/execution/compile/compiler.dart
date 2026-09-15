/// Compiles the shared Core IR to bytecode: scope resolution and
/// **upvalue resolution at compile time** (research decision 2), so closures
/// fall out of the VM as simple heap-allocated cells rather than a runtime
/// environment-chasing search.
library;

import '../ir/ir.dart';
import '../values/value.dart';
import '../vm/chunk.dart';

class _LocalVar {
  _LocalVar(this.name, this.depth, this.slot);
  final String name;
  final int depth;
  final int slot;
}

class _FunctionCompiler {
  _FunctionCompiler({this.enclosing, required this.name, required this.arity});
  final _FunctionCompiler? enclosing;
  final String name;
  final int arity;
  final ChunkBuilder builder = ChunkBuilder();
  final List<_LocalVar> locals = <_LocalVar>[];
  final List<UpvalueDescriptor> upvalues = <UpvalueDescriptor>[];
  int scopeDepth = 0;
  int nextSlot = 0;
  int maxLocalsSeen = 0;
  final List<_LoopContext> loopStack = <_LoopContext>[];
  final List<ExceptionHandler> exceptionTable = <ExceptionHandler>[];

  int declareLocal(String name) {
    final slot = nextSlot++;
    locals.add(_LocalVar(name, scopeDepth, slot));
    if (nextSlot > maxLocalsSeen) maxLocalsSeen = nextSlot;
    return slot;
  }

  void beginScope() => scopeDepth++;

  void endScope() {
    scopeDepth--;
    locals.removeWhere((l) => l.depth > scopeDepth);
  }
}

class _LoopContext {
  _LoopContext();
  final List<int> breakJumps = <int>[];

  /// Where a `continue` should jump to. Set once the loop's increment/
  /// condition-recheck point is known.
  int? continueTarget;
  final List<int> continueJumps = <int>[];
}

/// Thrown when the IR contains a construct this compiler does not yet lower
/// — always a bug in a frontend, never something a frontend should produce
/// for a language it claims to support (contract obligation O1).
class CompilerUnsupported implements Exception {
  CompilerUnsupported(this.message);
  final String message;
  @override
  String toString() => 'CompilerUnsupported: $message';
}

class Compiler {
  /// Compiles a whole program into a `<script>` [FunctionValue] the VM runs
  /// as its initial frame. Top-level declarations become globals (there is
  /// no enclosing function to hold them as locals), matching how the
  /// harness-generated call site expects to find the learner's functions and
  /// classes by name.
  FunctionValue compileProgram(IrProgram program) {
    final fc = _FunctionCompiler(name: '<script>', arity: 0);
    for (final stmt in program.statements) {
      _compileStmt(fc, stmt);
    }
    fc.builder.emitOp(OpCode.nullLit, line: 0, synthetic: true);
    fc.builder.emitOp(OpCode.ret, line: 0, synthetic: true);
    final proto = FunctionProto(
      name: '<script>',
      arity: 0,
      chunk: fc.builder.build(),
      upvalues: fc.upvalues,
      exceptionTable: fc.exceptionTable,
      maxLocals: fc.maxLocalsSeen,
    );
    return FunctionValue(name: '<script>', arity: 0, chunk: proto);
  }

  // -------------------------------------------------------------------
  // Variable resolution
  // -------------------------------------------------------------------

  int? _resolveLocal(_FunctionCompiler fc, String name) {
    for (var i = fc.locals.length - 1; i >= 0; i--) {
      if (fc.locals[i].name == name) return fc.locals[i].slot;
    }
    return null;
  }

  int _addUpvalue(_FunctionCompiler fc, {required bool isLocal, required int index}) {
    for (var i = 0; i < fc.upvalues.length; i++) {
      if (fc.upvalues[i].isLocal == isLocal && fc.upvalues[i].index == index) return i;
    }
    fc.upvalues.add(UpvalueDescriptor(isLocal: isLocal, index: index));
    return fc.upvalues.length - 1;
  }

  int? _resolveUpvalue(_FunctionCompiler fc, String name) {
    final enclosing = fc.enclosing;
    if (enclosing == null) return null;
    final localSlot = _resolveLocal(enclosing, name);
    if (localSlot != null) return _addUpvalue(fc, isLocal: true, index: localSlot);
    final upIdx = _resolveUpvalue(enclosing, name);
    if (upIdx != null) return _addUpvalue(fc, isLocal: false, index: upIdx);
    return null;
  }

  void _loadVariable(_FunctionCompiler fc, String name, int line, {bool synthetic = false}) {
    final local = _resolveLocal(fc, name);
    if (local != null) {
      fc.builder.emitOp(OpCode.getLocal, line: line, synthetic: synthetic);
      fc.builder.emitU16(local, line: line, synthetic: synthetic);
      return;
    }
    final up = _resolveUpvalue(fc, name);
    if (up != null) {
      fc.builder.emitOp(OpCode.getUpvalue, line: line, synthetic: synthetic);
      fc.builder.emitU16(up, line: line, synthetic: synthetic);
      return;
    }
    final nameIdx = fc.builder.addConstant(StrValue(name));
    fc.builder.emitOp(OpCode.getGlobal, line: line, synthetic: synthetic);
    fc.builder.emitU16(nameIdx, line: line, synthetic: synthetic);
  }

  /// Leaves the stored value on the stack (assignment is an expression).
  void _storeVariable(_FunctionCompiler fc, String name, int line, {bool synthetic = false}) {
    final local = _resolveLocal(fc, name);
    if (local != null) {
      fc.builder.emitOp(OpCode.setLocal, line: line, synthetic: synthetic);
      fc.builder.emitU16(local, line: line, synthetic: synthetic);
      return;
    }
    final up = _resolveUpvalue(fc, name);
    if (up != null) {
      fc.builder.emitOp(OpCode.setUpvalue, line: line, synthetic: synthetic);
      fc.builder.emitU16(up, line: line, synthetic: synthetic);
      return;
    }
    final nameIdx = fc.builder.addConstant(StrValue(name));
    fc.builder.emitOp(OpCode.setGlobal, line: line, synthetic: synthetic);
    fc.builder.emitU16(nameIdx, line: line, synthetic: synthetic);
  }

  // -------------------------------------------------------------------
  // Statements
  // -------------------------------------------------------------------

  void _compileStmt(_FunctionCompiler fc, IrStmt stmt) {
    switch (stmt) {
      case IrExprStmt(:final expr):
        _compileExpr(fc, expr);
        fc.builder.emitOp(OpCode.pop, line: stmt.line, synthetic: stmt.synthetic);
      case IrBlock(:final statements):
        fc.beginScope();
        for (final s in statements) {
          _compileStmt(fc, s);
        }
        fc.endScope();
      case IrVarDecl(:final name, :final initializer):
        if (initializer != null) {
          _compileExpr(fc, initializer);
        } else {
          fc.builder.emitOp(OpCode.nullLit, line: stmt.line, synthetic: stmt.synthetic);
        }
        if (fc.scopeDepth == 0) {
          final idx = fc.builder.addConstant(StrValue(name));
          fc.builder.emitOp(OpCode.defineGlobal, line: stmt.line, synthetic: stmt.synthetic);
          fc.builder.emitU16(idx, line: stmt.line, synthetic: stmt.synthetic);
        } else {
          fc.declareLocal(name);
          // The value is already on the stack in the right slot position
          // only by coincidence of evaluation order; make it explicit and
          // uniform by storing then discarding through the normal path.
          final slot = fc.locals.last.slot;
          fc.builder.emitOp(OpCode.setLocal, line: stmt.line, synthetic: stmt.synthetic);
          fc.builder.emitU16(slot, line: stmt.line, synthetic: stmt.synthetic);
          fc.builder.emitOp(OpCode.pop, line: stmt.line, synthetic: stmt.synthetic);
        }
      case IrDestructure(:final names, :final value):
        // Python/JS only (Phase 7/8) — the Dart frontend never emits this.
        throw CompilerUnsupported('destructuring is not supported by this frontend (names: $names, value: $value)');
      case IrIf(:final condition, :final thenBranch, :final elseBranch):
        _compileExpr(fc, condition);
        final elseJump = fc.builder.emitJump(OpCode.jumpIfFalse, line: stmt.line, synthetic: stmt.synthetic);
        _compileStmt(fc, thenBranch);
        if (elseBranch != null) {
          final endJump = fc.builder.emitJump(OpCode.jump, line: stmt.line, synthetic: stmt.synthetic);
          fc.builder.patchU16At(elseJump, fc.builder.offset);
          _compileStmt(fc, elseBranch);
          fc.builder.patchU16At(endJump, fc.builder.offset);
        } else {
          fc.builder.patchU16At(elseJump, fc.builder.offset);
        }
      case IrWhile(:final condition, :final body):
        final loop = _LoopContext();
        fc.loopStack.add(loop);
        final loopStart = fc.builder.offset;
        loop.continueTarget = loopStart;
        _compileExpr(fc, condition);
        final exitJump = fc.builder.emitJump(OpCode.jumpIfFalse, line: stmt.line, synthetic: stmt.synthetic);
        _compileStmt(fc, body);
        fc.builder.emitOp(OpCode.jump, line: stmt.line, synthetic: stmt.synthetic);
        fc.builder.emitU16(loopStart, line: stmt.line, synthetic: stmt.synthetic);
        fc.builder.patchU16At(exitJump, fc.builder.offset);
        for (final b in loop.breakJumps) {
          fc.builder.patchU16At(b, fc.builder.offset);
        }
        fc.loopStack.removeLast();
      case IrFor(:final init, :final condition, :final increment, :final body):
        fc.beginScope();
        if (init != null) _compileStmt(fc, init);
        final loop = _LoopContext();
        fc.loopStack.add(loop);
        final condStart = fc.builder.offset;
        int? exitJump;
        if (condition != null) {
          _compileExpr(fc, condition);
          exitJump = fc.builder.emitJump(OpCode.jumpIfFalse, line: stmt.line, synthetic: stmt.synthetic);
        }
        _compileStmt(fc, body);
        final incrementStart = fc.builder.offset;
        loop.continueTarget = incrementStart;
        if (increment != null) {
          _compileExpr(fc, increment);
          fc.builder.emitOp(OpCode.pop, line: stmt.line, synthetic: stmt.synthetic);
        }
        fc.builder.emitOp(OpCode.jump, line: stmt.line, synthetic: stmt.synthetic);
        fc.builder.emitU16(condStart, line: stmt.line, synthetic: stmt.synthetic);
        if (exitJump != null) fc.builder.patchU16At(exitJump, fc.builder.offset);
        for (final b in loop.breakJumps) {
          fc.builder.patchU16At(b, fc.builder.offset);
        }
        for (final c in loop.continueJumps) {
          fc.builder.patchU16At(c, incrementStart);
        }
        fc.loopStack.removeLast();
        fc.endScope();
      case IrForIn(:final varName, :final iterable, :final body):
        _compileForIn(fc, stmt, varName, iterable, body);
      case IrReturn(:final value):
        if (value != null) {
          _compileExpr(fc, value);
        } else {
          fc.builder.emitOp(OpCode.nullLit, line: stmt.line, synthetic: stmt.synthetic);
        }
        fc.builder.emitOp(OpCode.ret, line: stmt.line, synthetic: stmt.synthetic);
      case IrBreak():
        if (fc.loopStack.isEmpty) throw CompilerUnsupported('break outside a loop');
        final j = fc.builder.emitJump(OpCode.jump, line: stmt.line, synthetic: stmt.synthetic);
        fc.loopStack.last.breakJumps.add(j);
      case IrContinue():
        if (fc.loopStack.isEmpty) throw CompilerUnsupported('continue outside a loop');
        final loop = fc.loopStack.last;
        if (loop.continueTarget != null) {
          fc.builder.emitOp(OpCode.jump, line: stmt.line, synthetic: stmt.synthetic);
          fc.builder.emitU16(loop.continueTarget!, line: stmt.line, synthetic: stmt.synthetic);
        } else {
          final j = fc.builder.emitJump(OpCode.jump, line: stmt.line, synthetic: stmt.synthetic);
          loop.continueJumps.add(j);
        }
      case IrFunctionDecl(:final name, :final params, :final body):
        _compileNamedFunction(fc, stmt.line, name, params, body, isMethod: false);
      case IrClassDecl(:final name, :final superclass, :final methods):
        _compileClass(fc, stmt.line, name, superclass, methods);
      case IrTry():
        _compileTry(fc, stmt);
      case IrThrow(:final value):
        if (value != null) {
          _compileExpr(fc, value);
        } else {
          fc.builder.emitOp(OpCode.nullLit, line: stmt.line, synthetic: stmt.synthetic);
        }
        fc.builder.emitOp(OpCode.throwOp, line: stmt.line, synthetic: stmt.synthetic);
      case IrPrint(:final value):
        _compileExpr(fc, value);
        fc.builder.emitOp(OpCode.print, line: stmt.line, synthetic: stmt.synthetic);
    }
  }

  void _compileForIn(_FunctionCompiler fc, IrStmt stmt, String varName, IrExpr iterable, IrStmt body) {
    // Desugars to iterating an index cursor over the already-evaluated
    // iterable's items, since the VM has no dedicated iterator protocol.
    // `GET_INDEX` on a `ListValue`/`TupleValue`/`SetValue`/`MapValue` (keys)
    // is defined by the VM for this purpose.
    fc.beginScope();
    _compileExpr(fc, iterable);
    final iterableSlot = fc.declareLocal('<iterable>');
    fc.builder.emitOp(OpCode.setLocal, line: stmt.line, synthetic: true);
    fc.builder.emitU16(iterableSlot, line: stmt.line, synthetic: true);
    fc.builder.emitOp(OpCode.pop, line: stmt.line, synthetic: true);

    fc.builder.emitOp(OpCode.constant, line: stmt.line, synthetic: true);
    fc.builder.emitU16(fc.builder.addConstant(const IntValue(0)), line: stmt.line, synthetic: true);
    final cursorSlot = fc.declareLocal('<cursor>');
    fc.builder.emitOp(OpCode.setLocal, line: stmt.line, synthetic: true);
    fc.builder.emitU16(cursorSlot, line: stmt.line, synthetic: true);
    fc.builder.emitOp(OpCode.pop, line: stmt.line, synthetic: true);

    final loop = _LoopContext();
    fc.loopStack.add(loop);
    final loopStart = fc.builder.offset;
    loop.continueTarget = loopStart;

    // condition: cursor < len(iterable)
    fc.builder.emitOp(OpCode.getLocal, line: stmt.line, synthetic: true);
    fc.builder.emitU16(cursorSlot, line: stmt.line, synthetic: true);
    fc.builder.emitOp(OpCode.getLocal, line: stmt.line, synthetic: true);
    fc.builder.emitU16(iterableSlot, line: stmt.line, synthetic: true);
    final lenIdx = fc.builder.addConstant(const StrValue('length'));
    fc.builder.emitOp(OpCode.getProperty, line: stmt.line, synthetic: true);
    fc.builder.emitU16(lenIdx, line: stmt.line, synthetic: true);
    fc.builder.emitOp(OpCode.less, line: stmt.line, synthetic: true);
    final exitJump = fc.builder.emitJump(OpCode.jumpIfFalse, line: stmt.line, synthetic: true);

    fc.beginScope();
    fc.builder.emitOp(OpCode.getLocal, line: stmt.line, synthetic: true);
    fc.builder.emitU16(iterableSlot, line: stmt.line, synthetic: true);
    fc.builder.emitOp(OpCode.getLocal, line: stmt.line, synthetic: true);
    fc.builder.emitU16(cursorSlot, line: stmt.line, synthetic: true);
    fc.builder.emitOp(OpCode.getIndex, line: stmt.line, synthetic: true);
    final varSlot = fc.declareLocal(varName);
    fc.builder.emitOp(OpCode.setLocal, line: stmt.line, synthetic: true);
    fc.builder.emitU16(varSlot, line: stmt.line, synthetic: true);
    fc.builder.emitOp(OpCode.pop, line: stmt.line, synthetic: true);

    _compileStmt(fc, body);
    fc.endScope();

    // cursor = cursor + 1
    fc.builder.emitOp(OpCode.getLocal, line: stmt.line, synthetic: true);
    fc.builder.emitU16(cursorSlot, line: stmt.line, synthetic: true);
    fc.builder.emitOp(OpCode.constant, line: stmt.line, synthetic: true);
    fc.builder.emitU16(fc.builder.addConstant(const IntValue(1)), line: stmt.line, synthetic: true);
    fc.builder.emitOp(OpCode.add, line: stmt.line, synthetic: true);
    fc.builder.emitOp(OpCode.setLocal, line: stmt.line, synthetic: true);
    fc.builder.emitU16(cursorSlot, line: stmt.line, synthetic: true);
    fc.builder.emitOp(OpCode.pop, line: stmt.line, synthetic: true);

    fc.builder.emitOp(OpCode.jump, line: stmt.line, synthetic: true);
    fc.builder.emitU16(loopStart, line: stmt.line, synthetic: true);
    fc.builder.patchU16At(exitJump, fc.builder.offset);
    for (final b in loop.breakJumps) {
      fc.builder.patchU16At(b, fc.builder.offset);
    }
    for (final c in loop.continueJumps) {
      fc.builder.patchU16At(c, loopStart);
    }
    fc.loopStack.removeLast();
    fc.endScope();
  }

  void _compileNamedFunction(_FunctionCompiler fc, int line, String name, List<IrParam> params, List<IrStmt> body, {required bool isMethod}) {
    final reserveLocal = !isMethod && fc.scopeDepth != 0;
    int? reservedSlot;
    if (reserveLocal) {
      reservedSlot = fc.declareLocal(name);
    }
    final fnValue = _compileFunction(fc, name, params, body, isMethod: isMethod);
    final protoIdx = fc.builder.addConstant(fnValue);
    fc.builder.emitOp(OpCode.closure, line: line);
    fc.builder.emitU16(protoIdx, line: line);
    if (fc.scopeDepth == 0) {
      final nameIdx = fc.builder.addConstant(StrValue(name));
      fc.builder.emitOp(OpCode.defineGlobal, line: line);
      fc.builder.emitU16(nameIdx, line: line);
    } else if (reservedSlot != null) {
      fc.builder.emitOp(OpCode.setLocal, line: line);
      fc.builder.emitU16(reservedSlot, line: line);
      fc.builder.emitOp(OpCode.pop, line: line);
    }
  }

  FunctionValue _compileFunction(_FunctionCompiler? enclosing, String name, List<IrParam> params, List<IrStmt> body, {required bool isMethod}) {
    final fc = _FunctionCompiler(enclosing: enclosing, name: name, arity: params.length);
    fc.scopeDepth = 1;
    if (isMethod) fc.declareLocal('this');
    var minArity = params.length;
    for (var i = 0; i < params.length; i++) {
      fc.declareLocal(params[i].name);
      if (params[i].defaultValue != null && i < minArity) minArity = i;
    }
    // A trailing optional parameter the caller didn't supply keeps its
    // Cell's initial NullValue — which for `[this.next]`-style params with
    // no explicit default *is* the correct default, so only parameters with
    // an explicit default need this prologue.
    for (final p in params) {
      if (p.defaultValue == null) continue;
      _compileStmt(
        fc,
        IrIf(
          line: p.defaultValue!.line,
          synthetic: true,
          condition: IrBinary(line: p.defaultValue!.line, synthetic: true, op: IrBinaryOp.eq, left: IrIdentifier(line: p.defaultValue!.line, name: p.name), right: IrLiteral(line: p.defaultValue!.line, synthetic: true, kind: IrLiteralKind.nullLit, value: null)),
          thenBranch: IrExprStmt(line: p.defaultValue!.line, synthetic: true, expr: IrAssign(line: p.defaultValue!.line, synthetic: true, name: p.name, value: p.defaultValue!)),
        ),
      );
    }
    for (final stmt in body) {
      _compileStmt(fc, stmt);
    }
    final endLine = body.isEmpty ? 0 : body.last.line;
    fc.builder.emitOp(OpCode.nullLit, line: endLine, synthetic: true);
    fc.builder.emitOp(OpCode.ret, line: endLine, synthetic: true);
    final proto = FunctionProto(
      name: name,
      arity: fc.arity,
      minArity: minArity,
      chunk: fc.builder.build(),
      upvalues: fc.upvalues,
      exceptionTable: fc.exceptionTable,
      maxLocals: fc.maxLocalsSeen,
    );
    return FunctionValue(name: name, arity: fc.arity, chunk: proto);
  }

  void _compileClass(_FunctionCompiler fc, int line, String name, String? superclass, List<IrFunctionDecl> methods) {
    if (superclass != null) {
      _loadVariable(fc, superclass, line, synthetic: true);
    }
    final nameIdx = fc.builder.addConstant(StrValue(name));
    fc.builder.emitOp(OpCode.classDecl, line: line);
    fc.builder.emitU16(nameIdx, line: line);
    fc.builder.emitByte(superclass != null ? 1 : 0, line: line);

    for (final m in methods) {
      final methodValue = _compileFunction(fc, m.name, m.params, m.body, isMethod: true);
      final protoIdx = fc.builder.addConstant(methodValue);
      fc.builder.emitOp(OpCode.closure, line: m.line);
      fc.builder.emitU16(protoIdx, line: m.line);
      final methodNameIdx = fc.builder.addConstant(StrValue(m.name));
      fc.builder.emitOp(OpCode.method, line: m.line);
      fc.builder.emitU16(methodNameIdx, line: m.line);
    }

    if (fc.scopeDepth == 0) {
      fc.builder.emitOp(OpCode.defineGlobal, line: line);
      fc.builder.emitU16(nameIdx, line: line);
    } else {
      final slot = fc.declareLocal(name);
      fc.builder.emitOp(OpCode.setLocal, line: line);
      fc.builder.emitU16(slot, line: line);
      fc.builder.emitOp(OpCode.pop, line: line);
    }
  }

  void _compileTry(_FunctionCompiler fc, IrTry stmt) {
    final startPc = fc.builder.offset;
    _compileStmt(fc, stmt.body);
    final endPc = fc.builder.offset;

    if (stmt.catchBody != null) {
      if (stmt.finallyBody != null) _compileStmt(fc, stmt.finallyBody!);
      final normalJump = fc.builder.emitJump(OpCode.jump, line: stmt.line, synthetic: true);
      final catchPc = fc.builder.offset;
      fc.beginScope();
      final slot = fc.declareLocal(stmt.catchVar ?? '<exc>');
      fc.builder.emitOp(OpCode.setLocal, line: stmt.line, synthetic: true);
      fc.builder.emitU16(slot, line: stmt.line, synthetic: true);
      fc.builder.emitOp(OpCode.pop, line: stmt.line, synthetic: true);
      _compileStmt(fc, stmt.catchBody!);
      if (stmt.finallyBody != null) _compileStmt(fc, stmt.finallyBody!);
      fc.endScope();
      fc.builder.patchU16At(normalJump, fc.builder.offset);
      fc.exceptionTable.add(ExceptionHandler(startPc: startPc, endPc: endPc, catchPc: catchPc));
      return;
    }

    if (stmt.finallyBody != null) {
      // No catch clause: run finally, then rethrow (desugared as if this
      // were `try { body } catch (e) { finally-body; throw e; } finally { finally-body; }`).
      _compileStmt(fc, stmt.finallyBody!);
      final normalJump = fc.builder.emitJump(OpCode.jump, line: stmt.line, synthetic: true);
      final catchPc = fc.builder.offset;
      fc.beginScope();
      final slot = fc.declareLocal('<exc>');
      fc.builder.emitOp(OpCode.setLocal, line: stmt.line, synthetic: true);
      fc.builder.emitU16(slot, line: stmt.line, synthetic: true);
      fc.builder.emitOp(OpCode.pop, line: stmt.line, synthetic: true);
      _compileStmt(fc, stmt.finallyBody!);
      fc.builder.emitOp(OpCode.getLocal, line: stmt.line, synthetic: true);
      fc.builder.emitU16(slot, line: stmt.line, synthetic: true);
      fc.builder.emitOp(OpCode.throwOp, line: stmt.line, synthetic: true);
      fc.endScope();
      fc.builder.patchU16At(normalJump, fc.builder.offset);
      fc.exceptionTable.add(ExceptionHandler(startPc: startPc, endPc: endPc, catchPc: catchPc));
    }
    // Neither catch nor finally: a no-op wrapper, nothing further to emit.
  }

  // -------------------------------------------------------------------
  // Expressions
  // -------------------------------------------------------------------

  void _compileExpr(_FunctionCompiler fc, IrExpr expr) {
    switch (expr) {
      case IrLiteral(:final kind, :final value):
        _compileLiteral(fc, expr.line, expr.synthetic, kind, value);
      case IrIdentifier(:final name):
        _loadVariable(fc, name, expr.line, synthetic: expr.synthetic);
      case IrRawValue(:final value):
        final idx = fc.builder.addConstant(value);
        fc.builder.emitOp(OpCode.constant, line: expr.line, synthetic: expr.synthetic);
        fc.builder.emitU16(idx, line: expr.line, synthetic: expr.synthetic);
      case IrClosureRef(:final name):
        _loadVariable(fc, name, expr.line, synthetic: expr.synthetic);
      case IrBinary(:final op, :final left, :final right):
        _compileBinary(fc, expr.line, expr.synthetic, op, left, right);
      case IrUnary(:final op, :final operand):
        _compileExpr(fc, operand);
        fc.builder.emitOp(op == IrUnaryOp.negate ? OpCode.negate : OpCode.not, line: expr.line, synthetic: expr.synthetic);
      case IrConditional(:final condition, :final thenExpr, :final elseExpr):
        _compileExpr(fc, condition);
        final elseJump = fc.builder.emitJump(OpCode.jumpIfFalse, line: expr.line, synthetic: expr.synthetic);
        _compileExpr(fc, thenExpr);
        final endJump = fc.builder.emitJump(OpCode.jump, line: expr.line, synthetic: expr.synthetic);
        fc.builder.patchU16At(elseJump, fc.builder.offset);
        _compileExpr(fc, elseExpr);
        fc.builder.patchU16At(endJump, fc.builder.offset);
      case IrAssign(:final name, :final value):
        _compileExpr(fc, value);
        _storeVariable(fc, name, expr.line, synthetic: expr.synthetic);
      case IrIndexGet(:final receiver, :final index):
        _compileExpr(fc, receiver);
        _compileExpr(fc, index);
        fc.builder.emitOp(OpCode.getIndex, line: expr.line, synthetic: expr.synthetic);
      case IrIndexSet(:final receiver, :final index, :final value):
        _compileExpr(fc, receiver);
        _compileExpr(fc, index);
        _compileExpr(fc, value);
        fc.builder.emitOp(OpCode.setIndex, line: expr.line, synthetic: expr.synthetic);
      case IrSlice():
        throw CompilerUnsupported('slicing is not supported by this frontend');
      case IrPropertyGet(:final receiver, :final name):
        _compileExpr(fc, receiver);
        final idx = fc.builder.addConstant(StrValue(name));
        fc.builder.emitOp(OpCode.getProperty, line: expr.line, synthetic: expr.synthetic);
        fc.builder.emitU16(idx, line: expr.line, synthetic: expr.synthetic);
      case IrPropertySet(:final receiver, :final name, :final value):
        _compileExpr(fc, receiver);
        _compileExpr(fc, value);
        final idx = fc.builder.addConstant(StrValue(name));
        fc.builder.emitOp(OpCode.setProperty, line: expr.line, synthetic: expr.synthetic);
        fc.builder.emitU16(idx, line: expr.line, synthetic: expr.synthetic);
      case IrCall(:final callee, :final args):
        _compileExpr(fc, callee);
        for (final a in args) {
          if (a is IrSpread) throw CompilerUnsupported('spread call arguments are not supported by this frontend');
          _compileExpr(fc, a);
        }
        fc.builder.emitOp(OpCode.call, line: expr.line, synthetic: expr.synthetic);
        fc.builder.emitByte(args.length, line: expr.line, synthetic: expr.synthetic);
      case IrSuperCall(:final name, :final args):
        for (final a in args) {
          if (a is IrSpread) throw CompilerUnsupported('spread call arguments are not supported by this frontend');
          _compileExpr(fc, a);
        }
        final idx = fc.builder.addConstant(StrValue(name));
        fc.builder.emitOp(OpCode.superCall, line: expr.line, synthetic: expr.synthetic);
        fc.builder.emitU16(idx, line: expr.line, synthetic: expr.synthetic);
        fc.builder.emitByte(args.length, line: expr.line, synthetic: expr.synthetic);
      case IrListLiteral(:final items):
        for (final i in items) {
          if (i is IrSpread) throw CompilerUnsupported('spread in list literals is not supported by this frontend');
          _compileExpr(fc, i);
        }
        fc.builder.emitOp(OpCode.buildList, line: expr.line, synthetic: expr.synthetic);
        fc.builder.emitU16(items.length, line: expr.line, synthetic: expr.synthetic);
      case IrTupleLiteral():
        throw CompilerUnsupported('tuples are not supported by this frontend');
      case IrMapLiteral(:final keys, :final values):
        for (var i = 0; i < keys.length; i++) {
          _compileExpr(fc, keys[i]);
          _compileExpr(fc, values[i]);
        }
        fc.builder.emitOp(OpCode.buildMap, line: expr.line, synthetic: expr.synthetic);
        fc.builder.emitU16(keys.length, line: expr.line, synthetic: expr.synthetic);
      case IrSetLiteral(:final items):
        for (final i in items) {
          if (i is IrSpread) throw CompilerUnsupported('spread in set literals is not supported by this frontend');
          _compileExpr(fc, i);
        }
        fc.builder.emitOp(OpCode.buildSet, line: expr.line, synthetic: expr.synthetic);
        fc.builder.emitU16(items.length, line: expr.line, synthetic: expr.synthetic);
      case IrSpread():
        throw CompilerUnsupported('spread is only meaningful inside a call or collection literal');
      case IrLambda(:final name, :final params, :final body):
        final fnValue = _compileFunction(fc, name ?? '<anonymous>', params, body, isMethod: false);
        final protoIdx = fc.builder.addConstant(fnValue);
        fc.builder.emitOp(OpCode.closure, line: expr.line, synthetic: expr.synthetic);
        fc.builder.emitU16(protoIdx, line: expr.line, synthetic: expr.synthetic);
      case IrTemplateString(:final parts):
        for (final p in parts) {
          if (p is String) {
            final idx = fc.builder.addConstant(StrValue(p));
            fc.builder.emitOp(OpCode.constant, line: expr.line, synthetic: expr.synthetic);
            fc.builder.emitU16(idx, line: expr.line, synthetic: expr.synthetic);
          } else if (p is IrExpr) {
            _compileExpr(fc, p);
            fc.builder.emitOp(OpCode.stringify, line: expr.line, synthetic: expr.synthetic);
          } else {
            throw CompilerUnsupported('template string part must be a String or IrExpr, got $p');
          }
        }
        fc.builder.emitOp(OpCode.buildString, line: expr.line, synthetic: expr.synthetic);
        fc.builder.emitU16(parts.length, line: expr.line, synthetic: expr.synthetic);
      case IrComprehension():
        throw CompilerUnsupported('comprehensions are not supported by this frontend');
    }
  }

  void _compileLiteral(_FunctionCompiler fc, int line, bool synthetic, IrLiteralKind kind, Object? value) {
    switch (kind) {
      case IrLiteralKind.intLit:
        final idx = fc.builder.addConstant(IntValue(value as int));
        fc.builder.emitOp(OpCode.constant, line: line, synthetic: synthetic);
        fc.builder.emitU16(idx, line: line, synthetic: synthetic);
      case IrLiteralKind.numLit:
        final idx = fc.builder.addConstant(NumValue(value as double));
        fc.builder.emitOp(OpCode.constant, line: line, synthetic: synthetic);
        fc.builder.emitU16(idx, line: line, synthetic: synthetic);
      case IrLiteralKind.strLit:
        final idx = fc.builder.addConstant(StrValue(value as String));
        fc.builder.emitOp(OpCode.constant, line: line, synthetic: synthetic);
        fc.builder.emitU16(idx, line: line, synthetic: synthetic);
      case IrLiteralKind.boolLit:
        fc.builder.emitOp((value as bool) ? OpCode.trueLit : OpCode.falseLit, line: line, synthetic: synthetic);
      case IrLiteralKind.nullLit:
        fc.builder.emitOp(OpCode.nullLit, line: line, synthetic: synthetic);
    }
  }

  void _compileBinary(_FunctionCompiler fc, int line, bool synthetic, IrBinaryOp op, IrExpr left, IrExpr right) {
    if (op == IrBinaryOp.and) {
      _compileExpr(fc, left);
      fc.builder.emitOp(OpCode.dup, line: line, synthetic: synthetic);
      final shortCircuit = fc.builder.emitJump(OpCode.jumpIfFalse, line: line, synthetic: synthetic);
      fc.builder.emitOp(OpCode.pop, line: line, synthetic: synthetic);
      _compileExpr(fc, right);
      fc.builder.patchU16At(shortCircuit, fc.builder.offset);
      return;
    }
    if (op == IrBinaryOp.or) {
      _compileExpr(fc, left);
      fc.builder.emitOp(OpCode.dup, line: line, synthetic: synthetic);
      final shortCircuit = fc.builder.emitJump(OpCode.jumpIfTrue, line: line, synthetic: synthetic);
      fc.builder.emitOp(OpCode.pop, line: line, synthetic: synthetic);
      _compileExpr(fc, right);
      fc.builder.patchU16At(shortCircuit, fc.builder.offset);
      return;
    }
    if (op == IrBinaryOp.ifNull) {
      _compileExpr(fc, left);
      fc.builder.emitOp(OpCode.dup, line: line, synthetic: synthetic);
      fc.builder.emitOp(OpCode.nullLit, line: line, synthetic: synthetic);
      fc.builder.emitOp(OpCode.notEqual, line: line, synthetic: synthetic);
      final keepLeft = fc.builder.emitJump(OpCode.jumpIfTrue, line: line, synthetic: synthetic);
      fc.builder.emitOp(OpCode.pop, line: line, synthetic: synthetic);
      _compileExpr(fc, right);
      fc.builder.patchU16At(keepLeft, fc.builder.offset);
      return;
    }
    _compileExpr(fc, left);
    _compileExpr(fc, right);
    final opcode = switch (op) {
      IrBinaryOp.add => OpCode.add,
      IrBinaryOp.sub => OpCode.subtract,
      IrBinaryOp.mul => OpCode.multiply,
      IrBinaryOp.div => OpCode.divide,
      IrBinaryOp.floorDiv => OpCode.floorDivide,
      IrBinaryOp.truncDiv => OpCode.truncDivide,
      IrBinaryOp.mod => OpCode.modulo,
      IrBinaryOp.eq => OpCode.equal,
      IrBinaryOp.notEq => OpCode.notEqual,
      IrBinaryOp.lt => OpCode.less,
      IrBinaryOp.lte => OpCode.lessEqual,
      IrBinaryOp.gt => OpCode.greater,
      IrBinaryOp.gte => OpCode.greaterEqual,
      IrBinaryOp.and || IrBinaryOp.or || IrBinaryOp.ifNull => throw StateError('handled above'),
    };
    fc.builder.emitOp(opcode, line: line, synthetic: synthetic);
  }
}
