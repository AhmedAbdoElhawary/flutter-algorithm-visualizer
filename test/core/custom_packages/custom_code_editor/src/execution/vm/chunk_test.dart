import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/chunk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bytes, lines and synthetic marks line up', () {
    final builder = ChunkBuilder();

    builder.emitOp(OpCode.nullLit, line: 1);
    builder.emitOp(OpCode.pop, line: 2, synthetic: true);
    final chunk = builder.build();

    expect(chunk.code, [OpCode.nullLit, OpCode.pop]);
    expect(chunk.lines, [1, 2]);
    expect(chunk.synthetic, [0, 1]);
  });

  test('a u16 is written high byte first', () {
    final builder = ChunkBuilder()..emitU16(0x1234, line: 1);

    expect(builder.build().code, [0x12, 0x34]);
  });

  test('a jump is written with a placeholder, then patched to its target', () {
    final builder = ChunkBuilder();
    final at = builder.emitJump(OpCode.pop, line: 1);
    expect(builder.offset, 3);

    builder.patchU16At(at, 513);

    expect(builder.build().code, [OpCode.pop, 2, 1]);
  });

  test('constants get their own index', () {
    final builder = ChunkBuilder();

    expect(builder.addConstant(const IntValue(1)), 0);
    expect(builder.addConstant(const StrValue('a')), 1);
    expect(builder.build().constants, hasLength(2));
  });

  test('a function takes its minimum arity from its arity unless told', () {
    final chunk = ChunkBuilder().build();

    expect(FunctionProto(name: 'f', arity: 2, chunk: chunk).minArity, 2);
    expect(FunctionProto(name: 'f', arity: 2, minArity: 1, chunk: chunk).minArity, 1);
  });

  test('a chunk built by hand marks nothing synthetic', () {
    final built = ChunkBuilder().build();

    final chunk = BytecodeChunk(code: built.code, constants: const [], lines: built.lines);

    expect(chunk.synthetic, isEmpty);
  });
}
