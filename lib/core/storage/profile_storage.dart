import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

const _profileNameKey = 'profile_name';
const _defaultName = 'Alex Chen';

final profileStorageProvider = Provider<ProfileStorage>((ref) {
  return ProfileStorage(GetStorageService(GetStorage()));
});

class ProfileStorage {
  ProfileStorage(this._storage);

  final LocalStorage _storage;

  String getProfileName() => _storage.read<String>(_profileNameKey) ?? _defaultName;

  Future<void> saveProfileName(String name) => _storage.write(_profileNameKey, name);
}
