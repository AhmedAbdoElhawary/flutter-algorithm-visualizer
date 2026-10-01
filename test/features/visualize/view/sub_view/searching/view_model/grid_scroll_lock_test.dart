import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/grid_scroll_lock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('starts unlocked', () {
    expect(container.read(gridScrollLockProvider), isFalse);
  });

  test('lock and release', () {
    container.read(gridScrollLockProvider.notifier).lock();
    expect(container.read(gridScrollLockProvider), isTrue);

    container.read(gridScrollLockProvider.notifier).release();
    expect(container.read(gridScrollLockProvider), isFalse);
  });

  test('release without a lock stays unlocked', () {
    container.read(gridScrollLockProvider.notifier).release();

    expect(container.read(gridScrollLockProvider), isFalse);
  });
}
