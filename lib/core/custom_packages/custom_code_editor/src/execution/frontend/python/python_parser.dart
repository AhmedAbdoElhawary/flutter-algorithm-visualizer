/// A recursive-descent parser for the supported Python subset, producing the
/// shared Core IR.
///
/// Three things here are worth knowing before reading the rest:
///
/// **Scoping is hoisted.** Python scopes names to the whole function, not to
/// the block they appear in, so a name first assigned inside an `if` is still
/// there afterwards. The IR's `IrVarDecl` is block-scoped, so instead of
/// emitting one at each assignment, this parser collects every name a
/// function assigns and declares them all at the top of its body. Every
/// assignment itself then compiles to a plain store.
///
/// **Comprehensions are desugared, not represented.** `[f(x) for x in xs]`
/// becomes an immediately-called zero-argument function that builds a list
/// and returns it. The frontend contract explicitly allows this, and it means
/// the compiler needs no comprehension support at all — and that a
/// comprehension gets its own scope, exactly as Python 3 gives it.
///
/// **Python's stdlib names are translated here.** `xs.append(1)` becomes the
/// shared `add` intrinsic, and where the shapes genuinely differ
/// (`sep.join(xs)` has its arguments the other way round from every other
/// language) the call is rewritten into a helper from
/// `python_builtins.dart`. The shared runtime never learns that Python
/// exists.
library;

import '../../errors/failure.dart';
import '../../ir/ir.dart';
import 'python_builtins.dart';
import 'python_lexer.dart';

/// Names a function assigns, so they can be declared once at its top.
class _FunctionScope {
  _FunctionScope({required this.isModule, this.params = const <String>{}});

  /// Module-level assignments become globals, which the compiler creates on
  /// demand — so only real functions need hoisting.
  final bool isModule;
  final Set<String> params;
  final Set<String> assigned = <String>{};

  List<IrStmt> get hoisted {
    if (isModule) return const <IrStmt>[];
    return <IrStmt>[
      for (final name in assigned)
        if (!params.contains(name)) IrVarDecl(line: 0, synthetic: true, name: name),
    ];
  }
}

class PythonParser {
  List<PythonToken> _tokens = const <PythonToken>[];
  int _pos = 0;

  final List<_FunctionScope> _scopes = <_FunctionScope>[];

  /// Parameter names per function, so `f(b=2, a=1)` can be reordered into a
  /// positional call. Filled by a pre-pass so a function may be called before
  /// it is defined.
  final Map<String, List<String>> _signatures = <String, List<String>>{};

  /// The name the enclosing method gave its receiver — `self` by convention,
  /// but Python does not require that. Rewritten to the IR's `this`.
  String? _selfName;

  /// Counter for the temporaries comprehension desugaring needs. The `#`
  /// prefix is unlexable, so these can never collide with a learner's name.
  int _tempCounter = 0;

  List<IrStmt> parseProgram(String source) {
    _tokens = PythonLexer().tokenize(source);
    _pos = 0;
    _selfName = null;
    _signatures
      ..clear()
      ..addAll(pythonBuiltinParams);
    _rejectUnsupportedOperators();
    _collectSignatures();

    _scopes.add(_FunctionScope(isModule: true));
    final statements = <IrStmt>[];
    while (!_isAtEnd) {
      if (_check(PythonTokenType.newline) || _check(PythonTokenType.dedent)) {
        _advance();
        continue;
      }
      if (_check(PythonTokenType.indent)) {
        throw _syntax('unexpectedIndent');
      }
      statements.add(_statement());
    }
    _scopes.removeLast();
    return statements;
  }

  /// Operators that are real Python but outside the supported subset. They
  /// are rejected up front, by name, because catching them where they happen
  /// to appear in the grammar would report them as a plain syntax error —
  /// and "you typed it wrong" is the wrong thing to tell someone whose code
  /// is perfectly valid (FR-002d, SC-009).
  static const Map<String, String> _unsupportedOperators = <String, String>{
    ':=': 'walrus',
    '&': 'bitwiseOperator',
    '|': 'bitwiseOperator',
    '^': 'bitwiseOperator',
    '~': 'bitwiseOperator',
    '<<': 'bitwiseOperator',
    '>>': 'bitwiseOperator',
    '&=': 'bitwiseOperator',
    '|=': 'bitwiseOperator',
    '^=': 'bitwiseOperator',
    '<<=': 'bitwiseOperator',
    '>>=': 'bitwiseOperator',
    '@': 'decorator',
  };

  void _rejectUnsupportedOperators() {
    for (final token in _tokens) {
      if (token.type != PythonTokenType.op) continue;
      final construct = _unsupportedOperators[token.lexeme];
      if (construct == null) continue;
      throw FrontendFailure(
          kind: FailureKind.unsupported,
          code: 'unsupportedConstruct',
          data: <String, Object?>{'construct': construct},
          line: token.line);
    }
  }

  /// Records every `def name(a, b)` signature up front, so a call written
  /// above the definition can still resolve its keyword arguments.
  void _collectSignatures() {
    for (var i = 0; i < _tokens.length - 2; i++) {
      if (_tokens[i].type != PythonTokenType.keyword || _tokens[i].lexeme != 'def') continue;
      if (_tokens[i + 1].type != PythonTokenType.name) continue;
      if (_tokens[i + 2].lexeme != '(') continue;
      final params = <String>[];
      var j = i + 3;
      var depth = 1;
      var expectingName = true;
      while (j < _tokens.length && depth > 0) {
        final t = _tokens[j];
        if (t.lexeme == '(' || t.lexeme == '[' || t.lexeme == '{') depth++;
        if (t.lexeme == ')' || t.lexeme == ']' || t.lexeme == '}') depth--;
        if (depth == 0) break;
        if (depth == 1 && t.lexeme == ',') {
          expectingName = true;
        } else if (expectingName && t.type == PythonTokenType.name) {
          params.add(t.lexeme);
          expectingName = false;
        } else if (depth == 1 && (t.lexeme == '=' || t.lexeme == ':')) {
          expectingName = false;
        }
        j++;
      }
      _signatures[_tokens[i + 1].lexeme] = params;
    }
  }

  // -------------------------------------------------------------------
  // Token helpers
  // -------------------------------------------------------------------

  bool get _isAtEnd => _peek.type == PythonTokenType.eof;
  PythonToken get _peek => _tokens[_pos];
  PythonToken _peekAhead(int n) => _tokens[(_pos + n).clamp(0, _tokens.length - 1)];
  PythonToken get _previous => _tokens[_pos - 1];

  PythonToken _advance() {
    if (!_isAtEnd) _pos++;
    return _previous;
  }

  bool _check(PythonTokenType type) => _peek.type == type;
  bool _checkOp(String op) => _peek.type == PythonTokenType.op && _peek.lexeme == op;
  bool _checkKeyword(String kw) => _peek.type == PythonTokenType.keyword && _peek.lexeme == kw;

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

  PythonToken _expect(PythonTokenType type, String code) {
    if (!_check(type)) throw _syntax(code);
    return _advance();
  }

  String _expectName() => _expect(PythonTokenType.name, 'expectedIdentifier').lexeme;

  void _expectNewline() {
    if (_isAtEnd || _check(PythonTokenType.dedent)) return;
    if (!_check(PythonTokenType.newline)) throw _syntax('expectedNewline');
    _advance();
  }

  FrontendFailure _syntax(String code, [Map<String, Object?> data = const <String, Object?>{}]) =>
      FrontendFailure(kind: FailureKind.syntax, code: code, data: data, line: _peek.line);

  FrontendFailure _unsupported(String construct, [int? line]) => FrontendFailure(
      kind: FailureKind.unsupported,
      code: 'unsupportedConstruct',
      data: <String, Object?>{'construct': construct},
      line: line ?? _peek.line);

  /// Records that [name] is assigned in the innermost function, so it can be
  /// declared at the top of that function's body.
  void _noteAssignment(String name) => _scopes.last.assigned.add(name);

  String _nextTemp() => '#py${_tempCounter++}';

  // -------------------------------------------------------------------
  // Statements
  // -------------------------------------------------------------------

  IrStmt _statement() {
    final t = _peek;
    if (t.type == PythonTokenType.keyword) {
      switch (t.lexeme) {
        case 'if':
          return _ifStatement();
        case 'while':
          return _whileStatement();
        case 'for':
          return _forStatement();
        case 'def':
          return _functionDef();
        case 'class':
          return _classDef();
        case 'try':
          return _tryStatement();
        case 'return':
          return _returnStatement();
        case 'pass':
          _advance();
          _expectNewline();
          return IrBlock(line: t.line, statements: const <IrStmt>[]);
        case 'break':
          _advance();
          _expectNewline();
          return IrBreak(line: t.line);
        case 'continue':
          _advance();
          _expectNewline();
          return IrContinue(line: t.line);
        case 'raise':
          return _raiseStatement();
        case 'import':
        case 'from':
          return _importStatement();
        case 'with':
          throw _unsupported('with');
        case 'global':
          throw _unsupported('global');
        case 'nonlocal':
          throw _unsupported('nonlocal');
        case 'del':
          throw _unsupported('del');
        case 'assert':
          throw _unsupported('assert');
        case 'yield':
          throw _unsupported('yield');
        case 'async':
          throw _unsupported('asyncDef');
        case 'await':
          throw _unsupported('await');
      }
    }
    if (_checkOp('@')) throw _unsupported('decorator');
    return _simpleStatementLine();
  }

  /// The modules this engine actually ships: `import heapq` and
  /// `from collections import deque` and nothing else.
  ///
  /// Listing them explicitly is the point. A solution that opens with
  /// `import numpy` is far better told so on line 1 than left to fail later on
  /// a name it never bound, and a member that is not here is one that does not
  /// work — see `python_collections.dart` on why `OrderedDict` is missing.
  static const Map<String, Set<String>> _supportedModules = <String, Set<String>>{
    'collections': <String>{'deque', 'Counter', 'defaultdict'},
    'heapq': <String>{
      'heappush',
      'heappop',
      'heapify',
      'heappushpop',
      'heapreplace',
      'nlargest',
      'nsmallest',
    },
  };

  /// `import heapq` / `from collections import deque, Counter`.
  ///
  /// `import x` compiles to nothing: both modules are already bound as
  /// namespace globals, so the statement only has to agree that the name
  /// exists. `from x import a` does need a binding, and lowers to `a = x.a` —
  /// the same desugar-rather-than-represent approach comprehensions get.
  IrStmt _importStatement() {
    final line = _peek.line;

    if (_matchKeyword('from')) {
      final module = _expectModuleName(line);
      if (!_matchKeyword('import')) throw _syntax('expectedImport');
      if (_checkOp('*')) throw _unsupported('importStar', line);

      final bindings = <IrStmt>[];
      do {
        final name = _expectName();
        if (_checkKeyword('as')) throw _unsupported('importAs', line);
        _requireMember(module, name, line);

        bindings.add(IrVarDecl(
          line: line,
          synthetic: true,
          name: name,
          initializer: IrPropertyGet(
            line: line,
            synthetic: true,
            receiver: IrIdentifier(line: line, synthetic: true, name: module),
            name: name,
          ),
        ));
      } while (_matchOp(','));

      _expectNewline();
      return bindings.length == 1 ? bindings.single : IrStmtGroup(line: line, statements: bindings);
    }

    _advance();
    do {
      _expectModuleName(line);
      if (_checkKeyword('as')) throw _unsupported('importAs', line);
    } while (_matchOp(','));

    _expectNewline();
    return IrBlock(line: line, statements: const <IrStmt>[]);
  }

  String _expectModuleName(int line) {
    final name = _expectName();
    if (!_supportedModules.containsKey(name)) {
      throw _unsupported('module:$name', line);
    }
    return name;
  }

  void _requireMember(String module, String member, int line) {
    if (!_supportedModules[module]!.contains(member)) {
      throw _unsupported('$module.$member', line);
    }
  }

  /// One line of simple statements: `a = 1` or `a = 1; b = 2`.
  IrStmt _simpleStatementLine() {
    final line = _peek.line;
    final statements = <IrStmt>[_simpleStatement()];
    while (_matchOp(';')) {
      if (_check(PythonTokenType.newline) || _isAtEnd) break;
      statements.add(_simpleStatement());
    }
    _expectNewline();
    return statements.length == 1 ? statements.single : IrStmtGroup(line: line, statements: statements);
  }

  IrStmt _simpleStatement() {
    final line = _peek.line;

    if (_checkKeyword('return')) return _returnStatement(consumeNewline: false);
    if (_checkKeyword('raise')) return _raiseStatement(consumeNewline: false);
    if (_checkKeyword('pass')) {
      _advance();
      return IrBlock(line: line, statements: const <IrStmt>[]);
    }
    if (_checkKeyword('break')) {
      _advance();
      return IrBreak(line: line);
    }
    if (_checkKeyword('continue')) {
      _advance();
      return IrContinue(line: line);
    }
    if (_isPrintCall()) return _printStatement();

    final target = _targetOrExpression();

    // Annotated declaration: `count: int = 0`. The annotation is skipped —
    // this engine does not type-check (the Dart frontend ignores generics for
    // the same reason).
    if (_checkOp(':') && target is IrIdentifier) {
      _advance();
      _skipTypeAnnotation();
      if (!_matchOp('=')) {
        _noteAssignment(target.name);
        return IrExprStmt(
            line: line,
            expr: IrAssign(
                line: line,
                name: target.name,
                value: IrLiteral(line: line, kind: IrLiteralKind.nullLit, value: null)));
      }
      final value = _expressionList();
      _noteAssignment(target.name);
      return IrExprStmt(line: line, expr: IrAssign(line: line, name: target.name, value: value));
    }

    for (final op in const <String>['+=', '-=', '*=', '/=', '//=', '%=', '**=']) {
      if (_checkOp(op)) {
        _advance();
        final value = _expressionList();
        return _augmentedAssign(line, target, op, value);
      }
    }

    if (_checkOp('=')) {
      final targets = <IrExpr>[target];
      IrExpr value = target;
      while (_matchOp('=')) {
        value = _expressionList();
        if (_checkOp('=')) targets.add(value);
      }
      final assignments = <IrStmt>[for (final t in targets) _assignTo(line, t, value)];
      return assignments.length == 1 ? assignments.single : IrStmtGroup(line: line, statements: assignments);
    }

    if (_checkOp(':=')) throw _unsupported('walrus');

    return IrExprStmt(line: line, expr: target);
  }

  /// The left of an `=`, which may be a tuple of names (`a, b = ...`).
  IrExpr _targetOrExpression() {
    final first = _ternary();
    if (!_checkOp(',')) return first;
    final items = <IrExpr>[first];
    final line = _peek.line;
    while (_matchOp(',')) {
      if (_checkOp('=') || _check(PythonTokenType.newline) || _isAtEnd) break;
      items.add(_ternary());
    }
    return IrTupleLiteral(line: line, items: items);
  }

  IrStmt _assignTo(int line, IrExpr target, IrExpr value) {
    switch (target) {
      case IrIdentifier(:final name):
        _noteAssignment(name);
        return IrExprStmt(line: line, expr: IrAssign(line: line, name: name, value: value));
      case IrIndexGet(:final receiver, :final index):
        return IrExprStmt(
            line: line, expr: IrIndexSet(line: line, receiver: receiver, index: index, value: value));
      case IrPropertyGet(:final receiver, :final name):
        return IrExprStmt(
            line: line, expr: IrPropertySet(line: line, receiver: receiver, name: name, value: value));
      case IrTupleLiteral(:final items):
      case IrListLiteral(:final items):
        return _unpackInto(line, items, value);
      default:
        throw _syntax('invalidAssignmentTarget');
    }
  }

  /// `a, b = ...`. When every target is a plain name this is one
  /// [IrDestructure]. When a target is a subscript or an attribute — which is
  /// the `nums[i], nums[j] = nums[j], nums[i]` swap at the heart of half the
  /// Python solutions people write — the right-hand side is evaluated once
  /// into a temporary and each target assigned from it in order. That is
  /// Python's own rule: the whole right side is built before anything on the
  /// left is touched, which is why the swap works at all.
  IrStmt _unpackInto(int line, List<IrExpr> items, IrExpr value) {
    if (items.every((item) => item is IrIdentifier)) {
      final names = <String>[];
      for (final item in items) {
        final name = (item as IrIdentifier).name;
        names.add(name);
        _noteAssignment(name);
      }
      return IrDestructure(line: line, names: names, value: value);
    }
    final holder = _nextTemp();
    final statements = <IrStmt>[
      IrVarDecl(line: line, synthetic: true, name: holder, initializer: value),
    ];
    for (var i = 0; i < items.length; i++) {
      statements.add(_assignTo(
        line,
        items[i],
        IrIndexGet(
          line: line,
          synthetic: true,
          receiver: IrIdentifier(line: line, synthetic: true, name: holder),
          index: IrLiteral(line: line, synthetic: true, kind: IrLiteralKind.intLit, value: i),
        ),
      ));
    }
    return IrStmtGroup(line: line, synthetic: true, statements: statements);
  }

  IrStmt _augmentedAssign(int line, IrExpr target, String op, IrExpr value) {
    final binaryOp = switch (op) {
      '+=' => IrBinaryOp.add,
      '-=' => IrBinaryOp.sub,
      '*=' => IrBinaryOp.mul,
      '/=' => IrBinaryOp.div,
      '//=' => IrBinaryOp.floorDiv,
      '%=' => IrBinaryOp.mod,
      _ => IrBinaryOp.pow,
    };
    final combined = IrBinary(line: line, op: binaryOp, left: target, right: value);
    return _assignTo(line, target, combined);
  }

  bool _isPrintCall() =>
      _peek.type == PythonTokenType.name && _peek.lexeme == 'print' && _peekAhead(1).lexeme == '(';

  IrStmt _printStatement() {
    final line = _peek.line;
    _advance(); // print
    _expectOp('(');
    final args = <IrExpr>[];
    if (!_checkOp(')')) {
      do {
        if (_checkOp(')')) break;
        if (_peek.type == PythonTokenType.name && _peekAhead(1).lexeme == '=') {
          throw _unsupported('printKeywordArgument');
        }
        args.add(_ternary());
      } while (_matchOp(','));
    }
    _expectOp(')');

    if (args.isEmpty) {
      return IrPrint(line: line, value: IrLiteral(line: line, kind: IrLiteralKind.strLit, value: ''));
    }
    if (args.length == 1) return IrPrint(line: line, value: args.single);
    // Python separates several arguments with a single space.
    final parts = <Object>[];
    for (var i = 0; i < args.length; i++) {
      if (i > 0) parts.add(' ');
      parts.add(args[i]);
    }
    return IrPrint(line: line, value: IrTemplateString(line: line, parts: parts));
  }

  IrStmt _returnStatement({bool consumeNewline = true}) {
    final line = _advance().line;
    IrExpr? value;
    if (!_check(PythonTokenType.newline) && !_isAtEnd && !_checkOp(';')) {
      value = _expressionList();
    }
    if (consumeNewline) _expectNewline();
    return IrReturn(line: line, value: value);
  }

  IrStmt _raiseStatement({bool consumeNewline = true}) {
    final line = _advance().line;
    IrExpr? value;
    if (!_check(PythonTokenType.newline) && !_isAtEnd && !_checkOp(';')) {
      value = _ternary();
      if (_checkKeyword('from')) throw _unsupported('raiseFrom');
    }
    if (consumeNewline) _expectNewline();
    return IrThrow(line: line, value: value);
  }

  IrStmt _ifStatement() {
    final line = _advance().line; // if / elif
    final condition = _ternary();
    final thenBranch = _suite();
    IrStmt? elseBranch;
    if (_checkKeyword('elif')) {
      elseBranch = _ifStatement();
    } else if (_matchKeyword('else')) {
      elseBranch = _suite();
    }
    return IrIf(line: line, condition: condition, thenBranch: thenBranch, elseBranch: elseBranch);
  }

  IrStmt _whileStatement() {
    final line = _advance().line;
    final condition = _ternary();
    final body = _suite();
    if (_checkKeyword('else')) throw _unsupported('loopElse');
    return IrWhile(line: line, condition: condition, body: body);
  }

  IrStmt _forStatement() {
    final line = _advance().line;

    // `for k, v in pairs:` unpacks each element, which the IR expresses as a
    // one-variable loop whose body destructures that variable first.
    final names = <String>[_expectName()];
    while (_matchOp(',')) {
      names.add(_expectName());
    }
    if (!_matchKeyword('in')) throw _syntax('expectedIn');
    final iterable = _expressionList();
    final body = _suite();
    if (_checkKeyword('else')) throw _unsupported('loopElse');

    if (names.length == 1) {
      _noteAssignment(names.single);
      return IrForIn(line: line, varName: names.single, iterable: iterable, body: body);
    }
    final holder = _nextTemp();
    for (final n in names) {
      _noteAssignment(n);
    }
    return IrForIn(
      line: line,
      varName: holder,
      iterable: iterable,
      body: IrBlock(line: line, statements: <IrStmt>[
        IrDestructure(
            line: line,
            synthetic: true,
            names: names,
            value: IrIdentifier(line: line, synthetic: true, name: holder)),
        body,
      ]),
    );
  }

  IrStmt _tryStatement() {
    final line = _advance().line;
    final body = _suite();

    String? catchVar;
    IrStmt? catchBody;
    if (_checkKeyword('except')) {
      _advance();
      if (!_checkOp(':')) {
        // An exception type, which this engine does not match on — every
        // `except` catches everything. Saying so would need a type system.
        _ternary();
        if (_matchKeyword('as')) catchVar = _expectName();
      }
      catchBody = _suite();
      if (_checkKeyword('except')) throw _unsupported('multipleExceptClauses');
    }
    if (_checkKeyword('else')) throw _unsupported('tryElse');

    IrStmt? finallyBody;
    if (_matchKeyword('finally')) finallyBody = _suite();

    if (catchBody == null && finallyBody == null) throw _syntax('expectedExceptOrFinally');
    if (catchVar != null) _noteAssignment(catchVar);
    return IrTry(line: line, body: body, catchVar: catchVar, catchBody: catchBody, finallyBody: finallyBody);
  }

  IrStmt _functionDef({bool isMethod = false}) {
    final line = _advance().line; // def
    final name = _expectName();

    final savedSelf = _selfName;
    // A method binds its own receiver (`_parameterList` picks the name up
    // from the first parameter). A top-level function has none. A nested
    // `def` inherits whatever encloses it, so that a helper defined inside a
    // method can still reach `self` the way Python's closures allow.
    final params = _parameterList(isMethod: isMethod);
    if (!isMethod && _scopes.length == 1) _selfName = null;

    if (_matchOp('->')) _skipTypeAnnotation();

    final body = _functionBody(params);
    _selfName = savedSelf;

    return IrFunctionDecl(line: line, name: name == '__init__' ? '<init>' : name, params: params, body: body);
  }

  /// Parses a suite as a function body, hoisting the names it assigns.
  List<IrStmt> _functionBody(List<IrParam> params) {
    _scopes.add(_FunctionScope(isModule: false, params: <String>{for (final p in params) p.name}));
    final statements = _block();
    final scope = _scopes.removeLast();
    return <IrStmt>[...scope.hoisted, ...statements];
  }

  List<IrParam> _parameterList({required bool isMethod}) {
    _expectOp('(');
    final params = <IrParam>[];
    var first = true;
    while (!_checkOp(')')) {
      if (_checkOp('*') || _checkOp('**')) throw _unsupported('varargsParameter');
      final pName = _expectName();
      if (_matchOp(':')) _skipTypeAnnotation();
      IrExpr? defaultValue;
      if (_matchOp('=')) defaultValue = _ternary();

      if (first && isMethod) {
        // The receiver. The compiler binds it as `this` in slot 0, so it is
        // not a declared parameter here — references to it are rewritten.
        _selfName = pName;
      } else {
        params.add(IrParam(pName, defaultValue: defaultValue));
      }
      first = false;
      if (!_matchOp(',')) break;
    }
    _expectOp(')');
    return params;
  }

  /// Skips a type annotation — `int`, `List[int]`, `Optional[Dict[str, int]]`
  /// — without interpreting it.
  void _skipTypeAnnotation() {
    var depth = 0;
    while (!_isAtEnd) {
      final lexeme = _peek.lexeme;
      if (depth == 0 && (lexeme == ',' || lexeme == ')' || lexeme == '=' || lexeme == ':')) return;
      if (_check(PythonTokenType.newline)) return;
      if (lexeme == '[' || lexeme == '(') depth++;
      if (lexeme == ']' || lexeme == ')') depth--;
      _advance();
    }
  }

  IrStmt _classDef() {
    final line = _advance().line;
    final name = _expectName();

    String? superclass;
    if (_matchOp('(')) {
      if (!_checkOp(')')) {
        final base = _expectName();
        if (base != 'object') superclass = base;
        if (_checkOp(',')) throw _unsupported('multipleInheritance');
      }
      _expectOp(')');
    }

    _expectOp(':');
    final methods = <IrFunctionDecl>[];

    if (_check(PythonTokenType.newline)) {
      _advance();
      _expect(PythonTokenType.indent, 'expectedIndentedBlock');
      while (!_check(PythonTokenType.dedent) && !_isAtEnd) {
        if (_check(PythonTokenType.newline)) {
          _advance();
          continue;
        }
        if (_matchKeyword('pass')) {
          _expectNewline();
          continue;
        }
        if (_checkOp('@')) throw _unsupported('decorator');
        if (!_checkKeyword('def')) throw _unsupported('classBodyStatement');
        methods.add(_functionDef(isMethod: true) as IrFunctionDecl);
      }
      _expect(PythonTokenType.dedent, 'expectedDedent');
    } else if (_matchKeyword('pass')) {
      _expectNewline();
    } else {
      throw _syntax('expectedIndentedBlock');
    }

    return IrClassDecl(line: line, name: name, superclass: superclass, methods: methods);
  }

  /// A `:`-introduced block, as a single statement.
  IrStmt _suite() {
    final line = _peek.line;
    return IrBlock(line: line, statements: _block());
  }

  /// A `:`-introduced block, as a flat statement list. Handles both the
  /// indented form and the one-line form (`if x: return 1`).
  List<IrStmt> _block() {
    _expectOp(':');
    if (!_check(PythonTokenType.newline)) {
      final statements = <IrStmt>[_simpleStatement()];
      while (_matchOp(';')) {
        if (_check(PythonTokenType.newline) || _isAtEnd) break;
        statements.add(_simpleStatement());
      }
      _expectNewline();
      return statements;
    }
    _advance(); // newline
    _expect(PythonTokenType.indent, 'expectedIndentedBlock');
    final statements = <IrStmt>[];
    while (!_check(PythonTokenType.dedent) && !_isAtEnd) {
      if (_check(PythonTokenType.newline)) {
        _advance();
        continue;
      }
      statements.add(_statement());
    }
    _expect(PythonTokenType.dedent, 'expectedDedent');
    if (statements.isEmpty) throw _syntax('expectedIndentedBlock');
    return statements;
  }

  // -------------------------------------------------------------------
  // Expressions, lowest precedence first
  // -------------------------------------------------------------------

  /// A bare comma-separated list is a tuple: `return 1, 2` and `x = 1, 2`.
  IrExpr _expressionList() {
    final first = _ternary();
    if (!_checkOp(',')) return first;
    final line = _peek.line;
    final items = <IrExpr>[first];
    while (_matchOp(',')) {
      if (_check(PythonTokenType.newline) || _isAtEnd || _checkOp(')') || _checkOp(']')) break;
      items.add(_ternary());
    }
    return IrTupleLiteral(line: line, items: items);
  }

  IrExpr _ternary() {
    if (_checkKeyword('lambda')) return _lambda();
    final thenExpr = _or();
    if (!_checkKeyword('if')) return thenExpr;
    final line = _advance().line;
    final condition = _or();
    if (!_matchKeyword('else')) throw _syntax('expectedElse');
    final elseExpr = _ternary();
    return IrConditional(line: line, condition: condition, thenExpr: thenExpr, elseExpr: elseExpr);
  }

  IrExpr _lambda() {
    final line = _advance().line; // lambda
    final params = <IrParam>[];
    while (!_checkOp(':')) {
      if (_checkOp('*') || _checkOp('**')) throw _unsupported('varargsParameter');
      final name = _expectName();
      IrExpr? defaultValue;
      if (_matchOp('=')) defaultValue = _ternary();
      params.add(IrParam(name, defaultValue: defaultValue));
      if (!_matchOp(',')) break;
    }
    _expectOp(':');

    _scopes.add(_FunctionScope(isModule: false, params: <String>{for (final p in params) p.name}));
    final body = _ternary();
    final scope = _scopes.removeLast();

    return IrLambda(
      line: line,
      params: params,
      isExpressionBody: scope.hoisted.isEmpty,
      body: <IrStmt>[...scope.hoisted, IrReturn(line: line, value: body)],
    );
  }

  IrExpr _or() {
    var left = _and();
    while (_checkKeyword('or')) {
      final line = _advance().line;
      left = IrBinary(line: line, op: IrBinaryOp.or, left: left, right: _and());
    }
    return left;
  }

  IrExpr _and() {
    var left = _not();
    while (_checkKeyword('and')) {
      final line = _advance().line;
      left = IrBinary(line: line, op: IrBinaryOp.and, left: left, right: _not());
    }
    return left;
  }

  IrExpr _not() {
    if (_checkKeyword('not')) {
      final line = _advance().line;
      return IrUnary(line: line, op: IrUnaryOp.not, operand: _not());
    }
    return _comparison();
  }

  IrExpr _comparison() {
    var left = _arithmetic();
    IrExpr? chain;

    while (true) {
      final line = _peek.line;
      final IrExpr right;
      final IrExpr comparison;

      if (_checkKeyword('not') && _peekAhead(1).lexeme == 'in') {
        _advance();
        _advance();
        right = _arithmetic();
        comparison = IrUnary(line: line, op: IrUnaryOp.not, operand: _containsCall(line, right, left));
      } else if (_matchKeyword('in')) {
        right = _arithmetic();
        comparison = _containsCall(line, right, left);
      } else if (_checkKeyword('is')) {
        _advance();
        final negated = _matchKeyword('not');
        right = _arithmetic();
        // Python's `is` is identity, which for the values this engine models
        // — `None`, `True`, `False` — is the same question as equality.
        comparison =
            IrBinary(line: line, op: negated ? IrBinaryOp.notEq : IrBinaryOp.eq, left: left, right: right);
      } else {
        final op = switch (_peek.lexeme) {
          '<' => IrBinaryOp.lt,
          '<=' => IrBinaryOp.lte,
          '>' => IrBinaryOp.gt,
          '>=' => IrBinaryOp.gte,
          '==' => IrBinaryOp.eq,
          '!=' => IrBinaryOp.notEq,
          _ => null,
        };
        if (op == null || !_check(PythonTokenType.op)) break;
        _advance();
        right = _arithmetic();
        comparison = IrBinary(line: line, op: op, left: left, right: right);
      }

      // `1 <= x <= 10` means `1 <= x and x <= 10`. The middle operand is
      // evaluated once per comparison it takes part in, so a chain whose
      // middle term has a side effect would run it twice — vanishingly rare,
      // and the alternative needs a temporary the IR has no expression for.
      chain = chain == null
          ? comparison
          : IrBinary(line: line, op: IrBinaryOp.and, left: chain, right: comparison);
      left = right;
      if (!_startsComparison()) break;
    }
    return chain ?? left;
  }

  bool _startsComparison() {
    if (_checkKeyword('in') || _checkKeyword('is')) return true;
    if (_checkKeyword('not') && _peekAhead(1).lexeme == 'in') return true;
    if (!_check(PythonTokenType.op)) return false;
    return const <String>['<', '<=', '>', '>=', '==', '!='].contains(_peek.lexeme);
  }

  IrExpr _containsCall(int line, IrExpr container, IrExpr item) => IrCall(
      line: line,
      callee: IrIdentifier(line: line, synthetic: true, name: '__contains__'),
      args: <IrExpr>[container, item]);

  IrExpr _arithmetic() {
    var left = _term();
    while (_checkOp('+') || _checkOp('-')) {
      final op = _advance();
      left = IrBinary(
          line: op.line, op: op.lexeme == '+' ? IrBinaryOp.add : IrBinaryOp.sub, left: left, right: _term());
    }
    return left;
  }

  IrExpr _term() {
    var left = _factor();
    while (_checkOp('*') || _checkOp('/') || _checkOp('//') || _checkOp('%')) {
      final op = _advance();
      final irOp = switch (op.lexeme) {
        '*' => IrBinaryOp.mul,
        '/' => IrBinaryOp.div,
        '//' => IrBinaryOp.floorDiv,
        _ => IrBinaryOp.mod,
      };
      left = IrBinary(line: op.line, op: irOp, left: left, right: _factor());
    }
    return left;
  }

  IrExpr _factor() {
    if (_checkOp('-')) {
      final line = _advance().line;
      return IrUnary(line: line, op: IrUnaryOp.negate, operand: _factor());
    }
    if (_checkOp('+')) {
      _advance();
      return _factor();
    }
    if (_checkOp('~') ||
        _checkOp('&') ||
        _checkOp('|') ||
        _checkOp('^') ||
        _checkOp('<<') ||
        _checkOp('>>')) {
      throw _unsupported('bitwiseOperator');
    }
    return _power();
  }

  IrExpr _power() {
    final base = _postfix();
    if (!_checkOp('**')) return base;
    final line = _advance().line;
    // Right-associative, and its right operand binds tighter than unary minus
    // on the left: `-2 ** 2` is `-(2 ** 2)`.
    return IrBinary(line: line, op: IrBinaryOp.pow, left: base, right: _factor());
  }

  IrExpr _postfix() {
    var expr = _atom();
    while (true) {
      if (_checkOp('(')) {
        expr = _finishCall(expr);
      } else if (_checkOp('[')) {
        expr = _subscript(expr);
      } else if (_checkOp('.')) {
        final line = _advance().line;
        final name = _expectName();
        expr = _memberAccess(line, expr, name);
      } else {
        return expr;
      }
    }
  }

  IrExpr _subscript(IrExpr receiver) {
    final line = _advance().line; // [
    IrExpr? start;
    if (!_checkOp(':')) start = _ternary();

    if (!_checkOp(':')) {
      _expectOp(']');
      return IrIndexGet(line: line, receiver: receiver, index: start!);
    }

    _advance(); // :
    IrExpr? end;
    if (!_checkOp(']') && !_checkOp(':')) end = _ternary();
    IrExpr? step;
    if (_matchOp(':') && !_checkOp(']')) step = _ternary();
    _expectOp(']');
    return IrSlice(line: line, receiver: receiver, start: start, end: end, step: step);
  }

  // -------------------------------------------------------------------
  // Member access — where Python's stdlib names are translated
  // -------------------------------------------------------------------

  IrExpr _memberAccess(int line, IrExpr receiver, String name) {
    // `super().__init__(...)`. `super` is an ordinary name in Python, so by
    // the time we get here it has already been parsed as a no-argument call.
    if (receiver is IrCall &&
        receiver.args.isEmpty &&
        receiver.callee is IrIdentifier &&
        (receiver.callee as IrIdentifier).name == 'super') {
      if (!_checkOp('(')) throw _syntax('expectedCallAfterSuper');
      final (args, keywords) = _arguments();
      if (keywords.isNotEmpty) throw _unsupported('keywordArgumentsInSuperCall', line);
      return IrSuperCall(line: line, name: name == '__init__' ? '<init>' : name, args: args);
    }

    if (!_checkOp('(')) {
      // A plain attribute read: `self.head`, `node.next`.
      return IrPropertyGet(line: line, receiver: receiver, name: name);
    }

    final (args, keywords) = _arguments();

    // `d.keys()` reads as a call in Python but is a getter here.
    if (pythonPropertyMethods.contains(name) && args.isEmpty && keywords.isEmpty) {
      return IrPropertyGet(line: line, receiver: receiver, name: name);
    }

    final helper = pythonMethodHelpers[name];
    if (helper != null) {
      return IrCall(
        line: line,
        callee: IrIdentifier(line: line, synthetic: true, name: helper),
        args: <IrExpr>[receiver, ..._helperArguments(line, name, args, keywords)],
      );
    }

    // Not a method the frontend translates: leave it exactly as written, so
    // the learner's own methods reach their own class.
    if (keywords.isNotEmpty) throw _unsupported('keywordArgumentsForMethod', line);
    return IrCall(
      line: line,
      callee: IrPropertyGet(line: line, receiver: receiver, name: name),
      args: args,
    );
  }

  /// Orders the arguments of a helper-backed method, which is the only place
  /// a method may take keyword arguments (`xs.sort(key=f, reverse=True)`).
  List<IrExpr> _helperArguments(
      int line, String name, List<IrExpr> positional, Map<String, IrExpr> keywords) {
    if (keywords.isEmpty) return positional;
    if (name != 'sort') throw _unsupported('keywordArgumentsForMethod', line);
    final nullLiteral = IrLiteral(line: line, synthetic: true, kind: IrLiteralKind.nullLit, value: null);
    final falseLiteral = IrLiteral(line: line, synthetic: true, kind: IrLiteralKind.boolLit, value: false);
    for (final key in keywords.keys) {
      if (key != 'key' && key != 'reverse') {
        throw _unsupported('unknownKeywordArgument', line);
      }
    }
    return <IrExpr>[keywords['key'] ?? nullLiteral, keywords['reverse'] ?? falseLiteral];
  }

  IrExpr _finishCall(IrExpr callee) {
    final line = _peek.line;
    final (args, keywords) = _arguments();
    if (keywords.isEmpty) return IrCall(line: line, callee: callee, args: args);

    if (callee is! IrIdentifier) throw _unsupported('keywordArgumentsForExpression', line);
    final params = _signatures[callee.name];
    if (params == null) throw _unsupported('keywordArgumentsForUnknownFunction', line);

    // Re-order into a positional call, padding any gap with None the way an
    // unsupplied optional parameter arrives anyway.
    final ordered = <IrExpr>[...args];
    for (var i = args.length; i < params.length; i++) {
      final supplied = keywords.remove(params[i]);
      ordered
          .add(supplied ?? IrLiteral(line: line, synthetic: true, kind: IrLiteralKind.nullLit, value: null));
    }
    if (keywords.isNotEmpty) throw _unsupported('unknownKeywordArgument', line);
    while (
        ordered.length > args.length && ordered.last is IrLiteral && (ordered.last as IrLiteral).synthetic) {
      ordered.removeLast();
    }
    return IrCall(line: line, callee: callee, args: ordered);
  }

  (List<IrExpr>, Map<String, IrExpr>) _arguments() {
    _expectOp('(');
    final positional = <IrExpr>[];
    final keywords = <String, IrExpr>{};
    while (!_checkOp(')')) {
      if (_checkOp('**')) throw _unsupported('doubleStarArgument');
      if (_matchOp('*')) {
        positional.add(IrSpread(line: _peek.line, value: _ternary()));
      } else if (_peek.type == PythonTokenType.name &&
          _peekAhead(1).lexeme == '=' &&
          _peekAhead(1).type == PythonTokenType.op) {
        final name = _expectName();
        _expectOp('=');
        keywords[name] = _ternary();
      } else {
        final expr = _ternary();
        // `sum(x * 2 for x in xs)` — a generator expression may be a call's
        // sole argument without parentheses of its own.
        positional.add(
            _checkKeyword('for') ? _comprehension(_peek.line, expr, null, IrComprehensionKind.list) : expr);
      }
      if (!_matchOp(',')) break;
    }
    _expectOp(')');
    return (positional, keywords);
  }

  // -------------------------------------------------------------------
  // Atoms
  // -------------------------------------------------------------------

  IrExpr _atom() {
    final t = _peek;
    final line = t.line;

    switch (t.type) {
      case PythonTokenType.intLiteral:
        _advance();
        return IrLiteral(line: line, kind: IrLiteralKind.intLit, value: t.literal);
      case PythonTokenType.floatLiteral:
        _advance();
        return IrLiteral(line: line, kind: IrLiteralKind.numLit, value: t.literal);
      case PythonTokenType.stringLiteral:
        _advance();
        return _stringLiteral(t);
      case PythonTokenType.name:
        _advance();
        if (t.lexeme == _selfName) return IrIdentifier(line: line, name: 'this');
        return IrIdentifier(line: line, name: t.lexeme);
      case PythonTokenType.keyword:
        switch (t.lexeme) {
          case 'True':
            _advance();
            return IrLiteral(line: line, kind: IrLiteralKind.boolLit, value: true);
          case 'False':
            _advance();
            return IrLiteral(line: line, kind: IrLiteralKind.boolLit, value: false);
          case 'None':
            _advance();
            return IrLiteral(line: line, kind: IrLiteralKind.nullLit, value: null);
          case 'lambda':
            return _lambda();
          case 'not':
            return _not();
          case 'await':
            throw _unsupported('await');
          case 'yield':
            throw _unsupported('yield');
        }
      default:
        break;
    }

    if (_matchOp('(')) return _parenthesised(line);
    if (_matchOp('[')) return _listDisplay(line);
    if (_matchOp('{')) return _braceDisplay(line);

    throw _syntax('expectedExpression');
  }

  IrExpr _parenthesised(int line) {
    if (_matchOp(')')) return IrTupleLiteral(line: line, items: const <IrExpr>[]);
    final first = _ternary();
    if (_checkKeyword('for')) {
      // A generator expression. Materialised as a list, since the engine has
      // no lazy sequences and every use here (`sum(...)`, `max(...)`) is
      // immediate anyway.
      final comprehension = _comprehension(line, first, null, IrComprehensionKind.list);
      _expectOp(')');
      return comprehension;
    }
    if (_matchOp(')')) return first;

    final items = <IrExpr>[first];
    while (_matchOp(',')) {
      if (_checkOp(')')) break;
      items.add(_ternary());
    }
    _expectOp(')');
    return IrTupleLiteral(line: line, items: items);
  }

  IrExpr _listDisplay(int line) {
    if (_matchOp(']')) return IrListLiteral(line: line, items: const <IrExpr>[]);
    final first = _starrableItem();
    if (_checkKeyword('for')) {
      final comprehension = _comprehension(line, first, null, IrComprehensionKind.list);
      _expectOp(']');
      return comprehension;
    }
    final items = <IrExpr>[first];
    while (_matchOp(',')) {
      if (_checkOp(']')) break;
      items.add(_starrableItem());
    }
    _expectOp(']');
    return IrListLiteral(line: line, items: items);
  }

  IrExpr _braceDisplay(int line) {
    if (_matchOp('}')) return IrMapLiteral(line: line, keys: const <IrExpr>[], values: const <IrExpr>[]);

    final first = _starrableItem();
    if (_matchOp(':')) {
      final firstValue = _ternary();
      if (_checkKeyword('for')) {
        final comprehension = _comprehension(line, firstValue, first, IrComprehensionKind.map);
        _expectOp('}');
        return comprehension;
      }
      final keys = <IrExpr>[first];
      final values = <IrExpr>[firstValue];
      while (_matchOp(',')) {
        if (_checkOp('}')) break;
        keys.add(_ternary());
        _expectOp(':');
        values.add(_ternary());
      }
      _expectOp('}');
      return IrMapLiteral(line: line, keys: keys, values: values);
    }

    if (_checkKeyword('for')) {
      final comprehension = _comprehension(line, first, null, IrComprehensionKind.set);
      _expectOp('}');
      return comprehension;
    }
    final items = <IrExpr>[first];
    while (_matchOp(',')) {
      if (_checkOp('}')) break;
      items.add(_starrableItem());
    }
    _expectOp('}');
    return IrSetLiteral(line: line, items: items);
  }

  IrExpr _starrableItem() {
    if (_matchOp('*')) return IrSpread(line: _peek.line, value: _ternary());
    if (_checkOp('**')) throw _unsupported('dictUnpacking');
    return _ternary();
  }

  // -------------------------------------------------------------------
  // Comprehensions
  // -------------------------------------------------------------------

  /// Builds `[element for loopVar in iterable if condition]` — and the dict
  /// and set forms — as an immediately-called function that accumulates into
  /// a local and returns it. See this library's doc comment for why.
  IrExpr _comprehension(int line, IrExpr element, IrExpr? keyElement, IrComprehensionKind kind) {
    final clauses = <({List<String> names, IrExpr iterable, List<IrExpr> conditions})>[];

    while (_matchKeyword('for')) {
      final names = <String>[_expectName()];
      while (_matchOp(',')) {
        names.add(_expectName());
      }
      if (!_matchKeyword('in')) throw _syntax('expectedIn');
      // `or` rather than the full ternary: a bare `if` after this belongs to
      // the comprehension, not to a conditional expression.
      final iterable = _or();
      final conditions = <IrExpr>[];
      while (_checkKeyword('if')) {
        _advance();
        conditions.add(_or());
      }
      clauses.add((names: names, iterable: iterable, conditions: conditions));
    }
    if (clauses.isEmpty) throw _syntax('expectedFor');

    final accumulator = _nextTemp();
    IrExpr acc() => IrIdentifier(line: line, synthetic: true, name: accumulator);

    final IrExpr empty = switch (kind) {
      IrComprehensionKind.list => IrListLiteral(line: line, synthetic: true, items: const <IrExpr>[]),
      IrComprehensionKind.set => IrSetLiteral(line: line, synthetic: true, items: const <IrExpr>[]),
      IrComprehensionKind.map =>
        IrMapLiteral(line: line, synthetic: true, keys: const <IrExpr>[], values: const <IrExpr>[]),
    };

    IrStmt collect = IrExprStmt(
      line: line,
      synthetic: true,
      expr: switch (kind) {
        IrComprehensionKind.map =>
          IrIndexSet(line: line, synthetic: true, receiver: acc(), index: keyElement!, value: element),
        _ => IrCall(
            line: line,
            synthetic: true,
            callee: IrPropertyGet(line: line, synthetic: true, receiver: acc(), name: 'add'),
            args: <IrExpr>[element]),
      },
    );

    // Innermost clause first, so `for a in xs for b in ys` nests the way
    // Python reads it.
    for (final clause in clauses.reversed) {
      for (final condition in clause.conditions.reversed) {
        collect = IrIf(line: line, synthetic: true, condition: condition, thenBranch: collect);
      }
      if (clause.names.length == 1) {
        collect = IrForIn(
            line: line,
            synthetic: true,
            varName: clause.names.single,
            iterable: clause.iterable,
            body: collect);
      } else {
        final holder = _nextTemp();
        collect = IrForIn(
          line: line,
          synthetic: true,
          varName: holder,
          iterable: clause.iterable,
          body: IrBlock(line: line, synthetic: true, statements: <IrStmt>[
            IrDestructure(
                line: line,
                synthetic: true,
                names: clause.names,
                value: IrIdentifier(line: line, synthetic: true, name: holder)),
            collect,
          ]),
        );
      }
    }

    return IrCall(
      line: line,
      synthetic: true,
      callee: IrLambda(
        line: line,
        synthetic: true,
        params: const <IrParam>[],
        body: <IrStmt>[
          IrVarDecl(line: line, synthetic: true, name: accumulator, initializer: empty),
          collect,
          IrReturn(line: line, synthetic: true, value: acc()),
        ],
      ),
      args: const <IrExpr>[],
    );
  }

  // -------------------------------------------------------------------
  // Strings
  // -------------------------------------------------------------------

  IrExpr _stringLiteral(PythonToken token) {
    final parts = token.literal! as List<Object>;
    if (parts.length == 1 && parts.first is String) {
      return IrLiteral(line: token.line, kind: IrLiteralKind.strLit, value: parts.first);
    }
    return IrTemplateString(
      line: token.line,
      parts: <Object>[
        for (final part in parts)
          if (part is PythonInterpolation) _parseInterpolation(part) else part,
      ],
    );
  }

  /// Parses one `{...}` hole of an f-string by re-entering this same parser,
  /// so it sees the same `self` binding and the same signatures. The source
  /// is padded with newlines so the sub-lexer's line numbers already match
  /// the learner's file — no offset fix-up needed afterwards.
  IrExpr _parseInterpolation(PythonInterpolation slice) {
    final padded = '\n' * (slice.line - 1) + slice.source;
    final savedTokens = _tokens;
    final savedPos = _pos;
    try {
      _tokens = PythonLexer().tokenize(padded);
      _pos = 0;
      final expr = _expressionList();
      if (!_check(PythonTokenType.newline) && !_isAtEnd) throw _syntax('expectedExpression');
      return expr;
    } finally {
      _tokens = savedTokens;
      _pos = savedPos;
    }
  }
}
