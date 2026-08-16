// import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/editor/code_controller.dart';
// import 'package:algorithm_visualizer/features/challange/challange/domain/repositories/code_runner_repository.dart';
//
// /// Wraps the `CodeController` that the on-screen editor widget creates.
// ///
// /// The controller isn't available until `CodeEditorBlock` builds and hands
// /// it back through its `controllerCallback`, so instead of injecting it at
// /// construction time it's attached later via [attachController].
// ///
// /// `runCode`'s `sourceCode` param is intentionally unused here — the
// /// attached controller already executes its own current text via
// /// `execute()`. It's kept on the interface so a fake/in-memory
// /// implementation (for unit tests) can use it directly.
// class CodeControllerRunnerRepository implements CodeRunnerRepository {
//   CodeController? _controller;
//
//   void attachController(CodeController controller) {
//     _controller = controller;
//   }
//
//   @override
//   Future<String> runCode(String sourceCode) async {
//     final controller = _controller;
//     if (controller == null) {
//       throw StateError(
//         'CodeControllerRunnerRepository: no CodeController attached yet.',
//       );
//     }
//     final result = controller.execute();
//     return result.stdout.join('\n');
//   }
// }
