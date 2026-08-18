import 'package:algorithm_visualizer/core/storage/profile_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userNameProvider = StateNotifierProvider<UserNameNotifier, String>((ref) {
  return UserNameNotifier(ref.watch(profileStorageProvider));
});

class UserNameNotifier extends StateNotifier<String> {
  UserNameNotifier(this._storage) : super(_storage.getProfileName());

  final ProfileStorage _storage;

  Future<void> updateName(String name) async {
    state = name;
    await _storage.saveProfileName(name);
  }
}
