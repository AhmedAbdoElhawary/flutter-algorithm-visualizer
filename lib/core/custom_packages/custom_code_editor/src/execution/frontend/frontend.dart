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
