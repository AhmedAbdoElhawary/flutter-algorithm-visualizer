import 'perf_budgets.dart';
import 'perf_models.dart';

/// One raw frame timing, before phase classification.
class RawFrameTiming {
  const RawFrameTiming({
    required this.buildTimeMs,
    required this.rasterTimeMs,
  });

  final double buildTimeMs;
  final double rasterTimeMs;

  double get totalTimeMs => buildTimeMs + rasterTimeMs;
}

/// Classifies a run's raw frame timings into `warmup` and `steadyState`
/// samples, satisfying FR-021: one constant rule applied identically to
/// every scenario and build, steady state entered exactly once per run, and
/// warmup samples classified — never discarded (FR-020).
///
/// **The rule**: a frame is `warmup` while the cumulative elapsed time since
/// the run started is below [warmupMaxDurationMs]. The first frame whose
/// cumulative elapsed time reaches that threshold, and every frame after it,
/// is `steadyState`. This is the single constant boundary for every screen
/// and scenario — it is not tunable per-screen.
List<FrameSample> classifyFrames(List<RawFrameTiming> rawTimings) {
  final samples = <FrameSample>[];
  var elapsedMs = 0.0;
  var steadyStateEntered = false;

  for (var i = 0; i < rawTimings.length; i++) {
    final raw = rawTimings[i];
    if (!steadyStateEntered && elapsedMs >= warmupMaxDurationMs) {
      steadyStateEntered = true;
    }
    samples.add(
      FrameSample(
        frameIndex: i,
        buildTimeMs: raw.buildTimeMs,
        rasterTimeMs: raw.rasterTimeMs,
        totalTimeMs: raw.totalTimeMs,
        phase: steadyStateEntered ? FramePhase.steadyState : FramePhase.warmup,
      ),
    );
    elapsedMs += raw.totalTimeMs;
  }

  return samples;
}
