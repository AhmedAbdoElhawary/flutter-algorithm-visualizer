import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';

/// Wire/storage shape of [AuthUser].
///
/// Like the entity, it carries no token — see [AuthUser] for why. The practical
/// consequence here is that [toJson] is also what gets written to local
/// storage, which is not encrypted, so anything added to this class lands on
/// disk in clear text. Keep it to what the app actually reads back.
class AuthUserDTO {
  final String id;
  final String name;
  final String email;

  const AuthUserDTO({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AuthUserDTO.fromJson(Map<String, dynamic> json) {
    return AuthUserDTO(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      name: name,
      email: email,
    );
  }

  AuthUserDTO copyWith({
    String? id,
    String? name,
    String? email,
  }) {
    return AuthUserDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
