part of 'user_provider.dart';

/// make it simple and didn't use clean architecture layers, just simple MVVM
const _profileNameKey = 'profile_name';
const defaultName = StringsManager.anonymous;

final profileStorageInstanceProvider = Provider<ProfileStorage>((ref) {
  return GetProfileStorage(GetStorageService(GetStorage()));
});

abstract class ProfileStorage {
  String getProfileName();
  Future<void> saveProfileName(String name);
}

class GetProfileStorage implements ProfileStorage {
  GetProfileStorage(this._storage);

  final GetStorageService _storage;

  @override
  String getProfileName() => _storage.read<String>(_profileNameKey) ?? defaultName;

  @override
  Future<void> saveProfileName(String name) => _storage.write(_profileNameKey, name);
}
