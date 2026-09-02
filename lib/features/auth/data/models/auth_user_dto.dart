import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';

class AuthUserDTO {
  final String id;
  final String name;
  final String email;
  final String? token;
  final int solvedCount;

  const AuthUserDTO({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.solvedCount = 0,
  });

  factory AuthUserDTO.fromJson(Map<String, dynamic> json) {
    return AuthUserDTO(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      token: json['token'] as String?,
      solvedCount: json['solvedCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (token != null) 'token': token,
      'solvedCount': solvedCount,
    };
  }

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      name: name,
      email: email,
      token: token,
      solvedCount: solvedCount,
    );
  }

  factory AuthUserDTO.fromDomain(AuthUser entity) {
    return AuthUserDTO(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      token: entity.token,
      solvedCount: entity.solvedCount,
    );
  }
}
