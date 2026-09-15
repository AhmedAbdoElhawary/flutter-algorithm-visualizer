/// The complete, and only, per-language surface (contracts/frontend-contract.md).
/// Everything after [LanguageFrontend.parse]/[LanguageFrontend.buildHarness]
/// — the IR, compiler, VM, limits, cancellation, error classification, and
/// canonical normalizer — is shared by every language (FR-031, SC-011).
library;

import '../ir/ir.dart';
import '../values/dialect.dart';
import '../values/value.dart';

/// The single source of truth for what languages exist (FR-032). A full
/// registry (picker, highlighting, starter-code lookup all reading from one
/// place) is Phase 10 (T094) — this enum is the seed of it.
enum EditorLanguage { dart, python, javascript }

abstract class LanguageFrontend {
  EditorLanguage get language;
  Dialect get dialect;

  /// Builtins this language adds on top of the engine's own prelude, layered
  /// over it so that where the two disagree — Python's `min` takes a whole
  /// list, the engine's takes two arguments — this language wins.
  ///
  /// This is part of the per-language surface for the same reason [dialect]
  /// is: the shared runtime must not learn the name of any one language
  /// (FR-031, SC-011), and a language's builtins are exactly the kind of
  /// thing that would otherwise leak into it.
  Map<String, Value> get globals => const <String, Value>{};

  /// Learner source -> shared Core IR. Throws [FrontendFailure] (`syntax` or
  /// `unsupported`) — never a raw Dart error (O3).
  IrProgram parse(String source);

  /// Wraps the learner's code so [functionName] is called with [arguments]
  /// and its return value captured. Every node this generates must be
  /// flagged `synthetic` (O2, FR-017).
  IrProgram buildHarness({
    required IrProgram userProgram,
    required String functionName,
    required List<Value> arguments,
    required List<String> preludeSources,
  });
}
