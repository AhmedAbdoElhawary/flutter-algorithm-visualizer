/// How a custom object (e.g. `ListNode`) is constructed from / serialized to
/// the flat list form used in test-case inputs and expected outputs.
enum CustomObjectShape {
  /// A singly-linked chain: an array `[1, 2, 4]` builds `1 -> 2 -> 4`.
  /// The value field is [valueField] and the link field is [nextField]
  /// (both default to LeetCode's `val` / `next`).
  linkedList('linked_list', valueField: 'val', nextField: 'next'),

  /// A binary tree: a level-order array `[1, 2, 3, 4, 5]` builds the tree
  /// left-to-right per level (`null` entries mark missing children).
  binaryTree('binary_tree', leftField: 'left', rightField: 'right'),

  /// A plain object: built by passing the array elements as positional
  /// constructor arguments in order.
  plainFields('plain_fields');

  const CustomObjectShape(
    this.key, {
    this.valueField = 'val',
    this.nextField = 'next',
    this.leftField = 'left',
    this.rightField = 'right',
  });

  /// The string key used in the problem's `custom_objects` metadata.
  final String key;

  final String valueField;
  final String nextField;
  final String leftField;
  final String rightField;

  static CustomObjectShape? fromKey(String? key) {
    if (key == null) return null;
    for (final shape in values) {
      if (shape.key == key) return shape;
    }
    return null;
  }
}
