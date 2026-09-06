import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';

class AuthUserDTO {
  final String id;
  final String name;
  final String email;
  final String? token;

  const AuthUserDTO({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  factory AuthUserDTO.fromJson(Map<String, dynamic> json) {
    return AuthUserDTO(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (token != null) 'token': token,
    };
  }

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      name: name,
      email: email,
      token: token,
    );
  }

  factory AuthUserDTO.fromDomain(AuthUser entity) {
    return AuthUserDTO(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      token: entity.token,
    );
  }

  AuthUserDTO copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
  }) {
    return AuthUserDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }
}
