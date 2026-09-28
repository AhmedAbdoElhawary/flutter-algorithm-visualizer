import 'package:algorithm_visualizer/features/auth/presentation/common/extensions/auth_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('accepts real addresses', () {
    for (final email in [
      'ada@test.dev',
      'ada.lovelace@mail.example.co.uk',
      'ada+algodive@gmail.com',
      'ada_99@test.museum',
      'a-b@my-host.technology',
      '  ada@test.dev  ',
    ]) {
      test(email, () => expect(email.validateEmail, isTrue));
    }
  });

  group('refuses obvious typos', () {
    for (final email in ['', 'ada', 'ada@', '@test.dev', 'ada@test', 'ada@test.', 'ada test@test.dev', 'ada@@test.dev', 'ada@test.c']) {
      test('"$email"', () => expect(email.validateEmail, isFalse));
    }
  });
}
