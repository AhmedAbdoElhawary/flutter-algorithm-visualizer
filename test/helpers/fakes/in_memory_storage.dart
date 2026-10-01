import 'package:algorithm_visualizer/core/storage/storage.dart';

/// Stands in for both `GetStorage` containers, so no test touches the disk.
class InMemoryStorage implements LocalStorage {
  InMemoryStorage([Map<String, Object?>? seed]) : _values = {...?seed};

  final Map<String, Object?> _values;

  @override
  Future<void> write<T>(String key, T value) async => _values[key] = value;

  @override
  T? read<T>(String key) => _values[key] as T?;

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  bool has(String key) => _values.containsKey(key);
}
