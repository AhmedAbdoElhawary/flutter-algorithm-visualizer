import 'package:algorithm_visualizer/core/storage/storage.dart';

/// Holds the profile fields a guest can change before owning an account.
///
/// Only the display name is editable while signed out; e-mail and password are
/// meaningless without a Firebase account. The stored name is used to pre-fill
/// the sign up form and is dropped once it has been handed to Firebase Auth.
abstract class ProfileLocalDataSource {
  Future<void> saveDisplayName(String name);

  String? getDisplayName();

  Future<void> clearDisplayName();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final LocalStorage storage;

  static const String guestDisplayNameKey = 'guest_display_name';

  ProfileLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveDisplayName(String name) async {
    await storage.write(guestDisplayNameKey, name.trim());
  }

  @override
  String? getDisplayName() {
    final name = storage.read<String>(guestDisplayNameKey);
    if (name == null || name.trim().isEmpty) return null;
    return name;
  }

  @override
  Future<void> clearDisplayName() async {
    await storage.remove(guestDisplayNameKey);
  }
}
