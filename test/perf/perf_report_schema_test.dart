import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/support/perf_models.dart';
import '../../integration_test/support/perf_report.dart';

/// Asserts a serialized [PerformanceBaseline] conforms to
/// `specs/001-render-performance-60fps/contracts/perf-report.schema.json`.
///
/// No schema-validation package is added for this — `integration_test` is
/// this feature's one declared new dependency (plan.md Complexity Tracking).
/// The schema is small and fixed, so this test walks it by hand instead.
void main() {
  late Map<String, dynamic> schema;

  setUpAll(() {
    final file = File('specs/001-render-performance-60fps/contracts/perf-report.schema.json');
    schema = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  });

  test('schema declares the exact contract this model implements', () {
    expect(schema['required'], containsAll(<String>[
      'schemaVersion', 'label', 'device', 'buildMode', 'gitSha', 'capturedAt', 'reports',
    ]));
    final properties = schema['properties'] as Map<String, dynamic>;
    expect((properties['schemaVersion'] as Map)['const'], perfReportSchemaVersion);
    expect((properties['label'] as Map)['enum'], ['before', 'after']);
    expect((properties['buildMode'] as Map)['enum'], ['profile', 'release']);
    expect((properties['thermalState'] as Map)['enum'], ['cold', 'warm']);
    expect((properties['thermalState'] as Map)['default'], 'cold');
  });

  test('a serialized PerformanceBaseline satisfies every required field and constraint', () {
    final baseline = PerformanceBaseline(
      label: BaselineLabel.before,
      device: 'oppo-a5i',
      buildMode: ReportBuildMode.profile,
      gitSha: 'abc1234',
      capturedAt: DateTime.utc(2026, 9, 11),
      reports: [
        ScenarioReport(
          scenarioId: 'scroll.home',
          screen: TargetScreen.home,
          steadyState: const FrameStats(
            frameCount: 600,
            avgFrameTimeMs: 10,
            worstFrameTimeMs: 15,
            p90FrameTimeMs: 12,
            p99FrameTimeMs: 14,
            overBudgetFrameCount: 0,
            overBudgetPercent: 0,
          ),
          warmup: const FrameStats(
            frameCount: 10,
            avgFrameTimeMs: 20,
            worstFrameTimeMs: 90,
            p90FrameTimeMs: 40,
            p99FrameTimeMs: 90,
            overBudgetFrameCount: 3,
            overBudgetPercent: 30,
            durationMs: 300,
          ),
        ),
      ],
    );

    final json = baseline.toJson();
    final required = (schema['required'] as List<dynamic>).cast<String>();
    for (final field in required) {
      expect(json.containsKey(field), isTrue, reason: 'missing required field "$field"');
    }

    expect(json['schemaVersion'], perfReportSchemaVersion);
    expect(['before', 'after'], contains(json['label']));
    expect(RegExp(r'^[0-9a-f]{7,40}$').hasMatch(json['gitSha'] as String), isTrue);
    expect(DateTime.tryParse(json['capturedAt'] as String), isNotNull);
    expect(['profile', 'release'], contains(json['buildMode']));
    expect(['cold', 'warm'], contains(json['thermalState']));

    final reports = json['reports'] as List<dynamic>;
    expect(reports, isNotEmpty);
    final report = reports.first as Map<String, dynamic>;
    expect(report.containsKey('scenarioId'), isTrue);
    expect(report.containsKey('steadyState'), isTrue);
    expect(report.containsKey('warmup'), isTrue);
    expect(['home', 'visualize', 'code', 'practice', 'profile'], contains(report['screen']));

    final steadyState = report['steadyState'] as Map<String, dynamic>;
    for (final field in ['frameCount', 'avgFrameTimeMs', 'worstFrameTimeMs', 'p99FrameTimeMs', 'overBudgetFrameCount']) {
      expect(steadyState.containsKey(field), isTrue, reason: 'steadyState missing "$field"');
    }
  });

  test('buildMode "debug" is rejected, not silently accepted (FR-001)', () {
    expect(
      () => PerformanceBaseline.fromJson({
        'label': 'before',
        'device': 'oppo-a5i',
        'buildMode': 'debug',
        'gitSha': 'abc1234',
        'capturedAt': DateTime.now().toIso8601String(),
        'reports': [],
      }),
      throwsArgumentError,
    );
  });
}
