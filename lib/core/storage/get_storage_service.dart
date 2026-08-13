import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:get_storage/get_storage.dart';

final class GetStorageService implements LocalStorage {
  GetStorageService(this._storage);

  final GetStorage _storage;

  @override
  Future<void> write<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  @override
  T? read<T>(String key) {
    return _storage.read<T>(key);
  }

  @override
  Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    await _storage.erase();
  }

  @override
  bool has(String key) {
    return _storage.hasData(key);
  }
}