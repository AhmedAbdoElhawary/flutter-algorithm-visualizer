extension StringX on String {
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match.group(1)}_${match.group(2)}',
    ).toLowerCase();
  }

  /// `Two Sum` + `py` → `two_sum.py`, shortened a word at a time to stay a tab-sized label.
  String toFileName(String extension) {
    final snakeCase = toSnakeCase.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
    final parts = snakeCase.split('_');
    while (parts.join('_').length >= 20 && parts.length > 1) {
      parts.removeLast();
    }
    return "${parts.join('_')}.$extension";
  }
}
