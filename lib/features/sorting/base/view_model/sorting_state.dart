part of 'sorting_notifier.dart';

class SortingNotifierState {
  final List<SortableItem> list;
  final Map<int, Offset> positions;
  final PlaybackSpeed speed;
  final int size;
  final SortingEnum operationStatus;

  final int currentStepIndex;

  // Auto-play progress
  final int totalPlaySteps;
  final List<SortingStep> sortedSteps;

  final int currentCodeLine;

  SortingNotifierState({
    this.operationStatus = SortingEnum.none,
    this.size = SortingNotifier._defaultSize,
    this.speed = PlaybackSpeed.normal,
    required this.list,
    this.positions = const {},
    this.sortedSteps = const [],
    this.currentStepIndex = 0,
    this.totalPlaySteps = 0,
    this.currentCodeLine = -1,
  });

  // ── Computed getters ────────────────────────────────────────────────────────

  bool get isPlaying => operationStatus == SortingEnum.played;
  bool get isAtFirstStep => currentStepIndex == 0;
  bool get isAtLastStep => totalPlaySteps > 0 && currentStepIndex >= totalPlaySteps - 1;

  double get progressValue {
    return totalPlaySteps > 0 ? currentStepIndex / totalPlaySteps : 0.0;
  }

  String get progressLabel {
    if (totalPlaySteps > 0) return 'Step $currentStepIndex of $totalPlaySteps';
    return '';
  }

  SortingNotifierState copyWith({
    int? size,
    PlaybackSpeed? speed,
    List<SortableItem>? list,
    List<SortingStep>? sortedSteps,
    Map<int, Offset>? positions,
    SortingEnum? operationStatus,
    int? currentStepIndex,
    int? totalPlaySteps,
    int? currentCodeLine,
  }) {
    return SortingNotifierState(
      operationStatus: operationStatus ?? this.operationStatus,
      size: size ?? this.size,
      speed: speed ?? this.speed,
      list: list ?? this.list,
      positions: positions ?? this.positions,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      totalPlaySteps: totalPlaySteps ?? this.totalPlaySteps,
      currentCodeLine: currentCodeLine ?? this.currentCodeLine,
      sortedSteps: sortedSteps ?? this.sortedSteps,
    );
  }
}
