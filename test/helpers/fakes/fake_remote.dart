/// The three knobs every remote fake shares, so an error or loading path is one line of setup.
mixin FakeRemote {
  /// Thrown by the next call only, then cleared.
  Object? failWith;

  Duration delay = Duration.zero;

  final List<String> calls = [];

  Future<void> answer(String call) async {
    calls.add(call);
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    final error = failWith;
    if (error == null) return;
    failWith = null;
    throw error;
  }
}
