class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? token;
  final int solvedCount;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.solvedCount = 0,
  });

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    int? solvedCount,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      solvedCount: solvedCount ?? this.solvedCount,
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
          token == other.token &&
          solvedCount == other.solvedCount;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      (token?.hashCode ?? 0) ^
      solvedCount.hashCode;
}
