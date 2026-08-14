abstract interface class LocalStorage {
  Future<void> write<T>(String key, T value);

  T? read<T>(String key);

  Future<void> remove(String key);

  Future<void> clear();

  bool has(String key);
}