/// Bytecode chunk shape. See
/// `specs/007-multi-language-interpreter/data-model.md` §6.
///
/// One deviation from the literal data-model shape, noted for anyone
/// cross-referencing it: each [FunctionProto] owns its own [BytecodeChunk]
/// (the "clox" model) rather than all functions sharing one chunk with a
/// separate `functions` list. Nested function bodies are referenced as
/// constants (`FunctionProto` values) in the enclosing chunk's constant
/// pool. This is simpler to compile correctly and is functionally
/// equivalent — jump targets never need to cross a function boundary either
/// way.
library;

import 'dart:typed_data';

import '../values/value.dart';

/// Single-byte opcodes. Multi-byte operands (constant/local/upvalue indices,
/// jump targets) are 16-bit big-endian; `CALL`'s argument count is 8-bit.
abstract final class OpCode {
  static const int constant = 0; // u16 constant index
  static const int nullLit = 1;
  static const int trueLit = 2;
  static const int falseLit = 3;
  static const int pop = 4;
  static const int dup = 5;

  static const int getLocal = 6; // u16 slot
  static const int setLocal = 7; // u16 slot
  static const int getUpvalue = 8; // u16 index
  static const int setUpvalue = 9; // u16 index
  static const int getGlobal = 10; // u16 name-constant index
  static const int setGlobal = 11; // u16 name-constant index
  static const int defineGlobal = 12; // u16 name-constant index

  static const int getProperty = 13; // u16 name-constant index
  static const int setProperty = 14; // u16 name-constant index
  static const int getIndex = 15;
  static const int setIndex = 16;
  static const int slice = 17; // u8 flags: bit0 hasStart, bit1 hasEnd, bit2 hasStep

  static const int equal = 18;
  static const int notEqual = 19;
  static const int greater = 20;
  static const int greaterEqual = 21;
  static const int less = 22;
  static const int lessEqual = 23;
  static const int add = 24;
  static const int subtract = 25;
  static const int multiply = 26;
  static const int divide = 27;
  static const int floorDivide = 28; // Python `//` — mathematical floor
  static const int truncDivide = 29; // Dart `~/` — truncation toward zero
  static const int modulo = 30;
  static const int negate = 31;
  static const int not = 32;
  static const int stringify = 33; // dialect-aware Value -> StrValue, for interpolation
  static const int buildString = 34; // u16 count; concatenates count StrValues into one

  static const int jump = 35; // u16 absolute target
  static const int jumpIfFalse = 36; // u16 absolute target; pops
  static const int jumpIfTrue = 37; // u16 absolute target; pops

  static const int buildList = 38; // u16 count
  static const int buildTuple = 39; // u16 count
  static const int buildMap = 40; // u16 count (key/value pairs)
  static const int buildSet = 41; // u16 count

  static const int call = 42; // u8 argCount

  /// u16 index of a prototype-carrier `FunctionValue` constant (its `chunk`
  /// field is the real `FunctionProto`, which already carries its own
  /// `upvalues` descriptor list — nothing else follows in the bytecode).
  static const int closure = 43;
  static const int ret = 44;
  static const int print = 45;

  /// u16 name-constant index, u8 hasSuperclass. When set, the superclass
  /// `ClassValue` must already be on the stack (pushed by a preceding
  /// `GET_GLOBAL`/`GET_LOCAL`/... for its name).
  static const int classDecl = 46;

  /// Pops a method closure, peeks the `ClassValue` beneath it, and adds the
  /// method under the given name (u16 name-constant index).
  static const int method = 47;

  static const int superCall = 48; // u16 name-constant index, u8 argCount

  static const int throwOp = 49;

  /// Pops a value and appends it to the list beneath it, which stays on the
  /// stack. Together with [extendAll] this is how a literal or argument list
  /// containing a spread (`[...a, b]`, `f(...a, b)`) is built: its final
  /// length is not known until runtime, so it cannot be a [buildList] operand.
  static const int appendOne = 50;

  /// Pops an iterable and appends every element of it to the list beneath it,
  /// which stays on the stack.
  static const int extendAll = 51;

  /// Pops an argument list and then the callee, and calls the callee with
  /// exactly those arguments — the spread-aware counterpart of [call].
  static const int callSpread = 52;

  /// Python's and JavaScript's `**`.
  static const int power = 53;

  /// Pops an index and an iterable and pushes the element at that position in
  /// *iteration* order. Distinct from [getIndex] because the two genuinely
  /// disagree on a map: `d[k]` looks a key up, while `for k in d` walks the
  /// keys by position.
  static const int iterElement = 54;
}

class UpvalueDescriptor {
  const UpvalueDescriptor({required this.isLocal, required this.index});

  /// True: capture the *current* frame's local at [index]. False: capture
  /// the *current* frame's own upvalue at [index] (chained capture).
  final bool isLocal;
  final int index;
}

/// A `try` region: while `ip` is within `[startPc, endPc)`, a thrown error
/// jumps to `catchPc`, landing with the thrown value pushed on the stack.
/// A `try` with no `catch` clause still gets a compiler-synthesized landing
/// pad that runs the `finally` block and rethrows (see `compile/compiler.dart`
/// `_compileTry`), so `catchPc` is always present once a handler is
/// registered at all.
class ExceptionHandler {
  const ExceptionHandler({required this.startPc, required this.endPc, required this.catchPc});
  final int startPc;
  final int endPc;
  final int catchPc;
}

class FunctionProto {
  FunctionProto({
    required this.name,
    required this.arity,
    int? minArity,
    required this.chunk,
    this.upvalues = const <UpvalueDescriptor>[],
    this.exceptionTable = const <ExceptionHandler>[],
    this.maxLocals = 0,
  }) : minArity = minArity ?? arity;

  final String name;

  /// Total parameter count (required + optional).
  final int arity;

  /// Minimum argument count the caller must supply; optional trailing
  /// parameters (`ListNode([this.val = 0, this.next])`) fall in
  /// `[minArity, arity)`. Their default-value expressions are compiled as a
  /// prologue inside the function body itself (`if (param == null) param =
  /// `), so the VM's call protocol only needs this range check —
  /// see `compile/compiler.dart`'s `_compileFunction`.
  final int minArity;

  final BytecodeChunk chunk;
  final List<UpvalueDescriptor> upvalues;
  final List<ExceptionHandler> exceptionTable;
  final int maxLocals;
}

class BytecodeChunk {
  BytecodeChunk({required this.code, required this.constants, required this.lines, Uint8List? synthetic})
      : synthetic = synthetic ?? Uint8List(code.length);

  /// Instruction stream.
  final Uint8List code;

  /// Deduplicated constant pool: literals and nested [FunctionProto]s.
  final List<Value> constants;

  /// Indexed by byte offset of an opcode: the learner-source line that
  /// opcode originated from.
  final Int32List lines;

  /// Bitmap (one byte per code byte, 1 or 0) marking harness-generated
  /// instructions, excluded from line reporting to the learner.
  final Uint8List synthetic;
}

/// Growable emitter the compiler uses to build a [BytecodeChunk]; not part
/// of the immutable runtime shape.
class ChunkBuilder {
  final List<int> _code = <int>[];
  final List<int> _lines = <int>[];
  final List<int> _synthetic = <int>[];
  final List<Value> constants = <Value>[];

  int get offset => _code.length;

  int emitByte(int byte, {required int line, bool synthetic = false}) {
    final at = _code.length;
    _code.add(byte & 0xFF);
    _lines.add(line);
    _synthetic.add(synthetic ? 1 : 0);
    return at;
  }

  void emitU16(int value, {required int line, bool synthetic = false}) {
    emitByte((value >> 8) & 0xFF, line: line, synthetic: synthetic);
    emitByte(value & 0xFF, line: line, synthetic: synthetic);
  }

  int emitOp(int op, {required int line, bool synthetic = false}) =>
      emitByte(op, line: line, synthetic: synthetic);

  /// Emits [op] followed by a placeholder u16 target, returning the byte
  /// offset of the placeholder's first byte for later [patchU16At].
  int emitJump(int op, {required int line, bool synthetic = false}) {
    emitOp(op, line: line, synthetic: synthetic);
    final at = offset;
    emitU16(0xFFFF, line: line, synthetic: synthetic);
    return at;
  }

  void patchU16At(int at, int value) {
    _code[at] = (value >> 8) & 0xFF;
    _code[at + 1] = value & 0xFF;
  }

  int addConstant(Value value) {
    constants.add(value);
    return constants.length - 1;
  }

  BytecodeChunk build() {
    return BytecodeChunk(
      code: Uint8List.fromList(_code),
      constants: constants,
      lines: Int32List.fromList(_lines),
      synthetic: Uint8List.fromList(_synthetic),
    );
  }
}
