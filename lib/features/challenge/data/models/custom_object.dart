/// A custom class the user's solution may construct (e.g. `ListNode`,
/// `TreeNode`), as declared in the problem's `custom_objects.dart` list.
///
/// Each entry carries the raw `class` source plus an optional shape hint
/// (`linked_list`, `binary_tree`, `plain_fields`) that tells the grading
/// pipeline how to build the object from an array and how to serialize it
/// back for comparison.
class CustomObject {
  CustomObject({this.code, this.shape});

  /// Accepts both the legacy plain-string form and the newer
  /// `{"code": ..., "shape": ...}` object form.
  factory CustomObject.fromJson(dynamic json) {
    if (json is String) return CustomObject(code: json);
    if (json is Map<String, dynamic>) {
      return CustomObject(
        code: json['code'] as String?,
        shape: json['shape'] as String?,
      );
    }
    return CustomObject();
  }

  final String? code;
  final String? shape;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (code != null) 'code': code,
        if (shape != null) 'shape': shape,
      };

  String get getCode => code ?? '';
  String get getShape => shape ?? '';
}
