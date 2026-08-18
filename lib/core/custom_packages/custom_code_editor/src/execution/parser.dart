import 'ast.dart';
import 'lexer.dart';

/// Thrown when [Parser] encounters source that doesn't fit the supported
/// subset of Dart. Carries the 1-indexed source [line] so the editor can
/// highlight exactly where things went wrong.
class ParseError implements Exception {
  ParseError(this.message, this.line);
  final String message;
  final int line;

  @override
  String toString() => 'ParseError: $message (line $line)';
}

const Set<String> _typeKeywords = <String>{
  'void',
  'int',
  'double',
  'String',
  'bool',
  'num',
  'dynamic',
  'List',
  'Map',
};

/// A hand-written recursive-descent parser for a deliberately small
/// subset of Dart: top-level function declarations, local variables,
/// `if`/`while`/`for`/`for-in`, `return`/`break`/`continue`, arithmetic
/// and logical expressions, list literals/indexing, and string
/// interpolation. No classes, no async, no imports, no generics beyond
/// `List<T>` (parsed and ignored).
class Parser {
  Parser(this.tokens);

  final List<Tok> tokens;
  int pos = 0;

  Tok get _peek => tokens[pos];
  Tok get _previous => tokens[pos - 1];
  bool _isAtEnd() => _peek.kind == TokKind.eof;

  Tok _advance() {
    if (!_isAtEnd()) pos++;
    return _previous;
  }

  bool _check(TokKind kind, [String? text]) =>
      !_isAtEnd() && _peek.kind == kind && (text == null || _peek.text == text);

  bool _checkSymbol(String s) => _check(TokKind.symbol, s);
  bool _checkKeyword(String s) => _check(TokKind.keyword, s);

  bool _matchSymbol(String s) {
    if (_checkSymbol(s)) {
      _advance();
      return true;
    }
    return false;
  }

  bool _matchKeyword(String s) {
    if (_checkKeyword(s)) {
      _advance();
      return true;
    }
    return false;
  }

  Tok _consumeSymbol(String s, String errMsg) {
    if (_checkSymbol(s)) return _advance();
    throw ParseError(errMsg, _peek.line);
  }

  Tok _consumeIdentifier(String errMsg) {
    if (_check(TokKind.identifier)) return _advance();
    throw ParseError(errMsg, _peek.line);
  }

  Tok _consumeKeyword(String keyword) {
    if (_checkKeyword(keyword)) return _advance();
    throw ParseError('Expected "$keyword"', _peek.line);
  }

  bool _isVarDeclStart() {
    if (_check(TokKind.keyword) &&
        (_peek.text == 'var' || _peek.text == 'final' || _peek.text == 'const' || _typeKeywords.contains(_peek.text))) {
      return true;
    }
    // Custom (identifier) type names: `ListNode head`, `ListNode? next`, etc.
    if (_check(TokKind.identifier)) {
      if (pos + 1 >= tokens.length) return false;
      if (tokens[pos + 1].kind == TokKind.identifier) return true;
      if (tokens[pos + 1].kind == TokKind.symbol &&
          tokens[pos + 1].text == '?' &&
          pos + 2 < tokens.length &&
          tokens[pos + 2].kind == TokKind.identifier) {
        return true;
      }
    }
    return false;
  }

  /// Consumes a type (keyword type, `var`/`final`/`const`, custom identifier
  /// type, optional generics and nullable marker) and returns its source text,
  /// e.g. `List<int>`, `ListNode?`, `final Map<int, int>` or `void`.
  String _skipType() {
    final int start = pos;
    if (_check(TokKind.keyword) && _typeKeywords.contains(_peek.text)) {
      _advance();
    } else if (_check(TokKind.keyword) &&
        (_peek.text == 'var' || _peek.text == 'final' || _peek.text == 'const')) {
      _advance();
      // After `var`/`final`/`const`, consume the actual type only if the
      // next token looks like a type (not a variable name):
      //   - keyword type: `final Map<int, int> seen`
      //   - custom type followed by identifier: `final ListNode head`
      // But NOT when followed by `=` or `(` or `;` (it's a var name):
      //   - `final s = Solution()`
      if (_check(TokKind.keyword) && _typeKeywords.contains(_peek.text)) {
        _advance();
      } else if (_check(TokKind.identifier) && pos + 1 < tokens.length) {
        final next = tokens[pos + 1];
        // Custom type: identifier followed by another identifier (`ListNode head`)
        // or by `?` then identifier (`ListNode? next`).
        if (next.kind == TokKind.identifier) {
          _advance();
        } else if (next.kind == TokKind.symbol && next.text == '?' &&
            pos + 2 < tokens.length && tokens[pos + 2].kind == TokKind.identifier) {
          _advance();
        }
      }
    } else if (_check(TokKind.identifier)) {
      _advance();
    } else {
      throw ParseError('Expected a type', _peek.line);
    }
    if (_checkSymbol('<')) {
      _advance();
      int depth = 1;
      while (depth > 0) {
        if (_isAtEnd()) throw ParseError('Unterminated generic type', _peek.line);
        if (_checkSymbol('<')) {
          depth++;
          _advance();
          continue;
        }
        if (_checkSymbol('>')) {
          depth--;
          _advance();
          continue;
        }
        _advance();
      }
    }
    // Nullable type marker (e.g. `ListNode?`, `int?`).
    if (_checkSymbol('?')) _advance();
    return tokens.sublist(start, pos).map((t) => t.text).join();
  }

  // ---------------------------------------------------------------------
  // Top level
  // ---------------------------------------------------------------------

  Program parseProgram() {
    final List<FunctionDecl> fns = <FunctionDecl>[];
    final List<VarDeclStmt> vars = <VarDeclStmt>[];
    final List<ClassDecl> classes = <ClassDecl>[];
    while (!_isAtEnd()) {
      if (_checkKeyword('class')) {
        classes.add(_parseClassDecl());
        continue;
      }
      if (!_isVarDeclStart()) {
        throw ParseError(
          'Expected a function or variable declaration, found "${_peek.text}"',
          _peek.line,
        );
      }
      final int startLine = _peek.line;
      final String returnType = _skipType();
      final Tok nameTok = _consumeIdentifier('Expected a name after the type');
      if (_checkSymbol('(')) {
        final List<Param> params = _parseParamList();
        final Block body = _parseBlock();
        _assertReturnTypeSatisfied(returnType, body, nameTok.text, startLine);
        fns.add(FunctionDecl(nameTok.text, params, body, startLine));
      } else {
        Expr? init;
        if (_matchSymbol('=')) init = _parseExpr();
        _consumeSymbol(';', "Expected ';' after variable declaration");
        vars.add(VarDeclStmt(nameTok.text, init, startLine));
      }
    }
    return Program(fns, vars, classes, 1);
  }

  /// Mirrors Dart's own "doesn't end with a return statement" compile error:
  /// a function whose return type is non-void, non-nullable and not `dynamic`
  /// must contain a `return` somewhere in its body. An empty body (the seeded
  /// default state) fails this, which is reported as a syntax error before
  /// the program ever runs.
  void _assertReturnTypeSatisfied(String returnType, Block body, String name, int line) {
    final t = returnType.trim();
    if (t == 'void' || t == 'dynamic' || t.endsWith('?') || _containsReturn(body)) return;
    throw ParseError(
      "This function has a return type of '$t', but doesn't end with a return statement.",
      line,
    );
  }

  bool _containsReturn(Block block) {
    for (final stmt in block.statements) {
      if (_stmtContainsReturn(stmt)) return true;
    }
    return false;
  }

  bool _stmtContainsReturn(Stmt stmt) {
    if (stmt is ReturnStmt) return true;
    if (stmt is Block) return _containsReturn(stmt);
    if (stmt is IfStmt) {
      return _stmtContainsReturn(stmt.thenBranch) ||
          (stmt.elseBranch != null && _stmtContainsReturn(stmt.elseBranch!));
    }
    if (stmt is WhileStmt) return _stmtContainsReturn(stmt.body);
    if (stmt is ForStmt) return _stmtContainsReturn(stmt.body);
    if (stmt is ForInStmt) return _stmtContainsReturn(stmt.body);
    return false;
  }

  ClassDecl _parseClassDecl() {
    final int line = _peek.line;
    _advance(); // 'class'
    final Tok nameTok = _consumeIdentifier('Expected a class name');
    _consumeSymbol('{', "Expected '{' after class name");
    final List<FieldDecl> fields = <FieldDecl>[];
    final List<FunctionDecl> methods = <FunctionDecl>[];
    List<ConstructorParam>? constructorParams;
    while (!_checkSymbol('}') && !_isAtEnd()) {
      final int memberLine = _peek.line;
      _skipType();
      if (_checkSymbol('(')) {
        constructorParams = _parseConstructorParams();
      } else {
        final Tok memberTok = _consumeIdentifier('Expected a field or method name');
        if (_checkSymbol('(')) {
          // Method declaration: ReturnType methodName(params) { body }
          final List<Param> mParams = _parseParamList();
          final Block mBody = _parseBlock();
          methods.add(FunctionDecl(memberTok.text, mParams, mBody, memberLine));
        } else {
          Expr? fieldDefault;
          if (_matchSymbol('=')) fieldDefault = _parseExpr();
          _consumeSymbol(';', "Expected ';' after field declaration");
          fields.add(FieldDecl(memberTok.text, fieldDefault, memberLine));
        }
      }
    }
    _consumeSymbol('}', "Expected '}' after class body");
    return ClassDecl(nameTok.text, fields, constructorParams ?? const <ConstructorParam>[], methods, line);
  }

  List<ConstructorParam> _parseConstructorParams() {
    _consumeSymbol('(', "Expected '('");
    final List<ConstructorParam> params = <ConstructorParam>[];
    final bool optional = _matchSymbol('[');
    if (!_checkSymbol(')')) {
      do {
        if (_checkSymbol(']') || _checkSymbol(')')) break;
        _consumeKeyword('this');
        _consumeSymbol('.', "Expected '.' after 'this'");
        final Tok fieldTok = _consumeIdentifier('Expected a field name after "this."');
        Expr? def;
        if (_matchSymbol('=')) def = _parseExpr();
        params.add(ConstructorParam(fieldTok.text, def));
      } while (_matchSymbol(','));
    }
    if (optional) _consumeSymbol(']', "Expected ']' after optional constructor params");
    _consumeSymbol(')', "Expected ')' after constructor params");
    _consumeSymbol(';', "Expected ';' after constructor");
    return params;
  }

  List<Param> _parseParamList() {
    _consumeSymbol('(', "Expected '('");
    final List<Param> params = <Param>[];
    if (!_checkSymbol(')')) {
      do {
        _skipType();
        final Tok nameTok = _consumeIdentifier('Expected a parameter name');
        params.add(Param(nameTok.text));
      } while (_matchSymbol(','));
    }
    _consumeSymbol(')', "Expected ')'");
    return params;
  }

  // ---------------------------------------------------------------------
  // Statements
  // ---------------------------------------------------------------------

  Block _parseBlock() {
    final int line = _peek.line;
    _consumeSymbol('{', "Expected '{'");
    final List<Stmt> stmts = <Stmt>[];
    while (!_checkSymbol('}') && !_isAtEnd()) {
      stmts.add(_parseStatement());
    }
    _consumeSymbol('}', "Expected '}'");
    return Block(stmts, line);
  }

  Stmt _parseStatement() {
    final int line = _peek.line;
    if (_checkSymbol('{')) return _parseBlock();
    if (_isVarDeclStart()) return _parseLocalVarDecl();
    if (_matchKeyword('if')) return _parseIf(line);
    if (_matchKeyword('while')) return _parseWhile(line);
    if (_matchKeyword('for')) return _parseFor(line);
    if (_matchKeyword('return')) return _parseReturn(line);
    if (_matchKeyword('break')) {
      _consumeSymbol(';', "Expected ';' after 'break'");
      return BreakStmt(line);
    }
    if (_matchKeyword('continue')) {
      _consumeSymbol(';', "Expected ';' after 'continue'");
      return ContinueStmt(line);
    }
    final Expr expr = _parseExpr();
    _consumeSymbol(';', "Expected ';' after expression");
    return ExprStmt(expr, line);
  }

  VarDeclStmt _parseLocalVarDecl() {
    final int line = _peek.line;
    _skipType();
    final Tok nameTok = _consumeIdentifier('Expected a variable name');
    Expr? init;
    if (_matchSymbol('=')) init = _parseExpr();
    _consumeSymbol(';', "Expected ';' after variable declaration");
    return VarDeclStmt(nameTok.text, init, line);
  }

  Stmt _parseIf(int line) {
    _consumeSymbol('(', "Expected '(' after 'if'");
    final Expr cond = _parseExpr();
    _consumeSymbol(')', "Expected ')' after if condition");
    final Stmt thenBranch = _parseStatement();
    Stmt? elseBranch;
    if (_matchKeyword('else')) elseBranch = _parseStatement();
    return IfStmt(cond, thenBranch, elseBranch, line);
  }

  Stmt _parseWhile(int line) {
    _consumeSymbol('(', "Expected '(' after 'while'");
    final Expr cond = _parseExpr();
    _consumeSymbol(')', "Expected ')' after while condition");
    final Stmt body = _parseStatement();
    return WhileStmt(cond, body, line);
  }

  Stmt _parseFor(int line) {
    _consumeSymbol('(', "Expected '(' after 'for'");

    if (_isVarDeclStart()) {
      final int savedPos = pos;
      _skipType();
      if (_check(TokKind.identifier)) {
        final Tok nameTok = _advance();
        if (_checkKeyword('in')) {
          _advance();
          final Expr iterable = _parseExpr();
          _consumeSymbol(')', "Expected ')' after for-in iterable");
          final Stmt body = _parseStatement();
          return ForInStmt(nameTok.text, iterable, body, line);
        }
      }
      pos = savedPos;
    }

    Stmt? init;
    if (_checkSymbol(';')) {
      _advance();
    } else if (_isVarDeclStart()) {
      init = _parseLocalVarDecl();
    } else {
      final Expr e = _parseExpr();
      _consumeSymbol(';', "Expected ';' after for-loop initializer");
      init = ExprStmt(e, line);
    }

    Expr? cond;
    if (!_checkSymbol(';')) cond = _parseExpr();
    _consumeSymbol(';', "Expected ';' after for-loop condition");

    Expr? update;
    if (!_checkSymbol(')')) update = _parseExpr();
    _consumeSymbol(')', "Expected ')' after for-loop update");

    final Stmt body = _parseStatement();
    return ForStmt(init, cond, update, body, line);
  }

  Stmt _parseReturn(int line) {
    Expr? value;
    if (!_checkSymbol(';')) value = _parseExpr();
    _consumeSymbol(';', "Expected ';' after return statement");
    return ReturnStmt(value, line);
  }

  // ---------------------------------------------------------------------
  // Expressions (precedence, low to high)
  // ---------------------------------------------------------------------

  Expr _parseExpr() => _parseAssignment();

  Expr _parseAssignment() {
    final Expr expr = _parseConditional();
    if (_checkSymbol('=') || _checkSymbol('+=') || _checkSymbol('-=') || _checkSymbol('*=') || _checkSymbol('/=')) {
      final Tok opTok = _advance();
      final Expr value = _parseAssignment();
      if (expr is! Identifier && expr is! IndexExpr && expr is! PropertyAccess) {
        throw ParseError('Invalid assignment target', opTok.line);
      }
      return AssignExpr(expr, opTok.text, value, opTok.line);
    }
    return expr;
  }

  Expr _parseConditional() {
    final Expr cond = _parseNullCoalesce();
    if (_matchSymbol('?')) {
      final Expr thenExpr = _parseAssignment();
      _consumeSymbol(':', "Expected ':' in conditional expression");
      final Expr elseExpr = _parseAssignment();
      return ConditionalExpr(cond, thenExpr, elseExpr, cond.line);
    }
    return cond;
  }

  Expr _parseNullCoalesce() {
    Expr expr = _parseOr();
    while (_checkSymbol('??')) {
      final Tok opTok = _advance();
      expr = BinaryExpr('??', expr, _parseOr(), opTok.line);
    }
    return expr;
  }

  Expr _parseOr() {
    Expr expr = _parseAnd();
    while (_checkSymbol('||')) {
      final Tok opTok = _advance();
      expr = BinaryExpr('||', expr, _parseAnd(), opTok.line);
    }
    return expr;
  }

  Expr _parseAnd() {
    Expr expr = _parseEquality();
    while (_checkSymbol('&&')) {
      final Tok opTok = _advance();
      expr = BinaryExpr('&&', expr, _parseEquality(), opTok.line);
    }
    return expr;
  }

  Expr _parseEquality() {
    Expr expr = _parseRelational();
    while (_checkSymbol('==') || _checkSymbol('!=')) {
      final Tok opTok = _advance();
      expr = BinaryExpr(opTok.text, expr, _parseRelational(), opTok.line);
    }
    return expr;
  }

  Expr _parseRelational() {
    Expr expr = _parseAdditive();
    while (_checkSymbol('<') || _checkSymbol('>') || _checkSymbol('<=') || _checkSymbol('>=')) {
      final Tok opTok = _advance();
      expr = BinaryExpr(opTok.text, expr, _parseAdditive(), opTok.line);
    }
    return expr;
  }

  Expr _parseAdditive() {
    Expr expr = _parseMultiplicative();
    while (_checkSymbol('+') || _checkSymbol('-')) {
      final Tok opTok = _advance();
      expr = BinaryExpr(opTok.text, expr, _parseMultiplicative(), opTok.line);
    }
    return expr;
  }

  Expr _parseMultiplicative() {
    Expr expr = _parseUnary();
    while (_checkSymbol('*') || _checkSymbol('/') || _checkSymbol('~/') || _checkSymbol('%')) {
      final Tok opTok = _advance();
      expr = BinaryExpr(opTok.text, expr, _parseUnary(), opTok.line);
    }
    return expr;
  }

  Expr _parseUnary() {
    if (_checkSymbol('!') || _checkSymbol('-')) {
      final Tok opTok = _advance();
      return UnaryExpr(opTok.text, _parseUnary(), opTok.line);
    }
    return _parsePostfix();
  }

  Expr _parsePostfix() {
    Expr expr = _parsePrimary();
    while (true) {
      if (_checkSymbol('[')) {
        final Tok opTok = _advance();
        final Expr index = _parseExpr();
        _consumeSymbol(']', "Expected ']'");
        expr = IndexExpr(expr, index, opTok.line);
      } else if (_checkSymbol('!')) {
        // Null assertion `x!` — a no-op for our dynamic interpreter.
        _advance();
      } else if (_checkSymbol('?.')) {
        // Null-shorting member access `a?.b` / call `a?.b()`. The `?.`
        // token is lexed as a unit so the ternary `?` can't steal it.
        final Tok opTok = _advance();
        final Tok nameTok = _consumeIdentifier('Expected a member name after "?."');
        if (_checkSymbol('(')) {
          final List<Expr> args = _parseArgs();
          expr = CallExpr(
            NullAwareAccess(expr, nameTok.text, opTok.line),
            args,
            opTok.line,
          );
        } else {
          expr = NullAwareAccess(expr, nameTok.text, opTok.line);
        }
      } else if (_checkSymbol('.')) {
        final Tok opTok = _advance();
        final Tok nameTok = _consumeIdentifier('Expected a member name after "."');
        if (_checkSymbol('(')) {
          final List<Expr> args = _parseArgs();
          expr = CallExpr(
            PropertyAccess(expr, nameTok.text, opTok.line),
            args,
            opTok.line,
          );
        } else {
          expr = PropertyAccess(expr, nameTok.text, opTok.line);
        }
      } else if (_checkSymbol('(')) {
        final Tok opTok = _peek;
        expr = CallExpr(expr, _parseArgs(), opTok.line);
      } else if (_checkSymbol('++') || _checkSymbol('--')) {
        final Tok opTok = _advance();
        expr = PostfixExpr(expr, opTok.text, opTok.line);
      } else {
        break;
      }
    }
    return expr;
  }

  List<Expr> _parseArgs() {
    _consumeSymbol('(', "Expected '('");
    final List<Expr> args = <Expr>[];
    if (!_checkSymbol(')')) {
      do {
        args.add(_parseAssignment());
      } while (_matchSymbol(','));
    }
    _consumeSymbol(')', "Expected ')'");
    return args;
  }

  Expr _parsePrimary() {
    final Tok tok = _peek;
    if (_check(TokKind.intLiteral)) {
      _advance();
      return IntLiteral(tok.value as int, tok.line);
    }
    if (_check(TokKind.doubleLiteral)) {
      _advance();
      return DoubleLiteral(tok.value as double, tok.line);
    }
    if (_check(TokKind.stringLiteral)) {
      _advance();
      return _parseStringLiteral(tok);
    }
    if (_checkKeyword('true')) {
      _advance();
      return BoolLiteral(true, tok.line);
    }
    if (_checkKeyword('false')) {
      _advance();
      return BoolLiteral(false, tok.line);
    }
    if (_checkKeyword('null')) {
      _advance();
      return NullLiteral(tok.line);
    }
    if (_checkSymbol('[')) return _parseListLiteral();
    if (_checkSymbol('{')) return _parseMapLiteral();
    // Type-annotated literals: `<int>[]` (list), `<int>{}` (set),
    // `<String, int>{}` (map).
    if (_checkSymbol('<')) {
      _advance();
      int depth = 1;
      var topLevelCommas = 0;
      while (depth > 0) {
        if (_isAtEnd()) throw ParseError('Unterminated type argument list', _peek.line);
        if (_checkSymbol('<')) {
          depth++;
          _advance();
          continue;
        }
        if (_checkSymbol('>')) {
          depth--;
          _advance();
          continue;
        }
        if (_checkSymbol(',') && depth == 1) topLevelCommas++;
        _advance();
      }
      if (_checkSymbol('[')) return _parseListLiteral();
      if (_checkSymbol('{')) {
        return topLevelCommas == 0 ? _parseSetLiteral() : _parseMapLiteral();
      }
      throw ParseError('Expected a list, set or map literal after type arguments', _peek.line);
    }
    if (_checkSymbol('(')) {
      _advance();
      final Expr expr = _parseExpr();
      _consumeSymbol(')', "Expected ')'");
      return expr;
    }
    if (_check(TokKind.identifier)) {
      _advance();
      return Identifier(tok.text, tok.line);
    }
    throw ParseError('Unexpected token "${tok.text}"', tok.line);
  }

  Expr _parseListLiteral() {
    final int line = _peek.line;
    _consumeSymbol('[', "Expected '['");
    final List<Expr> elements = <Expr>[];
    if (!_checkSymbol(']')) {
      do {
        if (_checkSymbol(']')) break; // trailing comma
        elements.add(_parseAssignment());
      } while (_matchSymbol(','));
    }
    _consumeSymbol(']', "Expected ']'");
    return ListLiteral(elements, line);
  }

  Expr _parseSetLiteral() {
    final int line = _peek.line;
    _consumeSymbol('{', "Expected '{'");
    final List<Expr> elements = <Expr>[];
    if (!_checkSymbol('}')) {
      do {
        if (_checkSymbol('}')) break; // trailing comma
        elements.add(_parseAssignment());
      } while (_matchSymbol(','));
    }
    _consumeSymbol('}', "Expected '}'");
    return SetLiteral(elements, line);
  }

  Expr _parseMapLiteral() {
    final int line = _peek.line;
    _consumeSymbol('{', "Expected '{'");
    final List<MapLiteralEntry> entries = <MapLiteralEntry>[];
    if (!_checkSymbol('}')) {
      do {
        if (_checkSymbol('}')) break; // trailing comma
        final Expr key = _parseExpr();
        _consumeSymbol(':', "Expected ':' in map literal");
        final Expr value = _parseAssignment();
        entries.add(MapLiteralEntry(key, value));
      } while (_matchSymbol(','));
    }
    _consumeSymbol('}', "Expected '}'");
    return MapLiteral(entries, line);
  }

  // ---------------------------------------------------------------------
  // String interpolation
  // ---------------------------------------------------------------------

  Expr _parseStringLiteral(Tok tok) {
    final String raw = tok.value as String;
    final List<Object> parts = <Object>[];
    final StringBuffer buf = StringBuffer();
    int i = 0;
    while (i < raw.length) {
      final String c = raw[i];
      if (c == r'$' && i + 1 < raw.length) {
        if (raw[i + 1] == '{') {
          if (buf.isNotEmpty) {
            parts.add(buf.toString());
            buf.clear();
          }
          final int end = _findMatchingBrace(raw, i + 2);
          if (end == -1) {
            throw ParseError('Unterminated string interpolation', tok.line);
          }
          final String exprSrc = raw.substring(i + 2, end);
          parts.add(_parseSubExpr(exprSrc, tok.line));
          i = end + 1;
          continue;
        } else if (RegExp(r'[A-Za-z_]').hasMatch(raw[i + 1])) {
          if (buf.isNotEmpty) {
            parts.add(buf.toString());
            buf.clear();
          }
          int j = i + 1;
          while (j < raw.length && RegExp(r'[A-Za-z0-9_]').hasMatch(raw[j])) {
            j++;
          }
          parts.add(Identifier(raw.substring(i + 1, j), tok.line));
          i = j;
          continue;
        }
      }
      buf.write(c);
      i++;
    }
    if (buf.isNotEmpty) parts.add(buf.toString());
    return StringLiteral(parts, tok.line);
  }

  int _findMatchingBrace(String s, int start) {
    int depth = 1;
    int i = start;
    while (i < s.length) {
      if (s[i] == '{') depth++;
      if (s[i] == '}') {
        depth--;
        if (depth == 0) return i;
      }
      i++;
    }
    return -1;
  }

  Expr _parseSubExpr(String src, int line) {
    final List<Tok> subTokens = Lexer(src).tokenize();
    final Parser subParser = Parser(subTokens);
    return subParser._parseExpr();
  }
}
