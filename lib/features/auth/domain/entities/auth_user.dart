class AuthUser {
  final String id;
  final String? name;
  final String? email;
  final String? token;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  /// A guest is a user who interacts with the app before owning an account.
  /// Firebase never issues an empty uid, so an empty [id] marks the local-only
  /// session whose progress still lives in `GetStorage`.
  const AuthUser.guest({this.name})
      : id = '',
        email = null,
        token = null;

  bool get isGuest => id.isEmpty;

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
