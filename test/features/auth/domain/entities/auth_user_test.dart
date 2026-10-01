import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = AuthUser(id: 'uid-1', name: 'Ada', email: 'ada@test.dev');

  test('a guest has no id and no email', () {
    const guest = AuthUser.guest(name: 'Visitor');

    expect(guest.isGuest, isTrue);
    expect(guest.email, isNull);
    expect(guest.name, 'Visitor');
    expect(user.isGuest, isFalse);
  });

  test('equal users are equal and hash the same', () {
    const same = AuthUser(id: 'uid-1', name: 'Ada', email: 'ada@test.dev');

    expect(user, same);
    expect(user.hashCode, same.hashCode);
    expect(user, isNot(user.copyWith(name: 'Grace')));
  });

  test('copyWith changes only what is given', () {
    expect(user.copyWith(name: 'Grace'), const AuthUser(id: 'uid-1', name: 'Grace', email: 'ada@test.dev'));
    expect(user.copyWith(id: 'uid-2').id, 'uid-2');
    expect(user.copyWith(email: 'b@test.dev').email, 'b@test.dev');
    expect(user.copyWith(), user);
  });
}
