import 'package:algorithm_visualizer/core/monitoring/crash_reporter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('the Sentry event cap', () {
    SentryEvent eventOf(Object error) => SentryEvent(throwable: error);

    test('lets the first three of an error type through, then drops the rest', () {
      final cap = SentryEventCap();

      final kept = [for (var i = 0; i < 5; i++) cap(eventOf(StateError('$i')), Hint())];

      expect(kept.whereType<SentryEvent>(), hasLength(3));
      expect(kept.skip(3), everyElement(isNull));
    });

    test('counts each error type on its own', () {
      final cap = SentryEventCap(maxPerErrorType: 1);

      expect(cap(eventOf(StateError('a')), Hint()), isNotNull);
      expect(cap(eventOf(ArgumentError('b')), Hint()), isNotNull);
      expect(cap(eventOf(StateError('c')), Hint()), isNull);
    });

    test('an event with no error object is counted by its exception type', () {
      final cap = SentryEventCap(maxPerErrorType: 1);
      SentryEvent native() => SentryEvent(exceptions: [SentryException(type: 'SIGSEGV', value: 'crash')]);

      expect(cap(native(), Hint()), isNotNull);
      expect(cap(native(), Hint()), isNull);
      expect(cap(SentryEvent(), Hint()), isNotNull, reason: 'unknown ones share their own count');
      expect(cap(SentryEvent(), Hint()), isNull);
    });
  });

  test('with Sentry never started, the Sentry reporter is harmless', () async {
    const reporter = SentryCrashReporter();

    await reporter.recordError(StateError('x'), StackTrace.current, context: {'phase': 'boot'});
    await reporter.recordError(StateError('x'), null);
    reporter.addBreadcrumb('opened settings', category: 'nav');
    reporter.setUserId('u1');
    reporter.setUserId(null);
  });

  group('the debug reporter prints instead of sending', () {
    late List<String> printed;
    late DebugPrintCallback originalPrint;

    setUp(() {
      printed = [];
      originalPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) => printed.add(message!);
    });

    tearDown(() => debugPrint = originalPrint);

    test('an error, marked fatal, with its context and stack', () async {
      await const DebugCrashReporter().recordError(
        StateError('boom'),
        StackTrace.fromString('#0 main'),
        fatal: true,
        context: {'phase': 'boot'},
      );

      expect(printed, ['[Crash][FATAL] Bad state: boom', '[Crash] context: {phase: boot}', '#0 main']);
    });

    test('an error with no context or stack is one line', () async {
      await const DebugCrashReporter().recordError(StateError('boom'), null, context: {});

      expect(printed, ['[Crash] Bad state: boom']);
    });

    test('breadcrumbs and the user', () {
      const reporter = DebugCrashReporter();

      reporter.addBreadcrumb('opened settings', category: 'nav');
      reporter.addBreadcrumb('tapped sync');
      reporter.setUserId('u1');
      reporter.setUserId(null);

      expect(printed, [
        '[Crash][breadcrumb][nav] opened settings',
        '[Crash][breadcrumb] tapped sync',
        '[Crash] user set to u1',
        '[Crash] user set to null',
      ]);
    });
  });
}
