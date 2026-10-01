import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/core/logging/firebase_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> printed;
  late DebugPrintCallback originalPrint;

  setUp(() {
    printed = [];
    originalPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => printed.add(message!);
    FirebaseLogConfig.enabled = true;
    FirebaseLogConfig.payloads = false;
  });

  tearDown(() {
    debugPrint = originalPrint;
    FirebaseLogConfig.enabled = kDebugMode;
    FirebaseLogConfig.payloads = kDebugMode;
  });

  group('trace', () {
    test('prints the call and its result, and returns the value', () async {
      final value = await FirebaseLogger.trace(
        'auth',
        'login',
        () async => 'x9K2wq',
        args: {'email': 'a***@gmail.com'},
        describeResult: (uid) => 'uid=$uid',
      );

      expect(value, 'x9K2wq');
      expect(printed, hasLength(2));
      expect(printed.first, matches(RegExp(r'^\[FB#\d+\]\[auth\] → login\(email: a\*\*\*@gmail.com\)$')));
      expect(printed.last, matches(RegExp(r'^\[FB#\d+\]\[auth\] ✓ login  \d+ms  uid=x9K2wq$')));
    });

    test('a failure is printed with its code and still thrown', () async {
      final call = FirebaseLogger.trace<void>(
        'firestore',
        'deleteProblem',
        () async => throw FirebaseException(plugin: 'firestore', code: 'permission-denied'),
      );

      await expectLater(call, throwsA(isA<FirebaseException>()));
      expect(printed.last, contains('✗ deleteProblem'));
      expect(printed.last, endsWith('FirebaseException(permission-denied)'));
    });

    test('each call gets the next number, so interleaved lines can be told apart', () async {
      await FirebaseLogger.trace('auth', 'a', () async => 1);
      await FirebaseLogger.trace('auth', 'b', () async => 2);

      int idOf(String line) => int.parse(RegExp(r'FB#(\d+)').firstMatch(line)!.group(1)!);
      expect(idOf(printed[2]), idOf(printed[0]) + 1);
    });

    test('when logging is off, it only runs the action', () async {
      FirebaseLogConfig.enabled = false;

      expect(await FirebaseLogger.trace('auth', 'login', () async => 5), 5);
      expect(printed, isEmpty);
    });
  });

  group('traceSync', () {
    test('prints one line with the result', () {
      final value =
          FirebaseLogger.traceSync('auth', 'currentUser', () => 'u1', describeResult: (v) => 'uid=$v');

      expect(value, 'u1');
      expect(printed.single, endsWith('• currentUser()  uid=u1'));
    });

    test('a failure is printed and still thrown', () {
      expect(
        () => FirebaseLogger.traceSync<int>('auth', 'read', () => throw StateError('gone')),
        throwsStateError,
      );
      expect(printed.single, contains('✗ read()'));
    });

    test('when logging is off, it only runs the action', () {
      FirebaseLogConfig.enabled = false;

      expect(FirebaseLogger.traceSync('auth', 'read', () => 3), 3);
      expect(printed, isEmpty);
    });
  });

  test('traceDetached marks a call nobody waits for', () {
    FirebaseLogger.traceDetached('firestore', 'saveProblem', args: {'id': 14});

    expect(printed.single, endsWith('→ saveProblem(id: 14)  (fire and forget)'));
  });

  test('failure reports an error from outside a call', () {
    FirebaseLogger.failure('init', 'Firebase.initializeApp', Exception('no network'));

    expect(printed.single, endsWith('✗ Firebase.initializeApp  Exception: no network'));
  });

  test('with logging off, detached calls and failures print nothing', () {
    FirebaseLogConfig.enabled = false;

    FirebaseLogger.traceDetached('firestore', 'saveProblem');
    FirebaseLogger.failure('init', 'x', Exception());

    expect(printed, isEmpty);
  });

  group('personal data stays hidden unless payloads are on', () {
    test('email keeps the first letter and the domain', () {
      expect(FirebaseLogger.email('ahmed@gmail.com'), 'a***@gmail.com');
      expect(FirebaseLogger.email('not-an-email'), FirebaseLogger.secret);
      expect(FirebaseLogger.email('@gmail.com'), FirebaseLogger.secret);
      expect(FirebaseLogger.email(null), 'null');
      expect(FirebaseLogger.email(''), 'null');
    });

    test('name keeps the first letter of each word', () {
      expect(FirebaseLogger.name('Ahmed  Abdo'), 'A*** A***');
      expect(FirebaseLogger.name(null), 'null');
    });

    test('id is cut to six characters', () {
      expect(FirebaseLogger.id('x9K2wqLongUid'), 'x9K2wq…');
      expect(FirebaseLogger.id('short'), 'short');
      expect(FirebaseLogger.id(''), 'null');
    });

    test('a document shows only how many fields it has', () {
      expect(FirebaseLogger.document({'a': 1, 'b': 2}), 'fields=2');
    });

    test('with payloads on, everything prints as is', () {
      FirebaseLogConfig.payloads = true;

      expect(FirebaseLogger.email('ahmed@gmail.com'), 'ahmed@gmail.com');
      expect(FirebaseLogger.name('Ahmed Abdo'), 'Ahmed Abdo');
      expect(FirebaseLogger.id('x9K2wqLongUid'), 'x9K2wqLongUid');
      expect(FirebaseLogger.document({'a': 1}), '{a: 1}');
    });
  });
}
