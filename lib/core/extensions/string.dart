extension StringX on String {
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match.group(1)}_${match.group(2)}',
    ).toLowerCase();
  }

}
