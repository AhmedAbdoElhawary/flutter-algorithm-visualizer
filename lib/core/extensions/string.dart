import 'package:algorithm_visualizer/core/resources/strings_manager.dart';

extension StringX on String {
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match.group(1)}_${match.group(2)}',
    ).toLowerCase();
  }
  String get getNameWithLanguageName {
    final snakeCase = toSnakeCase.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
    final parts = snakeCase.split('_');
    while (parts.join('_').length >= 20 && parts.length > 1) {
      parts.removeLast();
    }
    return "${parts.join('_')}.${StringsManager.dart.toLowerCase()}";
  }
}
