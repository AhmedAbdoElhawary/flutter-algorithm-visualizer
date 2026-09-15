/// Assembles the Python [LanguageFrontend]: parsing, the builtins Python
/// adds, and the harness that calls the target function with already-parsed
/// arguments (FR-017). Every node the harness generates is flagged
/// `synthetic`, so a failure inside it is never blamed on the learner.
library;

import '../../ir/ir.dart';
import '../../values/dialect.dart';
import '../../values/value.dart';
import '../frontend.dart';
import 'python_builtins.dart';
import 'python_dialect.dart';
import 'python_parser.dart';

class PythonFrontend implements LanguageFrontend {
  @override
  EditorLanguage get language => EditorLanguage.python;

  @override
  Dialect get dialect => pythonDialect;

  @override
  Map<String, Value> get globals => pythonGlobals();

  @override
  IrProgram parse(String source) {
    final statements = PythonParser().parseProgram(source);

    // Python has no `main`, but a learner experimenting in the editor may
    // still write one and expect it to run, exactly as the Dart frontend
    // allows. Only call it when nothing at top level already does.
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

  /// Whether the program already calls `main()` itself — the
  /// `if __name__ == "__main__":` idiom is out of scope, but a bare
  /// `main()` at the bottom is common.
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
      for (final src in preludeSources) ...PythonParser().parseProgram(src),
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
