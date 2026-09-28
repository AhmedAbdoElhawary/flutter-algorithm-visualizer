import 'package:algorithm_visualizer/features/auth/presentation/delete_account/view_model/delete_account_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_container.dart';

void main() {
  test('the form is forgotten once nothing uses it', () async {
    final container = createTestContainer();
    final subscription = container.listen(deleteAccountProvider, (previous, next) {});
    container.read(deleteAccountProvider.notifier).setPassword('secret-1');
    expect(container.read(deleteAccountProvider).password, 'secret-1');

    subscription.close();
    await container.pump();

    expect(container.read(deleteAccountProvider).password, '');
  });
}
