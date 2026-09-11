import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:integration_test/integration_test.dart';

import 'perf_models.dart';
import 'perf_report.dart';
import 'phase_classifier.dart';

/// Runs [action] while recording every raw frame timing the engine reports,
/// then classifies them into warmup/steadyState via [classifyFrames]
/// (FR-021) and builds a [ScenarioReport] conforming to
/// `contracts/perf-report.schema.json`.
///
/// Lower-level than [IntegrationTestWidgetsFlutterBinding.watchPerformance]:
/// that helper only keeps an aggregate summary, but the perf-report contract
/// needs the warmup/steadyState split this feature defines, so the raw
/// per-frame [FrameTiming] stream is collected directly here instead.
Future<ScenarioReport> driveScenario({
  required String scenarioId,
  required TargetScreen screen,
  required Future<void> Function() action,
  double? tabSwitchMs,
}) async {
  final binding = IntegrationTestWidgetsFlutterBinding.instance;

  final rawTimings = <RawFrameTiming>[];
  void collect(List<FrameTiming> timings) {
    for (final timing in timings) {
      rawTimings.add(
        RawFrameTiming(
          buildTimeMs: timing.buildDuration.inMicroseconds / 1000,
          rasterTimeMs: timing.rasterDuration.inMicroseconds / 1000,
        ),
      );
    }
  }

  // Flush any FrameTimings left over from prior scenarios / widget setup
  // before this scenario's own timings start accumulating.
  await Future<void>.delayed(const Duration(seconds: 1));
  binding.addTimingsCallback(collect);
  await action();
  // The engine can batch FrameTimings and report them up to ~1s late.
  await Future<void>.delayed(const Duration(seconds: 2));
  binding.removeTimingsCallback(collect);

  final samples = classifyFrames(rawTimings);
  final warmupSamples = samples.where((s) => s.phase == FramePhase.warmup).toList();
  final steadySamples = samples.where((s) => s.phase == FramePhase.steadyState).toList();

  final warmupDurationMs = warmupSamples.fold<double>(0, (sum, s) => sum + s.totalTimeMs);

  return ScenarioReport(
    scenarioId: scenarioId,
    screen: screen,
    steadyState: FrameStats.fromSamples(steadySamples),
    warmup: FrameStats.fromSamples(warmupSamples, durationMs: warmupDurationMs),
    tabSwitchMs: tabSwitchMs,
  );
}

/// Assembles the reports collected by every scenario in the suite into a
/// [PerformanceBaseline] and hands it to [IntegrationTestWidgetsFlutterBinding]
/// as report data, so `flutter drive` (via test_driver/integration_test.dart)
/// writes it to disk as JSON (FR-022).
Future<void> writePerformanceBaseline({
  required BaselineLabel label,
  required List<ScenarioReport> reports,
  required String device,
  ThermalState thermalState = ThermalState.cold,
}) async {
  final binding = IntegrationTestWidgetsFlutterBinding.instance;
  final gitSha = await _currentGitSha();

  final baseline = PerformanceBaseline(
    label: label,
    device: device,
    buildMode: _currentBuildMode(),
    gitSha: gitSha,
    capturedAt: DateTime.now().toUtc(),
    thermalState: thermalState,
    reports: reports,
  );

  binding.reportData ??= <String, dynamic>{};
  binding.reportData!['performance'] = baseline.toJson();
}

ReportBuildMode _currentBuildMode() {
  // kProfileMode/kReleaseMode are compile-time constants from
  // package:flutter/foundation.dart; kDebugMode is intentionally not
  // accepted — a debug run must fail loudly, not report bogus numbers.
  const isProfile = bool.fromEnvironment('dart.vm.profile');
  return isProfile ? ReportBuildMode.profile : ReportBuildMode.release;
}

/// Prefers `--dart-define=GIT_SHA=<sha>` (works on-device, where there is no
/// `git` binary); falls back to running `git` directly, which only works
/// when this suite runs on the host (`flutter test integration_test/...`
/// during local iteration, never the real on-device gating run).
Future<String> _currentGitSha() async {
  const fromDefine = String.fromEnvironment('GIT_SHA');
  if (fromDefine.isNotEmpty) return fromDefine;

  try {
    final result = await Process.run('git', ['rev-parse', '--short=7', 'HEAD']);
    final sha = (result.stdout as String).trim();
    if (sha.isNotEmpty) return sha;
  } catch (_) {
    // No git on PATH (expected on-device without GIT_SHA passed).
  }
  return '0000000';
}
