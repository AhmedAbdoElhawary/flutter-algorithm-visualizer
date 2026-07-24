import 'pf_constants.dart';
import 'pf_step.dart';

enum PlaybackSpeed { slow, normal, fast }

extension PlaybackSpeedX on PlaybackSpeed {
  Duration get stepDuration => switch (this) {
        PlaybackSpeed.slow => const Duration(milliseconds: 150),
        PlaybackSpeed.normal => const Duration(milliseconds: 55),
        PlaybackSpeed.fast => const Duration(milliseconds: 16),
      };

  /// Display multiplier shown on the speed selector (1×, 2×, 3×).
  int get level => switch (this) {
        PlaybackSpeed.slow => 1,
        PlaybackSpeed.normal => 2,
        PlaybackSpeed.fast => 3,
      };
}

class SearchingState {
  final List<List<bool>> walls;
  final List<PFStep>? steps;
  final int stepIndex;
  final bool playing;
  final PlaybackSpeed speed;

  const SearchingState({
    required this.walls,
    required this.steps,
    required this.stepIndex,
    required this.playing,
    required this.speed,
  });

  factory SearchingState.initial() => SearchingState(
        walls: emptyWalls(),
        steps: null,
        stepIndex: 0,
        playing: false,
        speed: PlaybackSpeed.normal,
      );

  static List<List<bool>> emptyWalls() =>
      List.generate(kPFRows, (_) => List.filled(kPFCols, false));

  bool get hasSteps => steps != null;
  bool get isAtStart => stepIndex == 0;
  bool get isAtEnd => steps != null && stepIndex >= steps!.length - 1;
  PFStep? get currentStep => steps != null ? steps![stepIndex] : null;

  SearchingState copyWith({
    List<List<bool>>? walls,
    List<PFStep>? steps,
    bool clearSteps = false,
    int? stepIndex,
    bool? playing,
    PlaybackSpeed? speed,
  }) {
    return SearchingState(
      walls: walls ?? this.walls,
      steps: clearSteps ? null : (steps ?? this.steps),
      stepIndex: stepIndex ?? this.stepIndex,
      playing: playing ?? this.playing,
      speed: speed ?? this.speed,
    );
  }
}
