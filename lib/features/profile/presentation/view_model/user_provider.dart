import 'package:algorithm_visualizer/core/storage/profile_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userNameProvider = NotifierProvider<UserNameNotifier, String>(() {
  return UserNameNotifier();
});

class UserNameNotifier extends Notifier<String> {
  late final ProfileStorage _storage;

  @override
  String build() {
    _storage = ref.watch(profileStorageProvider);
    return _storage.getProfileName();
  }

  Future<void> updateName(String name) async {
    state = name;
    await _storage.saveProfileName(name);
  }
}
