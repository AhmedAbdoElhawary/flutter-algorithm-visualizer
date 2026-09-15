/// A recursive-descent parser for the supported Dart subset (see
/// contracts/frontend-contract.md's "Dart additionally" section), producing
/// shared Core IR. Generics are parsed and ignored (never a syntax error);
/// closures, single inheritance, and exceptions all lower to the same IR
/// every other language will use.
library;

import '../../errors/failure.dart';
import '../../ir/ir.dart';
import 'dart_lexer.dart';

class _ClassMember {
  _ClassMember.field(this.fieldName) : method = null, isConstructor = false;
  _ClassMember.method(IrFunctionDecl m) : method = m, fieldName = null, isConstructor = false;
  _ClassMember.constructor(IrFunctionDecl m) : method = m, fieldName = null, isConstructor = true;
  final String? fieldName;
  final IrFunctionDecl? method;
  final bool isConstructor;
}

class DartParser {
  List<DartToken> _tokens = const <DartToken>[];
  int _pos = 0;

  List<IrStmt> parseProgram(String source) {
    _tokens = DartLexer().tokenize(source);
    _pos = 0;
    final statements = <IrStmt>[];
    while (!_isAtEnd) {
      statements.add(_declarationOrStatement());
    }
    return statements;
  }

  // ---------------------------------------------------------------------
  // Token cursor helpers
  // ---------------------------------------------------------------------

  DartToken get _peek => _tokens[_pos];
  DartToken _peekAhead(int n) => _tokens[(_pos + n).clamp(0, _tokens.length - 1)];
  bool get _isAtEnd => _peek.type == DartTokenType.eof;
  DartToken _advance() {
    final t = _peek;
    if (!_isAtEnd) _pos++;
    return t;
  }

  bool _check(DartTokenType type) => !_isAtEnd && _peek.type == type;
  bool _checkId(String lexeme) => _check(DartTokenType.identifier) && _peek.lexeme == lexeme;
  bool _match(DartTokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  bool _matchId(String lexeme) {
    if (_checkId(lexeme)) {
      _advance();
      return true;
    }
    return false;
  }

  DartToken _expect(DartTokenType type, String code) {
    if (_check(type)) return _advance();
    throw _syntaxError(code);
  }

  FrontendFailure _syntaxError(String code, [Map<String, Object?> data = const <String, Object?>{}]) =>
      FrontendFailure(kind: FailureKind.syntax, code: code, data: data, line: _peek.line);

  FrontendFailure _unsupported(String construct, [int? line]) =>
      FrontendFailure(kind: FailureKind.unsupported, code: 'unsupportedConstruct', data: <String, Object?>{'construct': construct}, line: line ?? _peek.line);

  // ---------------------------------------------------------------------
  // Types (parsed and ignored — must never cause a syntax error)
  // ---------------------------------------------------------------------

  /// Keywords that must never be mistaken for a type or declaration name by
  /// the speculative lookahead below — without this, `return fib(n - 1);`
  /// reads as "a function named `fib` of return-type `return`".
  static const Set<String> _reservedWords = <String>{
    'return', 'if', 'else', 'while', 'for', 'break', 'continue', 'throw',
    'try', 'catch', 'finally', 'class', 'var', 'final', 'const', 'true',
    'false', 'null', 'new', 'super', 'this', 'extends', 'implements',
    'with', 'static', 'in', 'on', 'async', 'await', 'yield',
  };

  bool _trySkipType() {
    if (_checkId('void')) {
      _advance();
      _skipNullable();
      return true;
    }
    if (!_check(DartTokenType.identifier) || _reservedWords.contains(_peek.lexeme)) return false;
    _advance();
    if (_check(DartTokenType.less)) _skipGenericArgs();
    _skipNullable();
    if (_checkId('Function')) {
      _advance();
      if (_check(DartTokenType.leftParen)) {
        _skipParens();
        _skipNullable();
      }
    }
    return true;
  }

  void _skipNullable() {
    if (_check(DartTokenType.question)) _advance();
  }

  void _skipGenericArgs() {
    _expect(DartTokenType.less, 'expectedGenericOpen');
    var depth = 1;
    while (depth > 0) {
      if (_isAtEnd) throw _syntaxError('unexpectedEndOfInput');
      if (_check(DartTokenType.less)) {
        depth++;
      } else if (_check(DartTokenType.greater)) {
        depth--;
      }
      _advance();
    }
  }

  void _skipParens() {
    _expect(DartTokenType.leftParen, 'expectedOpenParen');
    var depth = 1;
    while (depth > 0) {
      if (_isAtEnd) throw _syntaxError('unexpectedEndOfInput');
      if (_check(DartTokenType.leftParen)) {
        depth++;
      } else if (_check(DartTokenType.rightParen)) {
        depth--;
      }
      _advance();
    }
  }

  bool _looksLikeTypedDeclarationHere() {
    final mark = _pos;
    final hadType = _trySkipType();
    var ok = false;
    if (hadType && _check(DartTokenType.identifier) && !_reservedWords.contains(_peek.lexeme)) {
      _advance();
      // `T identity<T>(...)` — a generic type-parameter list on the
      // declared name itself, before the real parameter list.
      if (_check(DartTokenType.less)) _skipGenericArgs();
      final t = _peek.type;
      ok = t == DartTokenType.leftParen || t == DartTokenType.equal || t == DartTokenType.semicolon || t == DartTokenType.comma;
    }
    _pos = mark;
    return ok;
  }

  // ---------------------------------------------------------------------
  // Declarations & statements
  // ---------------------------------------------------------------------

  IrStmt _declarationOrStatement() {
    if (_checkId('class')) return _classDecl();
    if (_checkId('var') || _checkId('final') || _checkId('const')) return _varDeclKeywordForm();
    if (_looksLikeTypedDeclarationHere()) return _typedDeclaration();
    return _statement();
  }

  IrStmt _varDeclKeywordForm() {
    final line = _peek.line;
    _advance();
    if (_looksLikeTypedDeclarationHere()) _trySkipType();
    final name = _expect(DartTokenType.identifier, 'expectedVariableName').lexeme;
    IrExpr? init;
    if (_match(DartTokenType.equal)) init = _expression();
    _expect(DartTokenType.semicolon, 'expectedSemicolon');
    return IrVarDecl(line: line, name: name, initializer: init);
  }

  IrStmt _typedDeclaration() {
    final line = _peek.line;
    _trySkipType();
    final name = _expect(DartTokenType.identifier, 'expectedDeclarationName').lexeme;
    if (_check(DartTokenType.less)) _skipGenericArgs();
    if (_check(DartTokenType.leftParen)) return _functionDeclAfterName(line, name);
    IrExpr? init;
    if (_match(DartTokenType.equal)) init = _expression();
    _expect(DartTokenType.semicolon, 'expectedSemicolon');
    return IrVarDecl(line: line, name: name, initializer: init);
  }

  /// `async`, `async*` and `sync*` function modifiers, and bare `await`/
  /// `yield` expressions, are valid Dart but out of scope (spec.md's Out of
  /// Scope: generators, async/await) — rejected as `unsupported`, never
  /// `syntax` (SC-009).
  void _rejectAsyncModifier() {
    if (_checkId('async') || _checkId('sync')) {
      final line = _peek.line;
      _advance();
      _match(DartTokenType.star);
      throw _unsupported('async/generator functions', line);
    }
  }

  IrStmt _functionDeclAfterName(int line, String name) {
    final params = _parseParamList(allowThis: false);
    _rejectAsyncModifier();
    if (_match(DartTokenType.arrow)) {
      final expr = _expression();
      _expect(DartTokenType.semicolon, 'expectedSemicolon');
      return IrFunctionDecl(line: line, name: name, params: params, body: <IrStmt>[IrReturn(line: line, value: expr)]);
    }
    final body = _block();
    return IrFunctionDecl(line: line, name: name, params: params, body: body.statements);
  }

  List<IrParam> _parseParamList({required bool allowThis}) {
    _expect(DartTokenType.leftParen, 'expectedOpenParen');
    final params = <IrParam>[];
    while (!_check(DartTokenType.rightParen) && !_check(DartTokenType.leftBracket) && !_check(DartTokenType.leftBrace)) {
      params.add(_parseParam(allowThis: allowThis));
      if (!_match(DartTokenType.comma)) break;
    }
    if (_check(DartTokenType.leftBracket)) {
      _advance();
      while (!_check(DartTokenType.rightBracket)) {
        params.add(_parseParam(allowThis: allowThis));
        if (!_match(DartTokenType.comma)) break;
      }
      _expect(DartTokenType.rightBracket, 'expectedCloseBracket');
    } else if (_check(DartTokenType.leftBrace)) {
      throw _unsupported('named parameters');
    }
    _expect(DartTokenType.rightParen, 'expectedCloseParen');
    return params;
  }

  IrParam _parseParam({required bool allowThis}) {
    if (allowThis && _checkId('this') && _peekAhead(1).type == DartTokenType.dot) {
      _advance();
      _advance();
      final name = _expect(DartTokenType.identifier, 'expectedParameterName').lexeme;
      IrExpr? def;
      if (_match(DartTokenType.equal)) def = _expression();
      return IrParam('this.$name', defaultValue: def);
    }
    final mark = _pos;
    final hadType = _trySkipType();
    if (hadType && _check(DartTokenType.identifier)) {
      final name = _advance().lexeme;
      IrExpr? def;
      if (_match(DartTokenType.equal)) def = _expression();
      return IrParam(name, defaultValue: def);
    }
    _pos = mark;
    final name = _expect(DartTokenType.identifier, 'expectedParameterName').lexeme;
    IrExpr? def;
    if (_match(DartTokenType.equal)) def = _expression();
    return IrParam(name, defaultValue: def);
  }

  IrStmt _classDecl() {
    final line = _peek.line;
    _advance();
    final name = _expect(DartTokenType.identifier, 'expectedClassName').lexeme;
    if (_check(DartTokenType.less)) _skipGenericArgs();
    String? superclass;
    if (_matchId('extends')) {
      superclass = _expect(DartTokenType.identifier, 'expectedSuperclassName').lexeme;
      if (_check(DartTokenType.less)) _skipGenericArgs();
    }
    while (_matchId('implements') || _matchId('with')) {
      _expect(DartTokenType.identifier, 'expectedTypeName');
      while (_match(DartTokenType.comma)) {
        _expect(DartTokenType.identifier, 'expectedTypeName');
      }
    }
    _expect(DartTokenType.leftBrace, 'expectedOpenBrace');
    final methods = <IrFunctionDecl>[];
    final fieldNames = <String>[];
    IrFunctionDecl? constructor;
    while (!_check(DartTokenType.rightBrace)) {
      final member = _classMember(name);
      if (member.isConstructor) {
        constructor = member.method;
      } else if (member.method != null) {
        methods.add(member.method!);
      } else if (member.fieldName != null) {
        fieldNames.add(member.fieldName!);
      }
    }
    _expect(DartTokenType.rightBrace, 'expectedCloseBrace');
    if (constructor != null) methods.add(constructor);
    return IrClassDecl(line: line, name: name, superclass: superclass, methods: methods, fieldNames: fieldNames);
  }

  _ClassMember _classMember(String className) {
    final line = _peek.line;
    _matchId('static');

    if (_checkId(className) && _peekAhead(1).type == DartTokenType.leftParen) {
      _advance();
      return _ClassMember.constructor(_constructorBody(line, className));
    }

    if (_checkId('var') || _checkId('final') || _checkId('const')) {
      _advance();
      _trySkipType();
      final fname = _expect(DartTokenType.identifier, 'expectedFieldName').lexeme;
      IrExpr? init;
      if (_match(DartTokenType.equal)) init = _expression();
      _expect(DartTokenType.semicolon, 'expectedSemicolon');
      if (init != null) throw _unsupported('field initializers', line);
      return _ClassMember.field(fname);
    }

    final mark = _pos;
    final hadType = _trySkipType();
    if (hadType && _check(DartTokenType.identifier)) {
      final mname = _advance().lexeme;
      if (_check(DartTokenType.less)) _skipGenericArgs();
      if (_check(DartTokenType.leftParen)) return _ClassMember.method(_finishMethod(line, mname));
      IrExpr? init;
      if (_match(DartTokenType.equal)) init = _expression();
      _expect(DartTokenType.semicolon, 'expectedSemicolon');
      if (init != null) throw _unsupported('field initializers', line);
      return _ClassMember.field(mname);
    }
    _pos = mark;

    if (_check(DartTokenType.identifier)) {
      final mname = _advance().lexeme;
      if (_check(DartTokenType.leftParen)) return _ClassMember.method(_finishMethod(line, mname));
    }
    throw _syntaxError('expectedClassMember');
  }

  IrFunctionDecl _finishMethod(int line, String name) {
    final params = _parseParamList(allowThis: false);
    _rejectAsyncModifier();
    if (_match(DartTokenType.arrow)) {
      final expr = _expression();
      _expect(DartTokenType.semicolon, 'expectedSemicolon');
      return IrFunctionDecl(line: line, name: name, params: params, body: <IrStmt>[IrReturn(line: line, value: expr)]);
    }
    if (_match(DartTokenType.semicolon)) {
      return IrFunctionDecl(line: line, name: name, params: params, body: const <IrStmt>[]);
    }
    final body = _block();
    return IrFunctionDecl(line: line, name: name, params: params, body: body.statements);
  }

  IrFunctionDecl _constructorBody(int line, String className) {
    final params = _parseParamList(allowThis: true);
    if (_match(DartTokenType.colon)) {
      // Initializer list (`: this.x = y * 2, super(...)`) — skipped
      // syntactically. None of this problem bank's custom-object shapes use
      // one (they rely on `this.x` shorthand params only); a documented
      // scope cut rather than a silent one.
      var depth = 0;
      while (!(depth == 0 && (_check(DartTokenType.leftBrace) || _check(DartTokenType.semicolon)))) {
        if (_isAtEnd) throw _syntaxError('unexpectedEndOfInput');
        if (_check(DartTokenType.leftParen) || _check(DartTokenType.leftBracket)) depth++;
        if (_check(DartTokenType.rightParen) || _check(DartTokenType.rightBracket)) depth--;
        _advance();
      }
    }
    final prologue = <IrStmt>[];
    final cleanParams = <IrParam>[];
    for (final p in params) {
      if (p.name.startsWith('this.')) {
        final fieldName = p.name.substring(5);
        cleanParams.add(IrParam(fieldName, defaultValue: p.defaultValue));
        prologue.add(IrExprStmt(
          line: line,
          synthetic: true,
          expr: IrPropertySet(line: line, synthetic: true, receiver: IrIdentifier(line: line, name: 'this'), name: fieldName, value: IrIdentifier(line: line, name: fieldName)),
        ));
      } else {
        cleanParams.add(p);
      }
    }
    List<IrStmt> body;
    if (_match(DartTokenType.semicolon)) {
      body = prologue;
    } else {
      body = <IrStmt>[...prologue, ..._block().statements];
    }
    return IrFunctionDecl(line: line, name: '<init>', params: cleanParams, body: body);
  }

  IrBlock _block() {
    final line = _peek.line;
    _expect(DartTokenType.leftBrace, 'expectedOpenBrace');
    final stmts = <IrStmt>[];
    while (!_check(DartTokenType.rightBrace)) {
      stmts.add(_declarationOrStatement());
    }
    _expect(DartTokenType.rightBrace, 'expectedCloseBrace');
    return IrBlock(line: line, statements: stmts);
  }

  IrStmt _statement() {
    final line = _peek.line;
    if (_check(DartTokenType.leftBrace)) return _block();
    if (_matchId('if')) return _ifStatement(line);
    if (_matchId('while')) return _whileStatement(line);
    if (_matchId('for')) return _forStatement(line);
    if (_matchId('break')) {
      _expect(DartTokenType.semicolon, 'expectedSemicolon');
      return IrBreak(line: line);
    }
    if (_matchId('continue')) {
      _expect(DartTokenType.semicolon, 'expectedSemicolon');
      return IrContinue(line: line);
    }
    if (_matchId('return')) {
      if (_match(DartTokenType.semicolon)) return IrReturn(line: line);
      final v = _expression();
      _expect(DartTokenType.semicolon, 'expectedSemicolon');
      return IrReturn(line: line, value: v);
    }
    if (_matchId('throw')) {
      final v = _expression();
      _expect(DartTokenType.semicolon, 'expectedSemicolon');
      return IrThrow(line: line, value: v);
    }
    if (_matchId('try')) return _tryStatement(line);
    if (_checkId('class')) return _classDecl();
    if (_checkId('print') && _peekAhead(1).type == DartTokenType.leftParen) {
      _advance();
      final args = _argumentList();
      _expect(DartTokenType.semicolon, 'expectedSemicolon');
      final value = args.isEmpty ? const IrLiteral(line: 0, kind: IrLiteralKind.nullLit, value: null) : args[0];
      return IrPrint(line: line, value: value);
    }
    if (_checkId('var') || _checkId('final') || _checkId('const')) return _varDeclKeywordForm();
    if (_looksLikeTypedDeclarationHere()) return _typedDeclaration();

    final expr = _expression();
    _expect(DartTokenType.semicolon, 'expectedSemicolon');
    return IrExprStmt(line: line, expr: expr);
  }

  IrStmt _ifStatement(int line) {
    _expect(DartTokenType.leftParen, 'expectedOpenParen');
    final cond = _expression();
    _expect(DartTokenType.rightParen, 'expectedCloseParen');
    final thenB = _statement();
    IrStmt? elseB;
    if (_matchId('else')) elseB = _statement();
    return IrIf(line: line, condition: cond, thenBranch: thenB, elseBranch: elseB);
  }

  IrStmt _whileStatement(int line) {
    _expect(DartTokenType.leftParen, 'expectedOpenParen');
    final cond = _expression();
    _expect(DartTokenType.rightParen, 'expectedCloseParen');
    final body = _statement();
    return IrWhile(line: line, condition: cond, body: body);
  }

  String? _tryParseForInHeader() {
    if (_checkId('var') || _checkId('final') || _checkId('const')) {
      _advance();
    } else {
      _trySkipType();
    }
    if (!_check(DartTokenType.identifier)) return null;
    final name = _advance().lexeme;
    if (_checkId('in')) {
      _advance();
      return name;
    }
    return null;
  }

  IrStmt _forStatement(int line) {
    _expect(DartTokenType.leftParen, 'expectedOpenParen');
    final mark = _pos;
    final forInVar = _tryParseForInHeader();
    if (forInVar != null) {
      final iterable = _expression();
      _expect(DartTokenType.rightParen, 'expectedCloseParen');
      final body = _statement();
      return IrForIn(line: line, varName: forInVar, iterable: iterable, body: body);
    }
    _pos = mark;

    IrStmt? init;
    if (_match(DartTokenType.semicolon)) {
      init = null;
    } else if (_checkId('var') || _checkId('final') || _checkId('const')) {
      init = _varDeclKeywordForm();
    } else if (_looksLikeTypedDeclarationHere()) {
      init = _typedDeclaration();
    } else {
      final expr = _expression();
      _expect(DartTokenType.semicolon, 'expectedSemicolon');
      init = IrExprStmt(line: line, expr: expr);
    }
    IrExpr? cond;
    if (!_check(DartTokenType.semicolon)) cond = _expression();
    _expect(DartTokenType.semicolon, 'expectedSemicolon');
    IrExpr? incr;
    if (!_check(DartTokenType.rightParen)) incr = _expression();
    _expect(DartTokenType.rightParen, 'expectedCloseParen');
    final body = _statement();
    return IrFor(line: line, init: init, condition: cond, increment: incr, body: body);
  }

  IrStmt _tryStatement(int line) {
    final body = _block();
    String? catchVar;
    IrStmt? catchBody;
    IrStmt? finallyBody;
    if (_matchId('on')) {
      _expect(DartTokenType.identifier, 'expectedExceptionType');
      if (_check(DartTokenType.less)) _skipGenericArgs();
      if (_matchId('catch')) {
        _expect(DartTokenType.leftParen, 'expectedOpenParen');
        catchVar = _expect(DartTokenType.identifier, 'expectedCatchVariable').lexeme;
        if (_match(DartTokenType.comma)) _expect(DartTokenType.identifier, 'expectedStackTraceVariable');
        _expect(DartTokenType.rightParen, 'expectedCloseParen');
      }
      catchBody = _block();
    } else if (_matchId('catch')) {
      _expect(DartTokenType.leftParen, 'expectedOpenParen');
      catchVar = _expect(DartTokenType.identifier, 'expectedCatchVariable').lexeme;
      if (_match(DartTokenType.comma)) _expect(DartTokenType.identifier, 'expectedStackTraceVariable');
      _expect(DartTokenType.rightParen, 'expectedCloseParen');
      catchBody = _block();
    }
    if (_matchId('finally')) finallyBody = _block();
    return IrTry(line: line, body: body, catchVar: catchVar, catchBody: catchBody, finallyBody: finallyBody);
  }

  // ---------------------------------------------------------------------
  // Expressions (precedence, low to high): assignment, conditional, ??,
  // ||, &&, equality, relational, additive, multiplicative, unary, postfix.
  // ---------------------------------------------------------------------

  IrExpr _expression() => _assignment();

  static const Map<DartTokenType, IrBinaryOp> _compoundOps = <DartTokenType, IrBinaryOp>{
    DartTokenType.plusEqual: IrBinaryOp.add,
    DartTokenType.minusEqual: IrBinaryOp.sub,
    DartTokenType.starEqual: IrBinaryOp.mul,
    DartTokenType.slashEqual: IrBinaryOp.div,
    DartTokenType.tildeSlashEqual: IrBinaryOp.truncDiv,
    DartTokenType.percentEqual: IrBinaryOp.mod,
  };

  IrExpr _assignment() {
    final expr = _conditional();
    if (_check(DartTokenType.equal) || _compoundOps.containsKey(_peek.type) || _check(DartTokenType.questionQuestionEqual)) {
      final opToken = _advance();
      final value = _assignment();
      final line = opToken.line;
      IrExpr computedValue = value;
      if (opToken.type == DartTokenType.questionQuestionEqual) {
        computedValue = IrBinary(line: line, op: IrBinaryOp.ifNull, left: expr, right: value);
      } else if (_compoundOps.containsKey(opToken.type)) {
        computedValue = IrBinary(line: line, op: _compoundOps[opToken.type]!, left: expr, right: value);
      }
      return _wrapAssign(expr, computedValue, line);
    }
    return expr;
  }

  IrExpr _wrapAssign(IrExpr target, IrExpr value, int line) {
    if (target is IrIdentifier) return IrAssign(line: line, name: target.name, value: value);
    if (target is IrIndexGet) return IrIndexSet(line: line, receiver: target.receiver, index: target.index, value: value);
    if (target is IrPropertyGet) return IrPropertySet(line: line, receiver: target.receiver, name: target.name, value: value);
    throw FrontendFailure(kind: FailureKind.syntax, code: 'invalidAssignmentTarget', line: line);
  }

  IrExpr _conditional() {
    final cond = _ifNull();
    if (_match(DartTokenType.question)) {
      final thenE = _expression();
      _expect(DartTokenType.colon, 'expectedColon');
      final elseE = _conditional();
      return IrConditional(line: cond.line, condition: cond, thenExpr: thenE, elseExpr: elseE);
    }
    return cond;
  }

  IrExpr _ifNull() {
    var expr = _or();
    while (_check(DartTokenType.questionQuestion)) {
      final line = _advance().line;
      expr = IrBinary(line: line, op: IrBinaryOp.ifNull, left: expr, right: _or());
    }
    return expr;
  }

  IrExpr _or() {
    var expr = _and();
    while (_check(DartTokenType.pipePipe)) {
      final line = _advance().line;
      expr = IrBinary(line: line, op: IrBinaryOp.or, left: expr, right: _and());
    }
    return expr;
  }

  IrExpr _and() {
    var expr = _equality();
    while (_check(DartTokenType.ampAmp)) {
      final line = _advance().line;
      expr = IrBinary(line: line, op: IrBinaryOp.and, left: expr, right: _equality());
    }
    return expr;
  }

  IrExpr _equality() {
    var expr = _relational();
    while (_check(DartTokenType.equalEqual) || _check(DartTokenType.bangEqual)) {
      final opTok = _advance();
      expr = IrBinary(line: opTok.line, op: opTok.type == DartTokenType.equalEqual ? IrBinaryOp.eq : IrBinaryOp.notEq, left: expr, right: _relational());
    }
    return expr;
  }

  IrExpr _relational() {
    var expr = _additive();
    while (_check(DartTokenType.less) || _check(DartTokenType.lessEqual) || _check(DartTokenType.greater) || _check(DartTokenType.greaterEqual)) {
      final opTok = _advance();
      final op = switch (opTok.type) {
        DartTokenType.less => IrBinaryOp.lt,
        DartTokenType.lessEqual => IrBinaryOp.lte,
        DartTokenType.greater => IrBinaryOp.gt,
        DartTokenType.greaterEqual => IrBinaryOp.gte,
        _ => throw StateError('unreachable'),
      };
      expr = IrBinary(line: opTok.line, op: op, left: expr, right: _additive());
    }
    return expr;
  }

  IrExpr _additive() {
    var expr = _multiplicative();
    while (_check(DartTokenType.plus) || _check(DartTokenType.minus)) {
      final opTok = _advance();
      expr = IrBinary(line: opTok.line, op: opTok.type == DartTokenType.plus ? IrBinaryOp.add : IrBinaryOp.sub, left: expr, right: _multiplicative());
    }
    return expr;
  }

  IrExpr _multiplicative() {
    var expr = _unary();
    while (_check(DartTokenType.star) || _check(DartTokenType.slash) || _check(DartTokenType.tildeSlash) || _check(DartTokenType.percent)) {
      final opTok = _advance();
      final op = switch (opTok.type) {
        DartTokenType.star => IrBinaryOp.mul,
        DartTokenType.slash => IrBinaryOp.div,
        DartTokenType.tildeSlash => IrBinaryOp.truncDiv,
        DartTokenType.percent => IrBinaryOp.mod,
        _ => throw StateError('unreachable'),
      };
      expr = IrBinary(line: opTok.line, op: op, left: expr, right: _unary());
    }
    return expr;
  }

  IrExpr _unary() {
    final line = _peek.line;
    if (_checkId('await')) throw _unsupported('await', line);
    if (_match(DartTokenType.bang)) return IrUnary(line: line, op: IrUnaryOp.not, operand: _unary());
    if (_match(DartTokenType.minus)) return IrUnary(line: line, op: IrUnaryOp.negate, operand: _unary());
    if (_check(DartTokenType.plusPlus) || _check(DartTokenType.minusMinus)) {
      final opTok = _advance();
      final operand = _unary();
      final newVal = IrBinary(line: line, op: opTok.type == DartTokenType.plusPlus ? IrBinaryOp.add : IrBinaryOp.sub, left: operand, right: const IrLiteral(line: 0, kind: IrLiteralKind.intLit, value: 1));
      return _wrapAssign(operand, newVal, line);
    }
    return _postfix(_primary());
  }

  IrExpr _postfix(IrExpr expr) {
    while (true) {
      final line = _peek.line;
      if (_match(DartTokenType.dot)) {
        final name = _expect(DartTokenType.identifier, 'expectedPropertyName').lexeme;
        expr = _check(DartTokenType.leftParen) ? IrCall(line: line, callee: IrPropertyGet(line: line, receiver: expr, name: name), args: _argumentList()) : IrPropertyGet(line: line, receiver: expr, name: name);
        continue;
      }
      if (_match(DartTokenType.questionDot)) {
        final name = _expect(DartTokenType.identifier, 'expectedPropertyName').lexeme;
        final nullCheck = IrBinary(line: line, op: IrBinaryOp.eq, left: expr, right: const IrLiteral(line: 0, kind: IrLiteralKind.nullLit, value: null));
        final access = _check(DartTokenType.leftParen)
            ? IrCall(line: line, callee: IrPropertyGet(line: line, receiver: expr, name: name), args: _argumentList())
            : IrPropertyGet(line: line, receiver: expr, name: name);
        expr = IrConditional(line: line, condition: nullCheck, thenExpr: const IrLiteral(line: 0, kind: IrLiteralKind.nullLit, value: null), elseExpr: access);
        continue;
      }
      if (_match(DartTokenType.leftBracket)) {
        final index = _expression();
        _expect(DartTokenType.rightBracket, 'expectedCloseBracket');
        expr = IrIndexGet(line: line, receiver: expr, index: index);
        continue;
      }
      if (_check(DartTokenType.leftParen)) {
        expr = IrCall(line: line, callee: expr, args: _argumentList());
        continue;
      }
      if (_check(DartTokenType.plusPlus) || _check(DartTokenType.minusMinus)) {
        final opTok = _advance();
        final newVal = IrBinary(line: line, op: opTok.type == DartTokenType.plusPlus ? IrBinaryOp.add : IrBinaryOp.sub, left: expr, right: const IrLiteral(line: 0, kind: IrLiteralKind.intLit, value: 1));
        expr = _wrapAssign(expr, newVal, line);
        continue;
      }
      break;
    }
    return expr;
  }

  List<IrExpr> _argumentList() {
    _expect(DartTokenType.leftParen, 'expectedOpenParen');
    final args = <IrExpr>[];
    while (!_check(DartTokenType.rightParen)) {
      if (_check(DartTokenType.identifier) && _peekAhead(1).type == DartTokenType.colon) {
        _advance();
        _advance();
      }
      args.add(_expression());
      if (!_match(DartTokenType.comma)) break;
    }
    _expect(DartTokenType.rightParen, 'expectedCloseParen');
    return args;
  }

  IrExpr? _tryParseLambda() {
    if (!_check(DartTokenType.leftParen)) return null;
    final mark = _pos;
    final line = _peek.line;
    try {
      final params = _parseParamList(allowThis: false);
      if (_match(DartTokenType.arrow)) {
        final expr = _expression();
        return IrLambda(line: line, params: params, body: <IrStmt>[IrReturn(line: line, value: expr)]);
      }
      if (_check(DartTokenType.leftBrace)) {
        final body = _block();
        return IrLambda(line: line, params: params, body: body.statements);
      }
      _pos = mark;
      return null;
    } on FrontendFailure {
      _pos = mark;
      return null;
    }
  }

  IrExpr _primary() {
    final line = _peek.line;
    if (_check(DartTokenType.intLiteral)) return IrLiteral(line: line, kind: IrLiteralKind.intLit, value: _advance().literal);
    if (_check(DartTokenType.doubleLiteral)) return IrLiteral(line: line, kind: IrLiteralKind.numLit, value: _advance().literal);
    if (_check(DartTokenType.boolLiteral)) return IrLiteral(line: line, kind: IrLiteralKind.boolLit, value: _advance().literal);
    if (_check(DartTokenType.nullLiteral)) {
      _advance();
      return IrLiteral(line: line, kind: IrLiteralKind.nullLit, value: null);
    }
    if (_check(DartTokenType.stringLiteral)) return _buildTemplateString(_advance(), line);

    if (_check(DartTokenType.leftParen)) {
      final lambda = _tryParseLambda();
      if (lambda != null) return lambda;
      _advance();
      final expr = _expression();
      _expect(DartTokenType.rightParen, 'expectedCloseParen');
      return expr;
    }

    if (_check(DartTokenType.less)) {
      _skipGenericArgs();
      if (_check(DartTokenType.leftBracket)) return _listLiteral();
      if (_check(DartTokenType.leftBrace)) return _mapOrSetLiteral();
      throw _syntaxError('expectedCollectionLiteral');
    }
    if (_check(DartTokenType.leftBracket)) return _listLiteral();
    if (_check(DartTokenType.leftBrace)) return _mapOrSetLiteral();

    if (_matchId('new')) return _postfix(_primary());

    if (_checkId('super')) {
      _advance();
      _expect(DartTokenType.dot, 'expectedDot');
      final name = _expect(DartTokenType.identifier, 'expectedMethodName').lexeme;
      return IrSuperCall(line: line, name: name, args: _argumentList());
    }

    if (_check(DartTokenType.identifier)) {
      final name = _advance().lexeme;
      return IrIdentifier(line: line, name: name);
    }

    throw _syntaxError('unexpectedToken', <String, Object?>{'token': _peek.lexeme});
  }

  IrExpr _listLiteral() {
    final line = _peek.line;
    _advance();
    final items = <IrExpr>[];
    while (!_check(DartTokenType.rightBracket)) {
      if (_check(DartTokenType.dot) && _peekAhead(1).type == DartTokenType.dot && _peekAhead(2).type == DartTokenType.dot) {
        throw _unsupported('spread in collection literals');
      }
      items.add(_expression());
      if (!_match(DartTokenType.comma)) break;
    }
    _expect(DartTokenType.rightBracket, 'expectedCloseBracket');
    return IrListLiteral(line: line, items: items);
  }

  IrExpr _mapOrSetLiteral() {
    final line = _peek.line;
    _advance();
    if (_check(DartTokenType.rightBrace)) {
      _advance();
      return const IrMapLiteral(line: 0, keys: <IrExpr>[], values: <IrExpr>[]);
    }
    final first = _expression();
    if (_match(DartTokenType.colon)) {
      final firstValue = _expression();
      final keys = <IrExpr>[first];
      final values = <IrExpr>[firstValue];
      while (_match(DartTokenType.comma)) {
        if (_check(DartTokenType.rightBrace)) break;
        keys.add(_expression());
        _expect(DartTokenType.colon, 'expectedColon');
        values.add(_expression());
      }
      _expect(DartTokenType.rightBrace, 'expectedCloseBrace');
      return IrMapLiteral(line: line, keys: keys, values: values);
    }
    final items = <IrExpr>[first];
    while (_match(DartTokenType.comma)) {
      if (_check(DartTokenType.rightBrace)) break;
      items.add(_expression());
    }
    _expect(DartTokenType.rightBrace, 'expectedCloseBrace');
    return IrSetLiteral(line: line, items: items);
  }

  IrExpr _buildTemplateString(DartToken token, int line) {
    final rawParts = token.literal! as List<Object>;
    if (rawParts.isEmpty) return IrLiteral(line: line, kind: IrLiteralKind.strLit, value: '');
    if (rawParts.length == 1 && rawParts[0] is String) {
      return IrLiteral(line: line, kind: IrLiteralKind.strLit, value: rawParts[0]);
    }
    final parts = <Object>[];
    for (final p in rawParts) {
      if (p is String) {
        parts.add(p);
        continue;
      }
      final slice = p as InterpolationSlice;
      final subTokens = DartLexer().tokenize(slice.source);
      final subParser = DartParser()
        .._tokens = subTokens
        .._pos = 0;
      parts.add(subParser._expression());
    }
    return IrTemplateString(line: line, parts: parts);
  }
}
