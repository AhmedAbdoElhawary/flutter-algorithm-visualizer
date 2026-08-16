import 'interpreter.dart';
import 'lexer.dart';
import 'parser.dart';

/// Whether a [RunError] happened while parsing (syntax) or while
/// executing already-parsed code (runtime).
enum RunErrorKind { syntax, runtime }

/// A single failure from [CodeRunner.run], pinned to the 1-indexed source
/// [line] responsible so the editor can highlight it.
class RunError {
  const RunError({
    required this.line,
    required this.message,
    required this.kind,
  });

  final int line;
  final String message;
  final RunErrorKind kind;

  @override
  String toString() => '${kind.name} error (line $line): $message';
}

/// The outcome of running a snippet: everything printed, in order, plus
/// an [error] if execution didn't finish successfully.
///
/// [stdout] may be non-empty even when [error] is set — output produced
/// before a runtime error is still returned, which is usually exactly
/// what you want for debugging ("it printed these 3 things, then blew up
/// on line 12").
class RunResult {
  const RunResult({required this.stdout, this.error, this.rawOutput = const <dynamic>[]});

  final List<String> stdout;
  final RunError? error;

  /// The raw evaluated value of each `print(...)` argument, parallel to
  /// [stdout]. Used by the problem runner to grade real values (e.g.
  /// [ObjectInstance]s) rather than their stringified forms.
  final List<dynamic> rawOutput;

  bool get success => error == null;
}

/// A pluggable "run this code" hook, mirroring `CodeFormatter`'s design:
/// the editor core has no built-in opinion about how/whether code gets
/// executed. Attach a [CodeRunner] to [CodeController.runner] to enable
/// `controller.execute()`.
abstract class CodeRunner {
  const CodeRunner();

  RunResult run(String source);
}

/// Executes a deliberately limited subset of Dart entirely on-device —
/// no `dart:mirrors`, no external process, no network call.
///
/// This is **not** a full Dart VM. There's no real Dart SDK you can
/// bundle and `exec()` from inside a mobile app (iOS forbids spawning
/// processes; Android could in theory, but shipping the whole SDK
/// contradicts "lightweight"). Instead, `execution/` implements a small
/// hand-written lexer → parser → tree-walking interpreter covering:
/// top-level functions, local variables, `if`/`while`/`for`/`for-in`,
/// `return`/`break`/`continue`, arithmetic/logical/comparison operators,
/// list literals & indexing, `.length`, basic `List`/`String` methods,
/// string interpolation, and `print()`.
///
/// Not supported: methods, `async`/`await`, imports, sets, full generics,
/// most of `dart:core`. Code using those fails with a normal
/// [RunError] rather than crashing the app.
class DartInterpreterRunner extends CodeRunner {
  const DartInterpreterRunner({this.maxSteps = 2000000});

  /// Passed straight through to [Interpreter] as its infinite-loop guard.
  final int maxSteps;

  @override
  RunResult run(String source) {
    Interpreter? interpreter;
    try {
      final tokens = Lexer(source).tokenize();
      final program = Parser(tokens).parseProgram();
      interpreter = Interpreter(maxSteps: maxSteps);
      interpreter.run(program);
      return RunResult(stdout: interpreter.output, rawOutput: interpreter.rawOutput);
    } on LexError catch (e) {
      return RunResult(
        stdout: const <String>[],
        error: RunError(line: e.line, message: e.message, kind: RunErrorKind.syntax),
      );
    } on ParseError catch (e) {
      return RunResult(
        stdout: const <String>[],
        error: RunError(line: e.line, message: e.message, kind: RunErrorKind.syntax),
      );
    } on InterpreterError catch (e) {
      return RunResult(
        stdout: interpreter?.output ?? const <String>[],
        error: RunError(line: e.line, message: e.message, kind: RunErrorKind.runtime),
      );
    } on StackOverflowError {
      return RunResult(
        stdout: interpreter?.output ?? const <String>[],
        error: const RunError(
          line: 1,
          message: 'Stack overflow (possible infinite recursion)',
          kind: RunErrorKind.runtime,
        ),
      );
    } catch (e) {
      return RunResult(
        stdout: interpreter?.output ?? const <String>[],
        error: RunError(line: 1, message: 'Unexpected error: $e', kind: RunErrorKind.runtime),
      );
    }
  }
}
