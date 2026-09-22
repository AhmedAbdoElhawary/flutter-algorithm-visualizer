import 'package:algorithm_visualizer/core/resources/constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

abstract class AnalyticsService {
  static AnalyticsService instance = const DebugAnalyticsService();

  Future<void> problemOpened({required int problemId, required String title});

  Future<void> visualizationStarted({required String algorithm});

  Future<void> visualizationCompleted({required String algorithm, required int durationMs});

  Future<void> algorithmSelected({required String algorithm, required String category});

  Future<void> speedChanged({required double speed});
}

/// flutter testing only
class DebugAnalyticsService implements AnalyticsService {
  const DebugAnalyticsService();

  void _log(String name, Map<String, Object?> params) {
    if (!kCustomDebugMode) return;
    debugPrint('[Analytics] $name $params');
  }

  @override
  Future<void> problemOpened({required int problemId, required String title}) async =>
      _log('problem_opened', {'problem_id': problemId, 'title': title});

  @override
  Future<void> visualizationStarted({required String algorithm}) async =>
      _log('visualization_started', {'algorithm': algorithm});

  @override
  Future<void> visualizationCompleted({required String algorithm, required int durationMs}) async =>
      _log('visualization_completed', {'algorithm': algorithm, 'duration_ms': durationMs});

  @override
  Future<void> algorithmSelected({required String algorithm, required String category}) async =>
      _log('algorithm_selected', {'algorithm': algorithm, 'category': category});

  @override
  Future<void> speedChanged({required double speed}) async => _log('speed_changed', {'speed': speed});
}

class FirebaseAnalyticsService implements AnalyticsService {
  const FirebaseAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> problemOpened({required int problemId, required String title}) => _analytics.logEvent(
        name: 'problem_opened',
        parameters: {'problem_id': problemId, 'title': title},
      );

  @override
  Future<void> visualizationStarted({required String algorithm}) => _analytics.logEvent(
        name: 'visualization_started',
        parameters: {'algorithm': algorithm},
      );

  @override
  Future<void> visualizationCompleted({required String algorithm, required int durationMs}) =>
      _analytics.logEvent(
        name: 'visualization_completed',
        parameters: {'algorithm': algorithm, 'duration_ms': durationMs},
      );

  @override
  Future<void> algorithmSelected({required String algorithm, required String category}) =>
      _analytics.logEvent(
        name: 'algorithm_selected',
        parameters: {'algorithm': algorithm, 'category': category},
      );

  @override
  Future<void> speedChanged({required double speed}) => _analytics.logEvent(
        name: 'speed_changed',
        parameters: {'speed': speed},
      );
}
