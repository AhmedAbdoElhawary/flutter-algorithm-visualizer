/// Assembles the Dart [LanguageFrontend]: parsing plus the harness that
/// calls the target function with already-parsed arguments and captures its
/// return value (FR-017). Every node this generates is flagged `synthetic`
/// so a failure inside it is never attributed to the learner's own code.
library;

import '../../ir/ir.dart';
import '../../values/dialect.dart';
import '../../values/value.dart';
import '../frontend.dart';
import 'dart_dialect.dart';
import 'dart_parser.dart';

class DartFrontend implements LanguageFrontend {
  @override
  EditorLanguage get language => EditorLanguage.dart;

  @override
  Dialect get dialect => dartDialect;

  @override
  IrProgram parse(String source) {
    final statements = DartParser().parseProgram(source);
    final hasMain = statements.whereType<IrFunctionDecl>().any((f) => f.name == 'main');
    if (!hasMain) return IrProgram(statements);
    return IrProgram(<IrStmt>[
      ...statements,
      const IrExprStmt(line: 0, synthetic: true, expr: IrCall(line: 0, synthetic: true, callee: IrIdentifier(line: 0, synthetic: true, name: 'main'), args: <IrExpr>[])),
    ]);
  }

  @override
  IrProgram buildHarness({
    required IrProgram userProgram,
    required String functionName,
    required List<Value> arguments,
    required List<String> preludeSources,
  }) {
    final preludeStatements = <IrStmt>[
      for (final src in preludeSources) ...DartParser().parseProgram(src),
    ];
    final args = <IrExpr>[for (final v in arguments) IrRawValue(line: 0, synthetic: true, value: v)];
    final targetCall = IrReturn(
      line: 0,
      synthetic: true,
      value: IrCall(line: 0, synthetic: true, callee: IrIdentifier(line: 0, synthetic: true, name: functionName), args: args),
    );
    return IrProgram(<IrStmt>[...preludeStatements, ...userProgram.statements, targetCall]);
  }
}
