/// The actual "parse -> compile -> run" pipeline, shared by both drivers
/// ([IsolateExecutionEngine] runs this inside a spawned isolate,
/// [SlicedExecutionEngine] runs it directly). Isolates share compiled code
/// but not memory, so this dispatch table is rebuilt independently in each
/// isolate via [registerAllFrontends] rather than through any shared mutable
/// registry — see `frontend/language_registry.dart` (T094) for the version
/// of this every consumer eventually reads from.
library;

import 'dart:collection';

import '../compile/compiler.dart';
import '../errors/failure.dart';
import '../frontend/dart/dart_harness.dart';
import '../frontend/frontend.dart';
import '../ir/ir.dart';
import '../values/dialect.dart';
import '../values/value.dart';
import '../vm/budget.dart';
import '../vm/vm.dart';

final Map<EditorLanguage, LanguageFrontend> _frontends = <EditorLanguage, LanguageFrontend>{};
var _registered = false;

/// Populated as each language frontend lands (Dart now, Python in Phase 7,
/// JavaScript in Phase 8). Safe to call more than once — [executeEncodedRequest]
/// calls it before every request so a fresh isolate is always ready.
void registerAllFrontends() {
  if (_registered) return;
  _registered = true;
  registerFrontend(DartFrontend());
}

void registerFrontend(LanguageFrontend frontend) => _frontends[frontend.language] = frontend;

/// A magic, never-naturally-occurring source string that lets Phase 2's
/// engine-plumbing tests (cancellation, limits, the isolate protocol itself)
/// exercise a real run without needing a language frontend to exist yet.
/// Harmless to leave in place once frontends land — no real learner source
/// will ever equal one of these sentinels.
const String stubInfiniteLoopSource = '<<engine-test:infinite-loop>>';
const String stubReturnConstantSource = '<<engine-test:return-42>>';

IrProgram? _stubProgram(String source) {
  switch (source) {
    case stubInfiniteLoopSource:
      return const IrProgram(<IrStmt>[
        IrWhile(line: 1, condition: IrLiteral(line: 1, kind: IrLiteralKind.boolLit, value: true), body: IrBlock(line: 1, statements: <IrStmt>[])),
      ]);
    case stubReturnConstantSource:
      return const IrProgram(<IrStmt>[IrReturn(line: 1, value: IrLiteral(line: 1, kind: IrLiteralKind.intLit, value: 42))]);
    default:
      return null;
  }
}

const Dialect _stubDialect = Dialect(
  intDivisionYields: IntDivisionMode.alwaysDouble,
  truthiness: TruthinessMode.boolOnly,
  equalityCoerces: false,
  defaultSortOrder: SortOrder.natural,
  hasUndefined: false,
  printsTrueAs: 'true',
  printsFalseAs: 'false',
  stringIndexYields: StringIndexResult.codeUnit,
  arbitraryPrecisionInts: false,
  negativeIndexing: false,
);

/// Runs one request end to end and returns a wire-encoded outcome. Never
/// throws — every failure path is captured and encoded.
Map<String, Object?> executeEncodedRequest(Map<String, Object?> encoded, bool Function() isCancelled) {
  registerAllFrontends();
  final stopwatch = Stopwatch()..start();
  try {
    final language = EditorLanguage.values.byName(encoded['language']! as String);
    final source = encoded['source']! as String;
    final functionName = encoded['functionName']! as String;
    final arguments = (encoded['arguments']! as List<Object?>).map(decodeValue).toList();
    final preludeSources = (encoded['preludeSources']! as List<Object?>).cast<String>();
    final budget = _decodeBudget(encoded['budget']! as Map<String, Object?>);

    IrProgram program;
    Dialect dialect;
    final stub = _stubProgram(source);
    if (stub != null) {
      program = stub;
      dialect = _stubDialect;
    } else {
      final frontend = _frontends[language];
      if (frontend == null) {
        return _encodeOutcome(
          const VmResult(failure: Failure(kind: FailureKind.unsupported, code: 'unsupportedConstruct', data: {'construct': 'this language'}, line: 0)),
          stopwatch.elapsed,
        );
      }
      dialect = frontend.dialect;
      final userProgram = frontend.parse(source);
      program = frontend.buildHarness(
        userProgram: userProgram,
        functionName: functionName,
        arguments: arguments,
        preludeSources: preludeSources,
      );
    }

    final script = Compiler().compileProgram(program);
    final vm = Vm(dialect: dialect, budget: budget, isCancelled: isCancelled);
    final result = vm.run(script, timeout: budget.perTestCaseTimeout);
    return _encodeOutcome(result, stopwatch.elapsed);
  } on FrontendFailure catch (e) {
    return _encodeOutcome(VmResult(failure: e.toFailure()), stopwatch.elapsed);
  } catch (e) {
    return _encodeOutcome(
      VmResult(failure: Failure(kind: FailureKind.runtime, code: 'uncaughtThrow', data: <String, Object?>{'message': e.toString()}, line: 0)),
      stopwatch.elapsed,
    );
  }
}

ExecutionBudget _decodeBudget(Map<String, Object?> m) => ExecutionBudget(
      perTestCaseTimeout: Duration(microseconds: m['perTestCaseTimeoutUs']! as int),
      perRunTimeout: Duration(microseconds: m['perRunTimeoutUs']! as int),
      maxFrameDepth: m['maxFrameDepth']! as int,
      maxHeapValues: m['maxHeapValues']! as int,
      maxCollectionLength: m['maxCollectionLength']! as int,
      maxOutputEntries: m['maxOutputEntries']! as int,
      maxOutputChars: m['maxOutputChars']! as int,
      instructionsPerBudgetCheck: m['instructionsPerBudgetCheck']! as int,
    );

Map<String, Object?> encodeBudget(ExecutionBudget b) => <String, Object?>{
      'perTestCaseTimeoutUs': b.perTestCaseTimeout.inMicroseconds,
      'perRunTimeoutUs': b.perRunTimeout.inMicroseconds,
      'maxFrameDepth': b.maxFrameDepth,
      'maxHeapValues': b.maxHeapValues,
      'maxCollectionLength': b.maxCollectionLength,
      'maxOutputEntries': b.maxOutputEntries,
      'maxOutputChars': b.maxOutputChars,
      'instructionsPerBudgetCheck': b.instructionsPerBudgetCheck,
    };

Map<String, Object?> _encodeOutcome(VmResult result, Duration elapsed) => <String, Object?>{
      'returned': result.returned == null ? null : encodeValue(result.returned!),
      'stdout': result.stdout,
      'truncated': result.truncated,
      'failure': result.failure == null
          ? null
          : <String, Object?>{
              'kind': result.failure!.kind.name,
              'code': result.failure!.code,
              'data': result.failure!.data,
              'line': result.failure!.line,
              'partialOutput': result.failure!.partialOutput,
            },
      'elapsedUs': elapsed.inMicroseconds,
    };

/// A plain-Dart (isolate-message-safe) encoding of a [Value]: primitives,
/// `List`, and `Map` only. Functions/classes/instances never cross this
/// boundary as *arguments* or *results* in the current problem-bank shape
/// (test-case data is always structural), so they are not represented here.
Object? encodeValue(Value v) {
  if (v is IntValue) return <String, Object?>{'k': 'int', 'v': v.value};
  if (v is NumValue) return <String, Object?>{'k': 'num', 'v': v.value};
  if (v is BoolValue) return <String, Object?>{'k': 'bool', 'v': v.value};
  if (v is StrValue) return <String, Object?>{'k': 'str', 'v': v.value};
  if (v is NullValue) return <String, Object?>{'k': 'null'};
  if (v is UndefinedValue) return <String, Object?>{'k': 'undefined'};
  if (v is ListValue) return <String, Object?>{'k': 'list', 'v': v.items.map(encodeValue).toList()};
  if (v is TupleValue) return <String, Object?>{'k': 'tuple', 'v': v.items.map(encodeValue).toList()};
  if (v is SetValue) return <String, Object?>{'k': 'set', 'v': v.items.map(encodeValue).toList()};
  if (v is MapValue) {
    return <String, Object?>{
      'k': 'map',
      'v': v.entries.entries.map((e) => <String, Object?>{'key': encodeValue(e.key), 'value': encodeValue(e.value)}).toList(),
    };
  }
  if (v is InstanceValue) {
    return <String, Object?>{
      'k': 'instance',
      'class': v.klass.name,
      'fields': v.fields.map((key, value) => MapEntry(key, encodeValue(value))),
    };
  }
  throw ArgumentError('$v cannot cross the isolate boundary');
}

Value decodeValue(Object? encoded) {
  if (encoded == null) return NullValue.instance;
  final m = encoded as Map<Object?, Object?>;
  switch (m['k']) {
    case 'int':
      return IntValue(m['v']! as int);
    case 'num':
      return NumValue(m['v']! as double);
    case 'bool':
      return BoolValue(m['v']! as bool);
    case 'str':
      return StrValue(m['v']! as String);
    case 'null':
      return NullValue.instance;
    case 'undefined':
      return UndefinedValue.instance;
    case 'list':
      return ListValue((m['v']! as List<Object?>).map(decodeValue).toList());
    case 'tuple':
      return TupleValue((m['v']! as List<Object?>).map(decodeValue).toList());
    case 'set':
      return SetValue(LinkedHashSet<Value>.of((m['v']! as List<Object?>).map(decodeValue)));
    case 'map':
      final mv = MapValue();
      for (final pair in m['v']! as List<Object?>) {
        final p = pair as Map<Object?, Object?>;
        mv.entries[decodeValue(p['key'])] = decodeValue(p['value']);
      }
      return mv;
    default:
      throw ArgumentError('cannot decode wire value: $encoded');
  }
}
