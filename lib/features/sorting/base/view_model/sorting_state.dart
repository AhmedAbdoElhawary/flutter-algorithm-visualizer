part of 'sorting_notifier.dart';

class SortingNotifierState {
  final List<SortableItem> list;
  final Map<int, Offset> positions;
  final Duration swipeDuration;
  final int size;
  final SortingEnum operationStatus;

  // Step-by-step
  final List<List<SortableItem>> stepSnapshots;
  final List<Map<int, Offset>> positionSnapshots;
  final List<int> codeLineSnapshots; // parallel to stepSnapshots
  final int currentStepIndex;

  // Auto-play progress
  final int currentPlayStep;
  final int totalPlaySteps;

  // Live code tracking (-1 = nothing highlighted)
  final int currentCodeLine;

  SortingNotifierState({
    this.operationStatus = SortingEnum.none,
    this.size = SortingNotifier._defaultSize,
    this.swipeDuration = SortingNotifier._defaultSpeedDuration,
    required this.list,
    this.positions = const {},
    this.stepSnapshots = const [],
    this.positionSnapshots = const [],
    this.codeLineSnapshots = const [],
    this.currentStepIndex = -1,
    this.currentPlayStep = 0,
    this.totalPlaySteps = 0,
    this.currentCodeLine = -1,
  });

  // ── Computed getters ────────────────────────────────────────────────────────

  bool get isPlaying => operationStatus == SortingEnum.played;
  bool get isInStepMode => stepSnapshots.isNotEmpty;
  bool get isAtLastStep =>
      isInStepMode && currentStepIndex == stepSnapshots.length - 1;
  bool get isAtFirstStep => isInStepMode && currentStepIndex == 0;

  /// 0.0 → 1.0. Works for both step mode and auto-play.
  double get progressValue {
    if (isInStepMode) {
      final total = stepSnapshots.length - 1;
      return total > 0 ? currentStepIndex / total : 0.0;
    }
    return totalPlaySteps > 0 ? currentPlayStep / totalPlaySteps : 0.0;
  }

  /// Human-readable label shown next to the progress bar.
  String get progressLabel {
    if (isInStepMode) {
      final total = stepSnapshots.length - 1;
      return 'Step $currentStepIndex of $total';
    }
    if (totalPlaySteps > 0) return 'Step $currentPlayStep of $totalPlaySteps';
    return '';
  }

  /// Text shown in the status banner.
  String get statusText {
    if (isAtLastStep || (isPlaying == false && progressValue == 1.0)) {
      return 'Array is fully sorted! 🎉';
    }
    if (isPlaying) return 'Sorting in progress…';
    if (operationStatus == SortingEnum.stopped) return 'Paused — step through or resume';
    if (isInStepMode) return 'Stepping through the algorithm';
    return 'Ready to sort';
  }

  // ── copyWith ────────────────────────────────────────────────────────────────

  SortingNotifierState copyWith({
    int? size,
    Duration? swipeDuration,
    List<SortableItem>? list,
    Map<int, Offset>? positions,
    SortingEnum? operationStatus,
    List<List<SortableItem>>? stepSnapshots,
    List<Map<int, Offset>>? positionSnapshots,
    List<int>? codeLineSnapshots,
    int? currentStepIndex,
    int? currentPlayStep,
    int? totalPlaySteps,
    int? currentCodeLine,
  }) {
    return SortingNotifierState(
      operationStatus: operationStatus ?? this.operationStatus,
      size: size ?? this.size,
      swipeDuration: swipeDuration ?? this.swipeDuration,
      list: list ?? this.list,
      positions: positions ?? this.positions,
      stepSnapshots: stepSnapshots ?? this.stepSnapshots,
      positionSnapshots: positionSnapshots ?? this.positionSnapshots,
      codeLineSnapshots: codeLineSnapshots ?? this.codeLineSnapshots,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      currentPlayStep: currentPlayStep ?? this.currentPlayStep,
      totalPlaySteps: totalPlaySteps ?? this.totalPlaySteps,
      currentCodeLine: currentCodeLine ?? this.currentCodeLine,
    );
  }
}