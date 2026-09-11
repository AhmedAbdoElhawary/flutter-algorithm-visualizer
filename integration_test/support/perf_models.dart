import 'perf_budgets.dart';

/// Which side of the warmup -> steadyState transition a frame falls in.
///
/// The transition rule (see `phase_classifier.dart`) is applied identically
/// to every scenario and build (FR-021). Steady state is entered exactly
/// once per run; warmup samples are classified, never discarded (FR-020).
enum FramePhase { warmup, steadyState }

/// One rendered frame — the atom of every performance measurement.
class FrameSample {
  const FrameSample({
    required this.frameIndex,
    required this.buildTimeMs,
    required this.rasterTimeMs,
    required this.totalTimeMs,
    required this.phase,
  })  : assert(frameIndex >= 0),
        assert(buildTimeMs >= 0),
        assert(rasterTimeMs >= 0),
        assert(totalTimeMs >= 0);

  final int frameIndex;
  final double buildTimeMs;
  final double rasterTimeMs;
  final double totalTimeMs;
  final FramePhase phase;

  bool get isOverBudget => totalTimeMs > frameBudgetMs;

  Map<String, dynamic> toJson() => {
        'frameIndex': frameIndex,
        'buildTimeMs': buildTimeMs,
        'rasterTimeMs': rasterTimeMs,
        'totalTimeMs': totalTimeMs,
        'phase': phase == FramePhase.warmup ? 'warmup' : 'steadyState',
      };

  factory FrameSample.fromJson(Map<String, dynamic> json) => FrameSample(
        frameIndex: json['frameIndex'] as int,
        buildTimeMs: (json['buildTimeMs'] as num?)?.toDouble() ?? 0,
        rasterTimeMs: (json['rasterTimeMs'] as num?)?.toDouble() ?? 0,
        totalTimeMs: (json['totalTimeMs'] as num).toDouble(),
        phase: json['phase'] == 'warmup' ? FramePhase.warmup : FramePhase.steadyState,
      );
}

/// Aggregates over a set of [FrameSample]s. Computed once for `warmup` and
/// once for `steadyState` per scenario.
class FrameStats {
  const FrameStats({
    required this.frameCount,
    required this.avgFrameTimeMs,
    required this.worstFrameTimeMs,
    required this.p90FrameTimeMs,
    required this.p99FrameTimeMs,
    required this.overBudgetFrameCount,
    required this.overBudgetPercent,
    this.durationMs,
  });

  final int frameCount;
  final double avgFrameTimeMs;
  final double worstFrameTimeMs;
  final double p90FrameTimeMs;
  final double p99FrameTimeMs;
  final int overBudgetFrameCount;
  final double overBudgetPercent;
  final double? durationMs;

  /// Builds stats from raw samples. Percentiles use nearest-rank on the
  /// sorted `totalTimeMs` values.
  factory FrameStats.fromSamples(List<FrameSample> samples, {double? durationMs}) {
    if (samples.isEmpty) {
      return FrameStats(
        frameCount: 0,
        avgFrameTimeMs: 0,
        worstFrameTimeMs: 0,
        p90FrameTimeMs: 0,
        p99FrameTimeMs: 0,
        overBudgetFrameCount: 0,
        overBudgetPercent: 0,
        durationMs: durationMs,
      );
    }
    final sorted = samples.map((s) => s.totalTimeMs).toList()..sort();
    final overBudget = samples.where((s) => s.isOverBudget).length;
    return FrameStats(
      frameCount: samples.length,
      avgFrameTimeMs: sorted.reduce((a, b) => a + b) / sorted.length,
      worstFrameTimeMs: sorted.last,
      p90FrameTimeMs: _percentile(sorted, 0.90),
      p99FrameTimeMs: _percentile(sorted, 0.99),
      overBudgetFrameCount: overBudget,
      overBudgetPercent: overBudget * 100 / sorted.length,
      durationMs: durationMs,
    );
  }

  static double _percentile(List<double> sortedAscending, double p) {
    final index = (p * (sortedAscending.length - 1)).round();
    return sortedAscending[index.clamp(0, sortedAscending.length - 1)];
  }

  Map<String, dynamic> toJson() => {
        'frameCount': frameCount,
        'avgFrameTimeMs': avgFrameTimeMs,
        'worstFrameTimeMs': worstFrameTimeMs,
        'p90FrameTimeMs': p90FrameTimeMs,
        'p99FrameTimeMs': p99FrameTimeMs,
        'overBudgetFrameCount': overBudgetFrameCount,
        'overBudgetPercent': overBudgetPercent,
        if (durationMs != null) 'durationMs': durationMs,
      };

  factory FrameStats.fromJson(Map<String, dynamic> json) => FrameStats(
        frameCount: json['frameCount'] as int,
        avgFrameTimeMs: (json['avgFrameTimeMs'] as num).toDouble(),
        worstFrameTimeMs: (json['worstFrameTimeMs'] as num).toDouble(),
        p90FrameTimeMs: (json['p90FrameTimeMs'] as num?)?.toDouble() ?? 0,
        p99FrameTimeMs: (json['p99FrameTimeMs'] as num).toDouble(),
        overBudgetFrameCount: json['overBudgetFrameCount'] as int,
        overBudgetPercent: (json['overBudgetPercent'] as num?)?.toDouble() ?? 0,
        durationMs: (json['durationMs'] as num?)?.toDouble(),
      );
}
