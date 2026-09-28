import 'package:algorithm_visualizer/core/monitoring/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFirebaseAnalytics implements FirebaseAnalytics {
  final events = <(String, Map<String, Object>?)>[];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    List<AnalyticsEventItem>? items,
    AnalyticsCallOptions? callOptions,
  }) async =>
      events.add((name, parameters));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Sends every event once, so both services are checked against the same list.
Future<void> _sendAll(AnalyticsService service) async {
  await service.problemOpened(problemId: 1, title: 'Two Sum');
  await service.visualizationStarted(algorithm: 'bubble');
  await service.visualizationCompleted(algorithm: 'bubble', durationMs: 1200);
  await service.algorithmSelected(algorithm: 'bfs', category: 'searching');
  await service.speedChanged(speed: 1.5);
}

void main() {
  test('the default service is the debug one, so tests never reach Firebase', () {
    expect(AnalyticsService.instance, isA<DebugAnalyticsService>());
  });

  test('Firebase gets each event with its snake_case name and parameters', () async {
    final analytics = _FakeFirebaseAnalytics();

    await _sendAll(FirebaseAnalyticsService(analytics));

    expect(analytics.events.map((e) => e.$1), [
      'problem_opened',
      'visualization_started',
      'visualization_completed',
      'algorithm_selected',
      'speed_changed',
    ]);
    expect(analytics.events.map((e) => e.$2), [
      {'problem_id': 1, 'title': 'Two Sum'},
      {'algorithm': 'bubble'},
      {'algorithm': 'bubble', 'duration_ms': 1200},
      {'algorithm': 'bfs', 'category': 'searching'},
      {'speed': 1.5},
    ]);
  });

  test('the debug service prints the same events instead', () async {
    final printed = <String>[];
    final originalPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => printed.add(message!);
    addTearDown(() => debugPrint = originalPrint);

    await _sendAll(const DebugAnalyticsService());

    expect(printed, [
      '[Analytics] problem_opened {problem_id: 1, title: Two Sum}',
      '[Analytics] visualization_started {algorithm: bubble}',
      '[Analytics] visualization_completed {algorithm: bubble, duration_ms: 1200}',
      '[Analytics] algorithm_selected {algorithm: bfs, category: searching}',
      '[Analytics] speed_changed {speed: 1.5}',
    ]);
  });
}
