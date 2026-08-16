// /// Abstraction over "whatever actually executes the user's source code".
// ///
// /// The concrete implementation wraps the on-device execution engine that
// /// lives inside `CodeController` (from the `custom_code_editor` package).
// /// Because that controller is created by the editor widget itself, the
// /// implementation exposes a way to attach it once it becomes available
// /// (see `CodeControllerRunnerRepository.attachController`).
// abstract class CodeRunnerRepository {
//   Future<String> runCode(String sourceCode);
// }
