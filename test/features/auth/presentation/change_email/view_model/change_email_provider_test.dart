import 'package:algorithm_visualizer/features/auth/presentation/change_email/view_model/change_email_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_container.dart';

void main() {
  test('the form is forgotten once nothing uses it', () async {
    final container = createTestContainer();
    final subscription = container.listen(changeEmailProvider, (previous, next) {});
    container.read(changeEmailProvider.notifier).setNewEmail('a@b.co');
    expect(container.read(changeEmailProvider).newEmail, 'a@b.co');

    subscription.close();
    await container.pump();

    expect(container.read(changeEmailProvider).newEmail, '');
  });
}
