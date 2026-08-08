part of 'searching_notifier.dart';

class SearchingState {
  final List<List<bool>> walls;
  final List<PFStep>? steps;
  final int stepIndex;
  final bool playing;
  final PlaybackSpeed speed;
  final int startRow;
  final int startCol;
  final int endRow;
  final int endCol;

  const SearchingState({
    required this.walls,
    required this.steps,
    required this.stepIndex,
    required this.playing,
    required this.speed,
    required this.startRow,
    required this.startCol,
    required this.endRow,
    required this.endCol,
  });

  factory SearchingState.initial() => SearchingState(
        walls: emptyWalls(),
        steps: null,
        stepIndex: 0,
        playing: false,
        speed: PlaybackSpeed.normal,
        startRow: kPFStartRow,
        startCol: kPFStartCol,
        endRow: kPFEndRow,
        endCol: kPFEndCol,
      );

  static List<List<bool>> emptyWalls() => List.generate(kPFCells, (_) => List.filled(kPFCells, false));

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
    int? startRow,
    int? startCol,
    int? endRow,
    int? endCol,
  }) {
    return SearchingState(
      walls: walls ?? this.walls,
      steps: clearSteps ? null : (steps ?? this.steps),
      stepIndex: stepIndex ?? this.stepIndex,
      playing: playing ?? this.playing,
      speed: speed ?? this.speed,
      startRow: startRow ?? this.startRow,
      startCol: startCol ?? this.startCol,
      endRow: endRow ?? this.endRow,
      endCol: endCol ?? this.endCol,
    );
  }
}
