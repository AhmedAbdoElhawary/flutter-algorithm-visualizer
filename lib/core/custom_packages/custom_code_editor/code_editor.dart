/// A lightweight, mobile-first code editor widget for Flutter.
///
/// This package deliberately does **not** attempt to be an IDE: no
/// IntelliSense, no LSP, no diagnostics, no file explorer, no terminal.
/// It provides exactly the essentials — editable text, syntax
/// highlighting, smart indentation, smart spacing, automatic bracket
/// pairing, optional formatting, and line numbers — with a Flutter-SDK
/// only footprint.
library;

// Editor
export 'src/editor/code_controller.dart';
export 'src/editor/code_document.dart';
export 'src/editor/code_editor.dart';

// Models
export 'src/models/code_editor_config.dart';
export 'src/models/code_editor_theme.dart';

// Syntax
export 'src/syntax/dart/dart_highlighter.dart';
export 'src/syntax/python/python_highlighter.dart';
export 'src/syntax/syntax_highlighter.dart';
export 'src/syntax/token.dart';
export 'src/syntax/token_type.dart';
export 'src/syntax/tokenizer.dart';

// Formatting
export 'src/formatting/formatter.dart';

// Execution ("run this code" support)
export 'src/execution/ast.dart';
export 'src/execution/interpreter.dart';
export 'src/execution/lexer.dart';
export 'src/execution/parser.dart';
export 'src/execution/runner.dart';

// Widgets
export 'src/widgets/line_numbers.dart';

// Utils (exposed for advanced/custom-language use cases and testing)
export 'src/utils/bracket_utils.dart';
export 'src/utils/indentation.dart';
