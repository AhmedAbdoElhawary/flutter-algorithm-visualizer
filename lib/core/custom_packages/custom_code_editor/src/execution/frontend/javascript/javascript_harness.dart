/// Assembles the JavaScript [LanguageFrontend]: parsing, the builtins
/// JavaScript adds, and the harness that calls the target function with
/// already-parsed arguments (FR-017). Every node the harness generates is
/// flagged `synthetic`, so a failure inside it is never blamed on the
/// learner.
library;

import '../../ir/ir.dart';
import '../../values/dialect.dart';
import '../../values/value.dart';
import '../frontend.dart';
import 'javascript_builtins.dart';
import 'javascript_dialect.dart';
import 'javascript_parser.dart';

class JavascriptFrontend implements LanguageFrontend {
  @override
  EditorLanguage get language => EditorLanguage.javascript;

  @override
  Dialect get dialect => javascriptDialect;

  @override
  Map<String, Value> get globals => javascriptGlobals();

  @override
  IrProgram parse(String source) {
    final statements = JavascriptParser().parseProgram(source);

    // JavaScript has no entry point of its own, but a learner experimenting
    // in the editor may write a `main` and expect it to run, as the Dart and
    // Python frontends both allow.
    final declaresMain = statements.whereType<IrFunctionDecl>().any((f) => f.name == 'main');
    if (!declaresMain || _callsMain(statements)) return IrProgram(statements);
    return IrProgram(<IrStmt>[
      ...statements,
      const IrExprStmt(
        line: 0,
        synthetic: true,
        expr: IrCall(
            line: 0,
            synthetic: true,
            callee: IrIdentifier(line: 0, synthetic: true, name: 'main'),
            args: <IrExpr>[]),
      ),
    ]);
  }

  bool _callsMain(List<IrStmt> statements) => statements.any((s) =>
      s is IrExprStmt &&
      s.expr is IrCall &&
      (s.expr as IrCall).callee is IrIdentifier &&
      ((s.expr as IrCall).callee as IrIdentifier).name == 'main');

  @override
  IrProgram buildHarness({
    required IrProgram userProgram,
    required String functionName,
    required List<Value> arguments,
    required List<String> preludeSources,
  }) {
    final preludeStatements = <IrStmt>[
      for (final src in preludeSources) ...JavascriptParser().parseProgram(src),
    ];
    final args = <IrExpr>[for (final v in arguments) IrRawValue(line: 0, synthetic: true, value: v)];
    final targetCall = IrReturn(
      line: 0,
      synthetic: true,
      value: IrCall(
          line: 0,
          synthetic: true,
          callee: IrIdentifier(line: 0, synthetic: true, name: functionName),
          args: args),
    );
    return IrProgram(<IrStmt>[...preludeStatements, ...userProgram.statements, targetCall]);
  }
}
