import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dto = AuthUserDTO(id: 'uid-1', name: 'Ada', email: 'ada@test.dev');

  test('toJson and fromJson round trip', () {
    final back = AuthUserDTO.fromJson(dto.toJson());

    expect(back.toJson(), {'id': 'uid-1', 'name': 'Ada', 'email': 'ada@test.dev'});
  });

  test('missing fields read as empty, not null', () {
    final dto = AuthUserDTO.fromJson(const {});

    expect((dto.id, dto.name, dto.email), ('', '', ''));
  });

  test('toDomain carries every field', () {
    expect(dto.toDomain(), const AuthUser(id: 'uid-1', name: 'Ada', email: 'ada@test.dev'));
  });

  test('copyWith changes only what is given', () {
    expect(dto.copyWith(name: 'Grace').toJson(), {'id': 'uid-1', 'name': 'Grace', 'email': 'ada@test.dev'});
    expect(dto.copyWith(id: 'uid-2', email: 'b@test.dev').toJson()['id'], 'uid-2');
    expect(dto.copyWith().toJson(), dto.toJson());
  });
}
