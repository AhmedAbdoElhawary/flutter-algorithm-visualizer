import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

part 'profile_storage.dart';

final profileStorageProvider = NotifierProvider<ProfileStorageNotifier, ProfileStorageState>(() {
  return ProfileStorageNotifier();
});

class ProfileStorageNotifier extends Notifier<ProfileStorageState> {
  late final ProfileStorage _storage;

  @override
  ProfileStorageState build() {
    _storage = ref.watch(profileStorageInstanceProvider);
    return ProfileStorageState(username: _storage.getProfileName());
  }

  Future<void> updateName(String name) async {
    if (name.trim().isEmpty) return;

    state = state.copyWith(username: name.trim());
    await _storage.saveProfileName(name.trim());
  }
}

class ProfileStorageState {
  final String username;

  ProfileStorageState({required this.username});

  factory ProfileStorageState.initial() {
    return ProfileStorageState(username: defaultName);
  }

  ProfileStorageState copyWith({String? username}) {
    return ProfileStorageState(username: username ?? this.username);
  }
}
