/// The signed-in user, as the app thinks of them.
///
/// There is no `token` field. A Firebase ID token was carried here for a
/// while, but nothing ever read it: every call this app makes goes through a
/// Firebase SDK, and each of those asks the SDK for a fresh token itself. An
/// ID token also expires an hour after it is issued, so a copy held on an
/// entity is wrong almost as soon as it is made. Keeping a credential in a
/// widely-passed object with no reader is a liability and no benefit.
class AuthUser {
  final String id;
  final String? name;
  final String? email;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
  });

  /// A guest is a user who interacts with the app before owning an account.
  /// Firebase never issues an empty uid, so an empty [id] marks the local-only
  /// session whose progress still lives in `GetStorage`.
  const AuthUser.guest({this.name})
      : id = '',
        email = null;

  bool get isGuest => id.isEmpty;

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
}
