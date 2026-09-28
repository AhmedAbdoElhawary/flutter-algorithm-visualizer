import 'package:algorithm_visualizer/features/auth/presentation/change_password/view_model/change_password_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_container.dart';

void main() {
  test('the form is forgotten once nothing uses it', () async {
    final container = createTestContainer();
    final subscription = container.listen(changePasswordProvider, (previous, next) {});
    container.read(changePasswordProvider.notifier).setNewPassword('secret-2');
    expect(container.read(changePasswordProvider).newPassword, 'secret-2');

    subscription.close();
    await container.pump();

    expect(container.read(changePasswordProvider).newPassword, '');
  });
}
