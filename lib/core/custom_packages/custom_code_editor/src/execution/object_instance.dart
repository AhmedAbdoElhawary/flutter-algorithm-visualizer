/// A runtime instance of an interpreted custom class (e.g. `ListNode` or
/// `TreeNode`), created when the interpreter evaluates a constructor call
/// like `ListNode(1, ListNode(2))`.
///
/// Fields are plain Dart values (ints, strings, `List<dynamic>`, nested
/// [ObjectInstance]s, `null`), which lets the shape-aware serializers walk
/// an instance graph to produce canonical output for grading.
class ObjectInstance {
  ObjectInstance(this.type, this.fields, [this.methods = const <String, ObjectInstanceMethod>{}]);

  final String type;
  final Map<String, dynamic> fields;
  final Map<String, ObjectInstanceMethod> methods;

  @override
  String toString() => '$type(${_format(fields, 0)})';

  static String _format(Map<String, dynamic> fields, int depth) {
    final parts = fields.entries.map((e) => '${e.key}: ${_fmtValue(e.value, depth)}').toList(growable: false);
    return parts.join(', ');
  }

  static String _fmtValue(dynamic v, int depth) {
    if (depth > 4) return '...';
    if (v is ObjectInstance) return '${v.type}(...)';
    if (v is List) {
      return '[${v.map((e) => _fmtValue(e, depth + 1)).join(', ')}]';
    }
    if (v is Map) {
      return '{${v.entries.map((e) => '${e.key}: ${_fmtValue(e.value, depth + 1)}').join(', ')}}';
    }
    return '$v';
  }
}

/// A bound method on an [ObjectInstance]: the method body plus a
/// reference to the instance it belongs to, so the interpreter can
/// set up `this` when the method is called.
class ObjectInstanceMethod {
  const ObjectInstanceMethod(this.decl, this.instance);

  final dynamic decl; // FunctionDecl (imported from ast.dart to avoid circular deps)
  final ObjectInstance instance;
}
