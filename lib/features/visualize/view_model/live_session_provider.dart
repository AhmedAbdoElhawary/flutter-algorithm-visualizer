import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The visual state of one bar in the live sparkline. Mirrors the sorting-plot
/// state model: idle grey, the compared pair cyan, the sorted tail green.
enum LiveBarState { idle, compared, sorted }

class LiveBar {
  /// Height as a fraction (0..1) of the tallest bar in the run.
  final double fraction;
  final LiveBarState state;

  const LiveBar({required this.fraction, required this.state});
}

/// A snapshot of the algorithm run that is currently playing in the visualizer,
/// published so the Home live card (and, later, a lock-screen / status pill) can
/// mirror it. `null` in the provider means nothing is running.
class LiveSessionData {
  final String algorithmName;
  final String stepText;
  final int currentStep;
  final int totalSteps;

  /// 0..1 playback progress.
  final double progress;
  final List<LiveBar> bars;
  final bool isPlaying;

  /// Play time accumulated up to [syncedAt]. While [isPlaying] the view adds the
  /// wall-clock time since [syncedAt] on top; while paused it stays frozen, so
  /// the displayed clock is pause-correct.
  final Duration elapsed;
  final DateTime syncedAt;

  const LiveSessionData({
    required this.algorithmName,
    required this.stepText,
    required this.currentStep,
    required this.totalSteps,
    required this.progress,
    required this.bars,
    required this.isPlaying,
    required this.elapsed,
    required this.syncedAt,
  });

  Duration get liveElapsed =>
      isPlaying ? elapsed + DateTime.now().difference(syncedAt) : elapsed;
}

/// Holds the current [LiveSessionData] plus a callback back into the visualizer
/// so the live card's pause button can drive the real playback. The callback is
/// runtime-only wiring, not serialisable state — it never leaves this object.
class LiveSessionController extends Notifier<LiveSessionData?> {
  void Function()? _onToggle;

  @override
  LiveSessionData? build() => null;

  void sync(LiveSessionData data) => state = data;

  void bindToggle(void Function() onToggle) => _onToggle = onToggle;

  void toggle() => _onToggle?.call();

  void clear() {
    _onToggle = null;
    state = null;
  }
}

final liveSessionProvider =
    NotifierProvider<LiveSessionController, LiveSessionData?>(
  LiveSessionController.new,
);
