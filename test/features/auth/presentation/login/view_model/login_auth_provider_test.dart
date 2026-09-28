import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_container.dart';

void main() {
  test('the form is forgotten once nothing uses it', () async {
    final container = createTestContainer();
    final subscription = container.listen(authLoginProvider, (previous, next) {});
    container.read(authLoginProvider.notifier).setEmail('a@b.co');
    expect(container.read(authLoginProvider).email, 'a@b.co');

    subscription.close();
    await container.pump();

    expect(container.read(authLoginProvider).email, '');
  });
}
