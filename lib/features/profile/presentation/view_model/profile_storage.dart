part of'user_provider.dart';

/// make it simple and didn't use clean architecture layers, just simple MVVM
const _profileNameKey = 'profile_name';
const _defaultName = StringsManager.anonymous;

final profileStorageInstanceProvider = Provider<ProfileStorage>((ref) {
  return ProfileStorage(GetStorageService(GetStorage()));
});

class ProfileStorage {
  ProfileStorage(this._storage);

  final GetStorageService _storage;

  String getProfileName() => _storage.read<String>(_profileNameKey) ?? _defaultName;

  Future<void> saveProfileName(String name) => _storage.write(_profileNameKey, name);
}
