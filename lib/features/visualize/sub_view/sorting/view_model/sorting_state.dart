part of 'sorting_notifier.dart';

class SortingNotifierState {
  final List<SortableItem> list;
  final Map<int, Offset> positions;
  final PlaybackSpeed speed;
  final int size;
  final SortingEnum operationStatus;

  final int currentStepIndex;

  final int totalPlaySteps;
  final List<SortStep> sortedSteps;

  final SortStep? currentStep;
  final bool isAllSorted;
  final List<SortRole> rolePerIndex;
  SortingNotifierState({
    this.operationStatus = SortingEnum.none,
    this.size = SortingNotifier._defaultSize,
    this.speed = PlaybackSpeed.normal,
    required this.list,
    this.isAllSorted = false,
    this.positions = const {},
    this.sortedSteps = const [],
    this.currentStepIndex = 0,
    this.totalPlaySteps = 0,
    this.currentStep,
    this.rolePerIndex = const [],
  });

  bool get isPlaying => operationStatus == SortingEnum.played;
  bool get isAtFirstStep => currentStepIndex == 0;
  bool get isAtLastStep => totalPlaySteps > 0 && currentStepIndex >= totalPlaySteps;

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
    List<SortStep>? sortedSteps,
    Map<int, Offset>? positions,
    SortingEnum? operationStatus,
    int? currentStepIndex,
    int? totalPlaySteps,
    SortStep? currentStep,
    bool clearCurrentStep = false,
    bool? isAllSorted,
    List<SortRole>? rolePerIndex,
  }) {
    return SortingNotifierState(
      isAllSorted: isAllSorted ?? this.isAllSorted,
      operationStatus: operationStatus ?? this.operationStatus,
      size: size ?? this.size,
      speed: speed ?? this.speed,
      list: list ?? this.list,
      positions: positions ?? this.positions,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      totalPlaySteps: totalPlaySteps ?? this.totalPlaySteps,
      currentStep: clearCurrentStep ? null : (currentStep ?? this.currentStep),
      sortedSteps: sortedSteps ?? this.sortedSteps,
      rolePerIndex: rolePerIndex ?? this.rolePerIndex,
    );
  }
}
