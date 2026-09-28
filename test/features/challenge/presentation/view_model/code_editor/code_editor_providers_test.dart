import 'package:algorithm_visualizer/features/challenge/presentation/view_model/code_editor/code_editor_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_container.dart';

void main() {
  test('the controller is dropped once its screen stops listening, so reopening starts fresh', () async {
    final container = createTestContainer();
    final subscription = container.listen(codeEditorControllerProvider(5), (previous, next) {});
    final first = container.read(codeEditorControllerProvider(5).notifier);

    subscription.close();
    await Future<void>.delayed(Duration.zero);
    container.listen(codeEditorControllerProvider(5), (previous, next) {});

    expect(container.read(codeEditorControllerProvider(5).notifier), isNot(same(first)));
  });

  test('while listened to, the same controller is kept', () {
    final container = createTestContainer();
    container.listen(codeEditorControllerProvider(5), (previous, next) {});

    expect(
      container.read(codeEditorControllerProvider(5).notifier),
      same(container.read(codeEditorControllerProvider(5).notifier)),
    );
  });
}
