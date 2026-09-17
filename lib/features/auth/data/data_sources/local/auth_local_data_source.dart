import 'dart:convert';

import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(AuthUserDTO user);
  AuthUserDTO? getUser();
  Future<void> clearUser();
  bool isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorage storage;

  static const String _userKey = 'auth_current_user';

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveUser(AuthUserDTO user) async {
    /// [AuthUserDTO] carries no token, so what lands on disk is the uid, name
    /// and email the app actually reads back — nothing that is a credential.
    /// This storage is not encrypted, so that distinction is the whole point.
    final jsonString = jsonEncode(user.toJson());
    await storage.write(_userKey, jsonString);
  }

  @override
  AuthUserDTO? getUser() {
    final data = storage.read<String>(_userKey);
    if (data == null || data.isEmpty) return null;
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      return AuthUserDTO.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await storage.remove(_userKey);
  }

  @override
  bool isLoggedIn() {
    return storage.has(_userKey) && getUser() != null;
  }
}
