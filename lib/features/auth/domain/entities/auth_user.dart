class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? token;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          token == other.token ;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      (token?.hashCode ?? 0);
}
