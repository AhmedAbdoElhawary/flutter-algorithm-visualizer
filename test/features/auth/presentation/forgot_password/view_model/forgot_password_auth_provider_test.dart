import 'package:algorithm_visualizer/features/auth/presentation/forgot_password/view_model/forgot_password_auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_container.dart';

void main() {
  test('the form outlives the page, so leaving and coming back keeps it', () async {
    final container = createTestContainer();
    final subscription = container.listen(authForgotPasswordProvider, (previous, next) {});
    container.read(authForgotPasswordProvider.notifier).setEmail('a@b.co');

    subscription.close();
    await container.pump();

    expect(container.read(authForgotPasswordProvider).email, 'a@b.co');
  });
}
