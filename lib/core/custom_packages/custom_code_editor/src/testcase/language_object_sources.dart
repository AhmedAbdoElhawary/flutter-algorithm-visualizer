/// The `ListNode` / `TreeNode` / `Node` class a problem's custom objects need,
/// written in the language the learner is solving in.
///
/// The dataset stores only the Dart definition (`custom_objects.dart`), which
/// is the one the Dart path prepends verbatim. Python and JavaScript need the
/// same class in their own syntax before a learner can write `ListNode(1)`,
/// and the shape metadata already says exactly what the class holds — so the
/// definition is derived from the shape rather than stored three times.
library;

import '../execution/frontend/frontend.dart';
import 'custom_object_shape.dart';

/// The class [className] in [language], shaped by [shape]. Null for Dart,
/// which uses the dataset's own source.
String? customObjectSource(EditorLanguage language, String className, CustomObjectShape shape) {
  return switch (language) {
    EditorLanguage.dart => null,
    EditorLanguage.python => _python(className, shape),
    EditorLanguage.javascript => _javascript(className, shape),
  };
}

String _python(String className, CustomObjectShape shape) {
  final fields = _fieldsOf(shape);
  final params = <String>['self', for (final f in fields) '${f.name}=${_pythonDefault(f)}'];
  final body = <String>[for (final f in fields) '        self.${f.name} = ${f.name}'];
  return 'class $className:\n'
      '    def __init__(${params.join(', ')}):\n'
      '${body.join('\n')}\n';
}

String _javascript(String className, CustomObjectShape shape) {
  final fields = _fieldsOf(shape);
  final params = <String>[for (final f in fields) '${f.name} = ${_javascriptDefault(f)}'];
  final body = <String>[for (final f in fields) '    this.${f.name} = ${f.name}'];
  return 'class $className {\n'
      '  constructor(${params.join(', ')}) {\n'
      '${body.join('\n')}\n'
      '  }\n'
      '}\n';
}

/// One field of the node class: its name, and whether it holds a value, a
/// link to another node, or a list of them.
typedef _Field = ({String name, _FieldKind kind});

enum _FieldKind { value, link, links }

List<_Field> _fieldsOf(CustomObjectShape shape) => switch (shape) {
      CustomObjectShape.linkedList => <_Field>[
          (name: shape.valueField, kind: _FieldKind.value),
          (name: shape.nextField, kind: _FieldKind.link),
        ],
      CustomObjectShape.binaryTree => <_Field>[
          (name: shape.valueField, kind: _FieldKind.value),
          (name: shape.leftField, kind: _FieldKind.link),
          (name: shape.rightField, kind: _FieldKind.link),
        ],
      CustomObjectShape.plainFields => <_Field>[
          (name: shape.valueField, kind: _FieldKind.value),
          (name: 'neighbors', kind: _FieldKind.links),
        ],
    };

String _pythonDefault(_Field field) => switch (field.kind) {
      _FieldKind.value => '0',
      _FieldKind.link => 'None',
      _FieldKind.links => 'None',
    };

String _javascriptDefault(_Field field) => switch (field.kind) {
      _FieldKind.value => '0',
      _FieldKind.link => 'null',
      _FieldKind.links => '[]',
    };
