import 'dart:convert';

import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(AuthUserDTO user);
  AuthUserDTO? getUser();
  Future<void> clearUser();
  bool isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final GetStorageService storage;

  static const String _userKey = 'auth_current_user';
  static const String _tokenKey = 'auth_access_token';

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveUser(AuthUserDTO user) async {
    final jsonString = jsonEncode(user.toJson());
    await storage.write(_userKey, jsonString);
    if (user.token != null) {
      await storage.write(_tokenKey, user.token!);
    }
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
    await storage.remove(_tokenKey);
  }

  @override
  bool isLoggedIn() {
    return storage.has(_userKey) && getUser() != null;
  }
}
