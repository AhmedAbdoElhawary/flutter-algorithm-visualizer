import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Is a pointer currently down on the searching grid?
///
/// Set from the raw pointer event, before the gesture arena resolves — that
/// ordering is what lets the page freeze its scroll in time for the drag.
class GridScrollLock extends Notifier<bool> {
  @override
  bool build() => false;

  void lock() => state = true;

  /// Must run on pointer cancel as well as pointer up, or the page stays
  /// permanently frozen.
  void release() => state = false;
}

final gridScrollLockProvider = NotifierProvider<GridScrollLock, bool>(GridScrollLock.new);
