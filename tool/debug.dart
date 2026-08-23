import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/interpreter.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/lexer.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/parser.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/testcase/function_signature.dart';
import 'package:flutter/foundation.dart' show debugPrint;

void main() {
  const signature = 'List<int> twoSum(List<int> nums, int target)';
  const userCode = '''
List<int> twoSum(List<int> nums, int target) {
  final seen = <int, int>{};
  for (int i = 0; i < nums.length; i++) {
    final comp = target - nums[i];
    if (seen.containsKey(comp)) return [seen[comp], i];
    seen[nums[i]] = i;
  }
  return [];
}
''';
  final sig = parseFunctionSignature(signature);
  debugPrint('NAME=${sig.name} RETURN=${sig.returnType}');
  debugPrint('PARAMS=${sig.params.map((p) => "${p.name}:${p.type}").toList()}');
  final program =
      '$userCode\n\nvoid main() {\n  final nums = [2,7,11,15];\n  final target = 9;\n  final result = ${sig.name}(nums, target);\n  print(result);\n}\n';
  debugPrint('--- PROGRAM ---');
  debugPrint(program);
  try {
    final tokens = Lexer(program).tokenize();
    final parsed = Parser(tokens).parseProgram();
    debugPrint('functions: ${parsed.functions.map((f) => f.name).toList()}');
    final interp = Interpreter();
    interp.run(parsed);
    debugPrint('OUTPUT: ${interp.output}');
  } catch (e) {
    debugPrint('ERROR: $e');
  }
}
