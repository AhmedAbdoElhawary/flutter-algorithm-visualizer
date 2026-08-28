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
    state = state.copyWith(username: name);
    await _storage.saveProfileName(name);
  }
}

class ProfileStorageState {
  final String username;

  ProfileStorageState({required this.username});

  factory ProfileStorageState.initial() {
    return ProfileStorageState(username: _defaultName);
  }

  ProfileStorageState copyWith({String? username}) {
    return ProfileStorageState(username: username ?? this.username);
  }
}
