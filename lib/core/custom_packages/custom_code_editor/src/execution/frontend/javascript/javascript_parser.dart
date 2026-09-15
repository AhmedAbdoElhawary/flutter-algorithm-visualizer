/// A recursive-descent parser for the supported JavaScript subset, producing
/// the shared Core IR.
///
/// Four things here are worth knowing before reading the rest:
///
/// **Semicolons are optional.** The lexer records whether a line break came
/// before each token; [_consumeSemicolon] treats that, a closing brace, or
/// end of input as a statement terminator. That is automatic semicolon
/// insertion, kept in one place instead of smeared through the lexer.
///
/// **`==` and `===` are different operators, not one operator with a flag.**
/// `===` compiles to the shared strict-equality opcode; `==` compiles to a
/// call to a frontend builtin that implements JavaScript's coercion rules.
/// Anything less loses real behaviour.
///
/// **An object literal is a map.** `{a: 1}` builds the same `MapValue` a
/// Python dict does, and the JavaScript dialect turns on
/// `propertyAccessReadsMapKeys` so that `o.a` and `o["a"]` are the same
/// lookup. That keeps one canonical shape for grading across all three
/// languages.
///
/// **`x++` is only cheap where its value is thrown away.** In a for-loop
/// increment or a statement of its own it compiles to `x = x + 1`. Used as a
/// value, where postfix genuinely has to yield the *old* number, it compiles
/// to a small immediately-called function that saves the old value first —
/// correct rather than convenient.
library;

import '../../errors/failure.dart';
import '../../ir/ir.dart';
import 'javascript_builtins.dart';
import 'javascript_lexer.dart';

class JavascriptParser {
  List<JsToken> _tokens = const <JsToken>[];
  int _pos = 0;
  int _tempCounter = 0;

  /// Parameter names per function, so a keyword-free call can still be
  /// checked. JavaScript has no keyword arguments, so this is only used to
  /// recognise `super(...)` arity problems early — kept minimal on purpose.
  final Set<String> _classNames = <String>{};

  List<IrStmt> parseProgram(String source) {
    _tokens = JavascriptLexer().tokenize(source);
    _pos = 0;
    _tempCounter = 0;
    _classNames.clear();

    _rejectUnsupportedOperators();
    final statements = <IrStmt>[];
    while (!_isAtEnd) {
      statements.add(_statement());
    }
    return statements;
  }

  /// Operators that are real JavaScript but outside the supported subset.
  /// Rejected up front, by name, because catching them wherever they happen
  /// to appear in the grammar would report them as a plain syntax error — and
  /// "you typed it wrong" is the wrong thing to tell someone whose code is
  /// perfectly valid (FR-002d, SC-009).
  static const Map<String, String> _unsupportedOperators = <String, String>{
    '&': 'bitwiseOperator',
    '|': 'bitwiseOperator',
    '^': 'bitwiseOperator',
    '~': 'bitwiseOperator',
    '<<': 'bitwiseOperator',
    '>>': 'bitwiseOperator',
    '>>>': 'bitwiseOperator',
    '&=': 'bitwiseOperator',
    '|=': 'bitwiseOperator',
    '^=': 'bitwiseOperator',
    '<<=': 'bitwiseOperator',
    '>>=': 'bitwiseOperator',
    '>>>=': 'bitwiseOperator',
    '??=': 'logicalAssignment',
    '&&=': 'logicalAssignment',
    '||=': 'logicalAssignment',
  };

  void _rejectUnsupportedOperators() {
    for (final token in _tokens) {
      if (token.type != JsTokenType.op) continue;
      final construct = _unsupportedOperators[token.lexeme];
      if (construct == null) continue;
      throw FrontendFailure(
          kind: FailureKind.unsupported,
          code: 'unsupportedConstruct',
          data: <String, Object?>{'construct': construct},
          line: token.line);
    }
  }

  // -------------------------------------------------------------------
  // Token helpers
  // -------------------------------------------------------------------

  bool get _isAtEnd => _peek.type == JsTokenType.eof;
  JsToken get _peek => _tokens[_pos];
  JsToken _peekAhead(int n) => _tokens[(_pos + n).clamp(0, _tokens.length - 1)];
  JsToken get _previous => _tokens[_pos - 1];

  JsToken _advance() {
    if (!_isAtEnd) _pos++;
    return _previous;
  }

  bool _check(JsTokenType type) => _peek.type == type;
  bool _checkOp(String op) => _peek.type == JsTokenType.op && _peek.lexeme == op;
  bool _checkKeyword(String kw) => _peek.type == JsTokenType.keyword && _peek.lexeme == kw;

  bool _matchOp(String op) {
    if (!_checkOp(op)) return false;
    _advance();
    return true;
  }

  bool _matchKeyword(String kw) {
    if (!_checkKeyword(kw)) return false;
    _advance();
    return true;
  }

  void _expectOp(String op) {
    if (!_matchOp(op)) throw _syntax('expected', <String, Object?>{'token': op});
  }

  String _expectName() {
    // A contextual keyword like `of` or `get` is a perfectly good property or
    // variable name.
    if (_check(JsTokenType.name) || _check(JsTokenType.keyword)) return _advance().lexeme;
    throw _syntax('expectedIdentifier');
  }

  String _expectVariableName() {
    if (!_check(JsTokenType.name)) throw _syntax('expectedIdentifier');
    return _advance().lexeme;
  }

  /// Automatic semicolon insertion: an explicit `;`, a line break before the
  /// next token, a closing brace, or end of input all end a statement.
  void _consumeSemicolon() {
    if (_matchOp(';')) return;
    if (_isAtEnd || _checkOp('}') || _peek.newlineBefore) return;
    throw _syntax('expectedSemicolon');
  }

  FrontendFailure _syntax(String code, [Map<String, Object?> data = const <String, Object?>{}]) =>
      FrontendFailure(kind: FailureKind.syntax, code: code, data: data, line: _peek.line);

  FrontendFailure _unsupported(String construct, [int? line]) => FrontendFailure(
      kind: FailureKind.unsupported,
      code: 'unsupportedConstruct',
      data: <String, Object?>{'construct': construct},
      line: line ?? _peek.line);

  String _nextTemp() => '#js${_tempCounter++}';

  // -------------------------------------------------------------------
  // Statements
  // -------------------------------------------------------------------

  IrStmt _statement() {
    final t = _peek;

    if (t.type == JsTokenType.keyword) {
      switch (t.lexeme) {
        case 'let':
        case 'const':
        case 'var':
          return _variableDeclaration();
        case 'function':
          return _functionDeclaration();
        case 'class':
          return _classDeclaration();
        case 'if':
          return _ifStatement();
        case 'while':
          return _whileStatement();
        case 'do':
          return _doWhileStatement();
        case 'for':
          return _forStatement();
        case 'return':
          return _returnStatement();
        case 'break':
          _advance();
          _consumeSemicolon();
          return IrBreak(line: t.line);
        case 'continue':
          _advance();
          _consumeSemicolon();
          return IrContinue(line: t.line);
        case 'throw':
          return _throwStatement();
        case 'try':
          return _tryStatement();
        case 'switch':
          throw _unsupported('switch');
        case 'async':
          throw _unsupported('asyncFunction');
        case 'await':
          throw _unsupported('await');
        case 'yield':
          throw _unsupported('yield');
        case 'import':
        case 'export':
          throw _unsupported('module');
        case 'with':
          throw _unsupported('with');
        case 'debugger':
          throw _unsupported('debugger');
        case 'delete':
          throw _unsupported('delete');
      }
    }

    if (_checkOp('{')) return _block();
    if (_matchOp(';')) return IrBlock(line: t.line, statements: const <IrStmt>[]);
    return _expressionStatement();
  }

  IrStmt _block() {
    final line = _peek.line;
    _expectOp('{');
    final statements = <IrStmt>[];
    while (!_checkOp('}') && !_isAtEnd) {
      statements.add(_statement());
    }
    _expectOp('}');
    return IrBlock(line: line, statements: statements);
  }

  IrStmt _variableDeclaration() {
    final line = _advance().line; // let / const / var
    final declarations = <IrStmt>[];
    do {
      if (_checkOp('[') || _checkOp('{')) {
        declarations.add(_destructuringDeclaration(line));
      } else {
        final name = _expectVariableName();
        IrExpr? initializer;
        if (_matchOp('=')) initializer = _assignment();
        declarations.add(IrVarDecl(line: line, name: name, initializer: initializer));
      }
    } while (_matchOp(','));
    _consumeSemicolon();
    return declarations.length == 1
        ? declarations.single
        : IrStmtGroup(line: line, statements: declarations);
  }

  /// `const [a, b] = xs` and `const {x, y} = o`.
  IrStmt _destructuringDeclaration(int line) {
    final byProperty = _checkOp('{');
    final closer = byProperty ? '}' : ']';
    _advance();
    final names = <String>[];
    while (!_checkOp(closer)) {
      if (_checkOp('...')) throw _unsupported('restInDestructuring', line);
      names.add(_expectVariableName());
      if (_checkOp('=') || _checkOp(':')) throw _unsupported('destructuringDefaultOrRename', line);
      if (!_matchOp(',')) break;
    }
    _expectOp(closer);
    _expectOp('=');
    return IrDestructure(line: line, names: names, value: _assignment(), byProperty: byProperty);
  }

  IrStmt _functionDeclaration() {
    final line = _advance().line; // function
    if (_checkOp('*')) throw _unsupported('generatorFunction', line);
    final name = _expectVariableName();
    final params = _parameterList();
    final body = _functionBody();
    return IrFunctionDecl(line: line, name: name, params: params, body: body);
  }

  List<IrParam> _parameterList() {
    _expectOp('(');
    final params = <IrParam>[];
    while (!_checkOp(')')) {
      if (_checkOp('...')) throw _unsupported('restParameter');
      if (_checkOp('[') || _checkOp('{')) throw _unsupported('destructuredParameter');
      final name = _expectVariableName();
      IrExpr? defaultValue;
      if (_matchOp('=')) defaultValue = _assignment();
      params.add(IrParam(name, defaultValue: defaultValue));
      if (!_matchOp(',')) break;
    }
    _expectOp(')');
    return params;
  }

  List<IrStmt> _functionBody() {
    _expectOp('{');
    final statements = <IrStmt>[];
    while (!_checkOp('}') && !_isAtEnd) {
      statements.add(_statement());
    }
    _expectOp('}');
    return statements;
  }

  IrStmt _classDeclaration() {
    final line = _advance().line; // class
    final name = _expectVariableName();
    _classNames.add(name);

    String? superclass;
    if (_matchKeyword('extends')) superclass = _expectVariableName();

    _expectOp('{');
    final methods = <IrFunctionDecl>[];
    while (!_checkOp('}') && !_isAtEnd) {
      if (_matchOp(';')) continue;
      if (_checkKeyword('static')) throw _unsupported('staticMember');
      if (_checkKeyword('get') || _checkKeyword('set')) {
        if (_peekAhead(1).type == JsTokenType.name) throw _unsupported('accessor');
      }
      if (_checkKeyword('async')) throw _unsupported('asyncMethod');
      if (_checkOp('*')) throw _unsupported('generatorMethod');

      final methodLine = _peek.line;
      final methodName = _expectName();
      if (!_checkOp('(')) throw _unsupported('classField', methodLine);
      final params = _parameterList();
      final body = _functionBody();
      methods.add(IrFunctionDecl(
          line: methodLine,
          name: methodName == 'constructor' ? '<init>' : methodName,
          params: params,
          body: body));
    }
    _expectOp('}');
    return IrClassDecl(line: line, name: name, superclass: superclass, methods: methods);
  }

  IrStmt _ifStatement() {
    final line = _advance().line;
    _expectOp('(');
    final condition = _expression();
    _expectOp(')');
    final thenBranch = _statement();
    IrStmt? elseBranch;
    if (_matchKeyword('else')) elseBranch = _statement();
    return IrIf(line: line, condition: condition, thenBranch: thenBranch, elseBranch: elseBranch);
  }

  IrStmt _whileStatement() {
    final line = _advance().line;
    _expectOp('(');
    final condition = _expression();
    _expectOp(')');
    return IrWhile(line: line, condition: condition, body: _statement());
  }

  /// `do { ... } while (c)` runs its body once before testing, which the IR
  /// has no node for — so the body is emitted once, then again inside a
  /// `while`.
  IrStmt _doWhileStatement() {
    final line = _advance().line; // do
    final body = _statement();
    if (!_matchKeyword('while')) throw _syntax('expectedWhile');
    _expectOp('(');
    final condition = _expression();
    _expectOp(')');
    _consumeSemicolon();
    return IrBlock(line: line, statements: <IrStmt>[
      body,
      IrWhile(line: line, condition: condition, body: body),
    ]);
  }

  IrStmt _forStatement() {
    final line = _advance().line; // for
    _expectOp('(');

    // Distinguish `for (init; cond; step)` from `for (x of xs)` and
    // `for (x in o)` by scanning ahead for the keyword before the first `;`.
    final iteration = _lookAheadForIterationKeyword();
    if (iteration != null) return _forInOf(line, iteration);

    IrStmt? init;
    if (_matchOp(';')) {
      init = null;
    } else if (_checkKeyword('let') || _checkKeyword('const') || _checkKeyword('var')) {
      init = _variableDeclaration();
    } else {
      init = _expressionStatement();
    }

    IrExpr? condition;
    if (!_checkOp(';')) condition = _expression();
    _expectOp(';');

    IrExpr? increment;
    if (!_checkOp(')')) increment = _discardedExpression();
    _expectOp(')');

    return IrFor(line: line, init: init, condition: condition, increment: increment, body: _statement());
  }

  /// `of`, `in`, or null for a classic three-part `for`.
  String? _lookAheadForIterationKeyword() {
    var depth = 0;
    for (var i = _pos; i < _tokens.length; i++) {
      final t = _tokens[i];
      if (t.lexeme == '(' || t.lexeme == '[' || t.lexeme == '{') depth++;
      if (t.lexeme == ')' || t.lexeme == ']' || t.lexeme == '}') {
        if (depth == 0) return null;
        depth--;
      }
      if (depth == 0 && t.lexeme == ';') return null;
      if (depth == 0 && t.type == JsTokenType.keyword && (t.lexeme == 'of' || t.lexeme == 'in')) {
        return t.lexeme;
      }
    }
    return null;
  }

  IrStmt _forInOf(int line, String keyword) {
    if (_checkKeyword('let') || _checkKeyword('const') || _checkKeyword('var')) _advance();

    final names = <String>[];
    var destructured = false;
    if (_checkOp('[') || _checkOp('{')) {
      destructured = _checkOp('{');
      _advance();
      final closer = destructured ? '}' : ']';
      while (!_checkOp(closer)) {
        names.add(_expectVariableName());
        if (!_matchOp(',')) break;
      }
      _expectOp(closer);
    } else {
      names.add(_expectVariableName());
    }

    if (!_matchKeyword(keyword)) throw _syntax('expectedIn');
    var iterable = _expression();
    _expectOp(')');

    // `for (const k in o)` walks an object's *keys*, which for a map is what
    // iterating it already does — but for an array it means the indices, not
    // the elements, so it is spelled out rather than left to chance.
    if (keyword == 'in') {
      iterable = IrCall(
        line: line,
        synthetic: true,
        callee: IrPropertyGet(
            line: line,
            synthetic: true,
            receiver: IrIdentifier(line: line, synthetic: true, name: 'Object'),
            name: 'keys'),
        args: <IrExpr>[iterable],
      );
    }

    final body = _statement();
    if (names.length == 1 && !destructured) {
      return IrForIn(line: line, varName: names.single, iterable: iterable, body: body);
    }

    final holder = _nextTemp();
    return IrForIn(
      line: line,
      varName: holder,
      iterable: iterable,
      body: IrBlock(line: line, statements: <IrStmt>[
        IrDestructure(
            line: line,
            synthetic: true,
            names: names,
            byProperty: destructured,
            value: IrIdentifier(line: line, synthetic: true, name: holder)),
        body,
      ]),
    );
  }

  IrStmt _returnStatement() {
    final line = _advance().line;
    IrExpr? value;
    // `return` followed by a line break returns nothing, however inviting the
    // next line looks — one of the few places ASI silently changes meaning.
    if (!_checkOp(';') && !_checkOp('}') && !_isAtEnd && !_peek.newlineBefore) {
      value = _expression();
    }
    _consumeSemicolon();
    return IrReturn(line: line, value: value);
  }

  IrStmt _throwStatement() {
    final line = _advance().line;
    final value = _expression();
    _consumeSemicolon();
    return IrThrow(line: line, value: value);
  }

  IrStmt _tryStatement() {
    final line = _advance().line;
    final body = _block();

    String? catchVar;
    IrStmt? catchBody;
    if (_matchKeyword('catch')) {
      if (_matchOp('(')) {
        catchVar = _expectVariableName();
        _expectOp(')');
      }
      catchBody = _block();
    }

    IrStmt? finallyBody;
    if (_matchKeyword('finally')) finallyBody = _block();

    if (catchBody == null && finallyBody == null) throw _syntax('expectedCatchOrFinally');
    return IrTry(
        line: line, body: body, catchVar: catchVar, catchBody: catchBody, finallyBody: finallyBody);
  }

  IrStmt _expressionStatement() {
    final line = _peek.line;
    if (_isConsoleLog()) return _printStatement();
    final expr = _discardedExpression();
    _consumeSemicolon();
    return IrExprStmt(line: line, expr: expr);
  }

  bool _isConsoleLog() =>
      _peek.type == JsTokenType.name &&
      _peek.lexeme == 'console' &&
      _peekAhead(1).lexeme == '.' &&
      _peekAhead(2).lexeme == 'log' &&
      _peekAhead(3).lexeme == '(';

  /// The global objects whose members must never be mistaken for instance
  /// methods: `Object.keys` is not the same function as `someMap.keys`.
  static const Set<String> _globalNamespaces = <String>{
    'Object', 'Math', 'Array', 'Number', 'String', 'JSON', 'console',
  };

  IrStmt _printStatement() {
    final line = _peek.line;
    _advance(); // console
    _advance(); // .
    _advance(); // log
    final args = _arguments();
    _consumeSemicolon();
    return _printOf(line, args);
  }

  /// Several arguments print separated by a single space, as `console.log`
  /// does.
  IrStmt _printOf(int line, List<IrExpr> args) {
    if (args.isEmpty) {
      return IrPrint(line: line, value: IrLiteral(line: line, kind: IrLiteralKind.strLit, value: ''));
    }
    if (args.length == 1) return IrPrint(line: line, value: args.single);
    final parts = <Object>[];
    for (var i = 0; i < args.length; i++) {
      if (i > 0) parts.add(' ');
      parts.add(args[i]);
    }
    return IrPrint(line: line, value: IrTemplateString(line: line, parts: parts));
  }

  /// An expression in a position where its value is discarded, so `i++` can
  /// compile to a plain `i = i + 1` rather than to a function call that saves
  /// the old value nobody is going to read.
  IrExpr _discardedExpression() {
    final line = _peek.line;
    final start = _pos;
    final expr = _expression();
    if (_checkOp('++') || _checkOp('--')) {
      final op = _advance().lexeme;
      if (!_isAssignable(expr)) {
        _pos = start;
        throw _syntax('invalidAssignmentTarget');
      }
      return _assignBack(line, expr, _stepped(line, expr, op));
    }
    return expr;
  }

  // -------------------------------------------------------------------
  // Expressions, lowest precedence first
  // -------------------------------------------------------------------

  IrExpr _expression() => _assignment();

  IrExpr _assignment() {
    if (_looksLikeArrowFunction()) return _arrowFunction();

    final line = _peek.line;
    final target = _conditional();

    for (final op in const <String>['=', '+=', '-=', '*=', '/=', '%=', '**=']) {
      if (!_checkOp(op)) continue;
      _advance();
      final value = _assignment();
      if (!_isAssignable(target)) throw _syntax('invalidAssignmentTarget');
      if (op == '=') return _assignBack(line, target, value);
      final binaryOp = switch (op) {
        '+=' => IrBinaryOp.add,
        '-=' => IrBinaryOp.sub,
        '*=' => IrBinaryOp.mul,
        '/=' => IrBinaryOp.div,
        '%=' => IrBinaryOp.mod,
        _ => IrBinaryOp.pow,
      };
      return _assignBack(line, target, IrBinary(line: line, op: binaryOp, left: target, right: value));
    }
    if (_checkOp('??=') || _checkOp('&&=') || _checkOp('||=')) {
      throw _unsupported('logicalAssignment');
    }
    return target;
  }

  bool _isAssignable(IrExpr expr) =>
      expr is IrIdentifier || expr is IrIndexGet || expr is IrPropertyGet;

  IrExpr _assignBack(int line, IrExpr target, IrExpr value) => switch (target) {
        IrIdentifier(:final name) => IrAssign(line: line, name: name, value: value),
        IrIndexGet(:final receiver, :final index) =>
          IrIndexSet(line: line, receiver: receiver, index: index, value: value),
        IrPropertyGet(:final receiver, :final name) =>
          IrPropertySet(line: line, receiver: receiver, name: name, value: value),
        _ => throw _syntax('invalidAssignmentTarget'),
      };

  IrExpr _stepped(int line, IrExpr target, String op) => IrBinary(
        line: line,
        op: op == '++' ? IrBinaryOp.add : IrBinaryOp.sub,
        left: target,
        right: IrLiteral(line: line, synthetic: true, kind: IrLiteralKind.intLit, value: 1),
      );

  IrExpr _conditional() {
    final condition = _nullish();
    if (!_checkOp('?')) return condition;
    final line = _advance().line;
    final thenExpr = _assignment();
    _expectOp(':');
    final elseExpr = _assignment();
    return IrConditional(line: line, condition: condition, thenExpr: thenExpr, elseExpr: elseExpr);
  }

  IrExpr _nullish() {
    var left = _logicalOr();
    while (_checkOp('??')) {
      final line = _advance().line;
      left = IrBinary(line: line, op: IrBinaryOp.ifNull, left: left, right: _logicalOr());
    }
    return left;
  }

  IrExpr _logicalOr() {
    var left = _logicalAnd();
    while (_checkOp('||')) {
      final line = _advance().line;
      left = IrBinary(line: line, op: IrBinaryOp.or, left: left, right: _logicalAnd());
    }
    return left;
  }

  IrExpr _logicalAnd() {
    var left = _equality();
    while (_checkOp('&&')) {
      final line = _advance().line;
      left = IrBinary(line: line, op: IrBinaryOp.and, left: left, right: _equality());
    }
    return left;
  }

  IrExpr _equality() {
    var left = _relational();
    while (_checkOp('===') || _checkOp('!==') || _checkOp('==') || _checkOp('!=')) {
      final op = _advance();
      final right = _relational();
      final line = op.line;
      left = switch (op.lexeme) {
        // Strict equality is the shared opcode, because the JavaScript
        // dialect declares `equalityCoerces: false`.
        '===' => IrBinary(line: line, op: IrBinaryOp.eq, left: left, right: right),
        '!==' => IrBinary(line: line, op: IrBinaryOp.notEq, left: left, right: right),
        // Loose equality is a genuinely different operation, so it goes to a
        // builtin that implements the coercion rules rather than approximating
        // them with a flag.
        '==' => _looseEqCall(line, left, right),
        _ => IrUnary(line: line, op: IrUnaryOp.not, operand: _looseEqCall(line, left, right)),
      };
    }
    return left;
  }

  IrExpr _looseEqCall(int line, IrExpr left, IrExpr right) => IrCall(
        line: line,
        callee: IrIdentifier(line: line, synthetic: true, name: '__looseEq'),
        args: <IrExpr>[left, right],
      );

  IrExpr _relational() {
    var left = _additive();
    while (true) {
      if (_checkKeyword('instanceof')) throw _unsupported('instanceof');
      if (_checkKeyword('in')) {
        final line = _advance().line;
        left = IrCall(
          line: line,
          callee: IrIdentifier(line: line, synthetic: true, name: '__has'),
          args: <IrExpr>[_additive(), left],
        );
        continue;
      }
      final op = switch (_peek.lexeme) {
        '<' => IrBinaryOp.lt,
        '<=' => IrBinaryOp.lte,
        '>' => IrBinaryOp.gt,
        '>=' => IrBinaryOp.gte,
        _ => null,
      };
      if (op == null || !_check(JsTokenType.op)) return left;
      final line = _advance().line;
      left = IrBinary(line: line, op: op, left: left, right: _additive());
    }
  }

  IrExpr _additive() {
    var left = _multiplicative();
    while (_checkOp('+') || _checkOp('-')) {
      final op = _advance();
      left = IrBinary(
          line: op.line,
          op: op.lexeme == '+' ? IrBinaryOp.add : IrBinaryOp.sub,
          left: left,
          right: _multiplicative());
    }
    return left;
  }

  IrExpr _multiplicative() {
    var left = _unary();
    while (_checkOp('*') || _checkOp('/') || _checkOp('%')) {
      final op = _advance();
      final irOp = switch (op.lexeme) {
        '*' => IrBinaryOp.mul,
        '/' => IrBinaryOp.div,
        _ => IrBinaryOp.mod,
      };
      left = IrBinary(line: op.line, op: irOp, left: left, right: _unary());
    }
    return left;
  }

  IrExpr _unary() {
    final line = _peek.line;
    if (_matchOp('!')) return IrUnary(line: line, op: IrUnaryOp.not, operand: _unary());
    if (_matchOp('-')) return IrUnary(line: line, op: IrUnaryOp.negate, operand: _unary());
    if (_matchOp('+')) return _unary();
    if (_matchOp('~')) throw _unsupported('bitwiseOperator', line);
    if (_checkOp('&') || _checkOp('|') || _checkOp('^') || _checkOp('<<') || _checkOp('>>')) {
      throw _unsupported('bitwiseOperator', line);
    }
    if (_matchKeyword('typeof')) {
      return IrCall(
        line: line,
        callee: IrIdentifier(line: line, synthetic: true, name: '__typeof'),
        args: <IrExpr>[_unary()],
      );
    }
    if (_matchKeyword('void')) throw _unsupported('void', line);
    if (_checkKeyword('await')) throw _unsupported('await', line);
    if (_checkOp('++') || _checkOp('--')) {
      // Prefix yields the new value, so a plain assignment is exactly right
      // wherever it appears.
      final op = _advance().lexeme;
      final operand = _unary();
      if (!_isAssignable(operand)) throw _syntax('invalidAssignmentTarget');
      return _assignBack(line, operand, _stepped(line, operand, op));
    }
    return _exponent();
  }

  IrExpr _exponent() {
    final base = _postfix();
    if (!_checkOp('**')) return base;
    final line = _advance().line;
    return IrBinary(line: line, op: IrBinaryOp.pow, left: base, right: _unary());
  }

  IrExpr _postfix() {
    var expr = _primary();
    while (true) {
      final line = _peek.line;
      if (_checkOp('(')) {
        expr = IrCall(line: line, callee: expr, args: _arguments());
      } else if (_matchOp('[')) {
        final index = _expression();
        _expectOp(']');
        expr = IrIndexGet(line: line, receiver: expr, index: index);
      } else if (_matchOp('.')) {
        expr = _member(line, expr, _expectName(), optional: false);
      } else if (_matchOp('?.')) {
        if (_checkOp('(') || _checkOp('[')) throw _unsupported('optionalCallOrIndex', line);
        expr = _member(line, expr, _expectName(), optional: true);
      } else if (_checkOp('++') || _checkOp('--')) {
        expr = _postfixStep(line, expr);
      } else {
        return expr;
      }
    }
  }

  /// `x++` where the value is used. Postfix has to yield the number as it was
  /// *before* the step, which needs somewhere to keep it — so this compiles
  /// to a small function that saves the old value, steps, and returns the
  /// saved one. The cheap form is in [_discardedExpression], which covers the
  /// loop increments and standalone statements where almost all `++` lives.
  IrExpr _postfixStep(int line, IrExpr target) {
    final op = _advance().lexeme;
    if (!_isAssignable(target)) throw _syntax('invalidAssignmentTarget');
    final saved = _nextTemp();
    return IrCall(
      line: line,
      synthetic: true,
      callee: IrLambda(
        line: line,
        synthetic: true,
        params: const <IrParam>[],
        body: <IrStmt>[
          IrVarDecl(line: line, synthetic: true, name: saved, initializer: target),
          IrExprStmt(line: line, synthetic: true, expr: _assignBack(line, target, _stepped(line, target, op))),
          IrReturn(line: line, synthetic: true, value: IrIdentifier(line: line, synthetic: true, name: saved)),
        ],
      ),
      args: const <IrExpr>[],
    );
  }

  /// Property access, translating the JavaScript method and property names
  /// that the shared runtime spells differently or not at all.
  IrExpr _member(int line, IrExpr receiver, String name, {required bool optional}) {
    if (receiver is IrIdentifier && receiver.name == 'super') {
      if (!_checkOp('(')) throw _syntax('expectedCallAfterSuper');
      return IrSuperCall(line: line, name: name, args: _arguments());
    }

    // `console.log(...)` in a value position — inside `xs.forEach(x =>
    // console.log(x))`, say. Printing is a statement in the IR, so it is
    // wrapped in a function call to give it a value position to live in.
    if (receiver is IrIdentifier && receiver.name == 'console' && name == 'log' && _checkOp('(')) {
      final args = _arguments();
      return IrCall(
        line: line,
        synthetic: true,
        callee: IrLambda(
          line: line,
          synthetic: true,
          params: const <IrParam>[],
          body: <IrStmt>[_printOf(line, args)],
        ),
        args: const <IrExpr>[],
      );
    }

    // A static member of a global namespace — `Object.keys`, `Math.max`. The
    // method-name translation below must not touch these: `keys` on an
    // object is a builtin, but `Object.keys` is a different function that
    // happens to share the name.
    if (receiver is IrIdentifier && _globalNamespaces.contains(receiver.name)) {
      final member = IrPropertyGet(line: line, receiver: receiver, name: name);
      if (!_checkOp('(')) return member;
      return IrCall(line: line, callee: member, args: _arguments());
    }

    if (!_checkOp('(')) {
      final propertyHelper = jsPropertyHelpers[name];
      final read = propertyHelper != null
          ? IrCall(
              line: line,
              callee: IrIdentifier(line: line, synthetic: true, name: propertyHelper),
              args: <IrExpr>[receiver])
          : IrPropertyGet(line: line, receiver: receiver, name: name);
      return optional ? _guardOptional(line, receiver, read) : read;
    }

    final args = _arguments();
    final methodHelper = jsMethodHelpers[name];
    final call = methodHelper != null
        ? IrCall(
            line: line,
            callee: IrIdentifier(line: line, synthetic: true, name: methodHelper),
            args: <IrExpr>[receiver, ...args])
        : IrCall(
            line: line, callee: IrPropertyGet(line: line, receiver: receiver, name: name), args: args);
    return optional ? _guardOptional(line, receiver, call) : call;
  }

  /// `a?.b` — null when the receiver is null, otherwise the access. The
  /// receiver is evaluated twice, which is safe for the identifiers and
  /// property chains optional access is written on and cheap enough not to
  /// need a temporary.
  IrExpr _guardOptional(int line, IrExpr receiver, IrExpr access) => IrConditional(
        line: line,
        synthetic: true,
        condition: IrBinary(
          line: line,
          synthetic: true,
          op: IrBinaryOp.eq,
          left: receiver,
          right: IrLiteral(line: line, synthetic: true, kind: IrLiteralKind.nullLit, value: null),
        ),
        thenExpr: IrLiteral(line: line, synthetic: true, kind: IrLiteralKind.nullLit, value: null),
        elseExpr: access,
      );

  List<IrExpr> _arguments() {
    _expectOp('(');
    final args = <IrExpr>[];
    while (!_checkOp(')')) {
      if (_matchOp('...')) {
        args.add(IrSpread(line: _peek.line, value: _assignment()));
      } else {
        args.add(_assignment());
      }
      if (!_matchOp(',')) break;
    }
    _expectOp(')');
    return args;
  }

  // -------------------------------------------------------------------
  // Arrow functions
  // -------------------------------------------------------------------

  /// `x => ...` and `(a, b) => ...` both start where a parenthesised
  /// expression could, so the only reliable test is to find the matching
  /// `)` and look at what follows.
  bool _looksLikeArrowFunction() {
    if (_check(JsTokenType.name) && _peekAhead(1).lexeme == '=>') return true;
    if (!_checkOp('(')) return false;
    var depth = 0;
    for (var i = _pos; i < _tokens.length; i++) {
      final lexeme = _tokens[i].lexeme;
      if (lexeme == '(') depth++;
      if (lexeme == ')') {
        depth--;
        if (depth == 0) return _tokens[i + 1].lexeme == '=>';
      }
    }
    return false;
  }

  IrExpr _arrowFunction() {
    final line = _peek.line;
    final params = <IrParam>[];
    if (_check(JsTokenType.name)) {
      params.add(IrParam(_expectVariableName()));
    } else {
      params.addAll(_parameterList());
    }
    _expectOp('=>');

    if (_checkOp('{')) {
      return IrLambda(line: line, params: params, body: _functionBody());
    }
    // A concise body returns its expression. An object literal has to be
    // parenthesised in JavaScript for exactly this reason, so a `{` here is
    // already a block, handled above.
    final body = _assignment();
    return IrLambda(
      line: line,
      params: params,
      isExpressionBody: true,
      body: <IrStmt>[IrReturn(line: line, value: body)],
    );
  }

  // -------------------------------------------------------------------
  // Primary expressions
  // -------------------------------------------------------------------

  IrExpr _primary() {
    final t = _peek;
    final line = t.line;

    switch (t.type) {
      case JsTokenType.numberLiteral:
        _advance();
        return IrLiteral(
            line: line,
            kind: t.literal is int ? IrLiteralKind.intLit : IrLiteralKind.numLit,
            value: t.literal);
      case JsTokenType.stringLiteral:
        _advance();
        return IrLiteral(line: line, kind: IrLiteralKind.strLit, value: t.literal);
      case JsTokenType.templateLiteral:
        _advance();
        return _templateLiteral(t);
      case JsTokenType.name:
        _advance();
        return IrIdentifier(line: line, name: t.lexeme);
      case JsTokenType.keyword:
        switch (t.lexeme) {
          case 'true':
            _advance();
            return IrLiteral(line: line, kind: IrLiteralKind.boolLit, value: true);
          case 'false':
            _advance();
            return IrLiteral(line: line, kind: IrLiteralKind.boolLit, value: false);
          case 'null':
            _advance();
            return IrLiteral(line: line, kind: IrLiteralKind.nullLit, value: null);
          case 'undefined':
            _advance();
            return IrIdentifier(line: line, name: 'undefined');
          case 'this':
            _advance();
            return IrIdentifier(line: line, name: 'this');
          case 'super':
            _advance();
            if (_checkOp('(')) return IrSuperCall(line: line, name: '<init>', args: _arguments());
            return IrIdentifier(line: line, name: 'super');
          case 'new':
            _advance();
            return _newExpression(line);
          case 'function':
            _advance();
            if (_checkOp('*')) throw _unsupported('generatorFunction', line);
            if (_check(JsTokenType.name)) _advance();
            return IrLambda(line: line, params: _parameterList(), body: _functionBody());
          case 'class':
            throw _unsupported('classExpression', line);
        }
        break;
      default:
        break;
    }

    if (_matchOp('(')) {
      final expr = _expression();
      _expectOp(')');
      return expr;
    }
    if (_matchOp('[')) return _arrayLiteral(line);
    if (_matchOp('{')) return _objectLiteral(line);

    throw _syntax('expectedExpression');
  }

  /// `new Map()`, `new Set()` and `new Array()` are builtins rather than
  /// classes the learner declared, so they are routed to their constructors.
  /// Anything else is an ordinary class instantiation, which the VM already
  /// performs by calling the class value.
  IrExpr _newExpression(int line) {
    final name = _expectVariableName();
    final args = _checkOp('(') ? _arguments() : const <IrExpr>[];
    const builtinConstructors = <String, String>{
      'Map': '__newMap',
      'Set': '__newSet',
      'Array': '__newArray',
    };
    final builtin = builtinConstructors[name];
    if (builtin != null && !_classNames.contains(name)) {
      return IrCall(
          line: line, callee: IrIdentifier(line: line, synthetic: true, name: builtin), args: args);
    }
    if (name == 'Error' && !_classNames.contains(name)) {
      // `throw new Error("...")` is the idiom; the message is what matters.
      return args.isEmpty ? IrLiteral(line: line, kind: IrLiteralKind.strLit, value: 'Error') : args.first;
    }
    return IrCall(line: line, callee: IrIdentifier(line: line, name: name), args: args);
  }

  IrExpr _arrayLiteral(int line) {
    final items = <IrExpr>[];
    while (!_checkOp(']')) {
      if (_matchOp('...')) {
        items.add(IrSpread(line: _peek.line, value: _assignment()));
      } else {
        items.add(_assignment());
      }
      if (!_matchOp(',')) break;
    }
    _expectOp(']');
    return IrListLiteral(line: line, items: items);
  }

  /// An object literal builds a map, which is what the JavaScript dialect's
  /// `propertyAccessReadsMapKeys` is there to make readable as `o.a`.
  IrExpr _objectLiteral(int line) {
    final keys = <IrExpr>[];
    final values = <IrExpr>[];
    while (!_checkOp('}')) {
      if (_checkOp('...')) throw _unsupported('objectSpread', line);

      if (_matchOp('[')) {
        keys.add(_assignment());
        _expectOp(']');
        _expectOp(':');
        values.add(_assignment());
      } else {
        final keyToken = _peek;
        final String key;
        if (keyToken.type == JsTokenType.stringLiteral) {
          _advance();
          key = keyToken.literal! as String;
        } else if (keyToken.type == JsTokenType.numberLiteral) {
          _advance();
          key = '${keyToken.literal}';
        } else {
          key = _expectName();
        }
        keys.add(IrLiteral(line: keyToken.line, kind: IrLiteralKind.strLit, value: key));

        if (_checkOp('(')) throw _unsupported('objectMethod', keyToken.line);
        if (_matchOp(':')) {
          values.add(_assignment());
        } else {
          // Shorthand: `{x}` is `{x: x}`.
          values.add(IrIdentifier(line: keyToken.line, name: key));
        }
      }
      if (!_matchOp(',')) break;
    }
    _expectOp('}');
    return IrMapLiteral(line: line, keys: keys, values: values);
  }

  IrExpr _templateLiteral(JsToken token) {
    final parts = token.literal! as List<Object>;
    if (parts.length == 1 && parts.first is String) {
      return IrLiteral(line: token.line, kind: IrLiteralKind.strLit, value: parts.first);
    }
    return IrTemplateString(
      line: token.line,
      parts: <Object>[
        for (final part in parts)
          if (part is JsInterpolation) _parseInterpolation(part) else part,
      ],
    );
  }

  /// Parses one `${...}` hole by re-entering this same parser. The source is
  /// padded with newlines so the sub-lexer's line numbers already match the
  /// learner's file.
  IrExpr _parseInterpolation(JsInterpolation slice) {
    final padded = '\n' * (slice.line - 1) + slice.source;
    final savedTokens = _tokens;
    final savedPos = _pos;
    try {
      _tokens = JavascriptLexer().tokenize(padded);
      _pos = 0;
      final expr = _expression();
      if (!_isAtEnd) throw _syntax('expectedExpression');
      return expr;
    } finally {
      _tokens = savedTokens;
      _pos = savedPos;
    }
  }
}
