import 'package:algorithm_visualizer/features/auth/presentation/signup/view_model/signup_auth_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_container.dart';

void main() {
  test('the form outlives the page, so leaving and coming back keeps it', () async {
    final container = createTestContainer();
    final subscription = container.listen(authSignupProvider, (previous, next) {});
    container.read(authSignupProvider.notifier).setName('Ada');

    subscription.close();
    await container.pump();

    expect(container.read(authSignupProvider).name, 'Ada');
  });
}
