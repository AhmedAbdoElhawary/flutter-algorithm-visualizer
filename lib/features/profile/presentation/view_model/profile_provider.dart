import 'package:algorithm_visualizer/core/storage/profile_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileNameProvider = StateNotifierProvider<ProfileNameNotifier, String>((ref) {
  return ProfileNameNotifier(ref.watch(profileStorageProvider));
});

class ProfileNameNotifier extends StateNotifier<String> {
  ProfileNameNotifier(this._storage) : super(_storage.getProfileName());

  final ProfileStorage _storage;

  Future<void> updateName(String name) async {
    state = name;
    await _storage.saveProfileName(name);
  }
}
