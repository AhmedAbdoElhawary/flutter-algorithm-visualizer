import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_control_interface.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_description_interface.dart';
import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part '../helper/sortable_item.dart';
part '../helper/sorting_enums.dart';
part '../helper/sort_role.dart';
part '../helper/sort_step.dart';
part '../helper/sorting_status_text.dart';
part 'sorting_state.dart';

class _SortSnapshot {
  final List<SortableItem> list;
  final Map<int, Offset> positions;
  final List<SortRole> rolePerIndex;

  const _SortSnapshot(this.list, this.positions, this.rolePerIndex);
}

abstract class SortingNotifier extends Notifier<SortingNotifierState>
    implements AlgorithmDescriptionNotifier, AlgorithmControlInterface {
  @visibleForTesting
  static List<SortableItem>? debugInitialListOverride;

  static SortingNotifierState initState({List<SortableItem>? initialList}) {
    final list = initialList ?? debugInitialListOverride ?? _generateList(_defaultSize);
    final positions = _computeInitialPositions(list, _defaultSize);
    return SortingNotifierState(
        list: list, positions: positions, rolePerIndex: List.filled(list.length, SortRole.idle));
  }

  @override
  SortingNotifierState build() {
    _snapshots = [];

    /// The provider is auto-disposing now (see [BaseViewModel.sortingCards]),
    /// so it can be torn down mid-animation — leaving the visualize tab is
    /// enough. The play loops below `await` between every frame, and writing
    /// `state` after disposal throws, so they check this flag after each gap.
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    return initState();
  }

  bool _disposed = false;

  /// Whether this notifier has been torn down. Callers holding a direct
  /// reference (the views keep one so they can pause from `dispose()`) must
  /// check this before touching the notifier.
  bool get isDisposed => _disposed;

  Set<SortRole> get roles;

  Map<SortRole, String> get pointerHints => const {};

  /// todo: add this feature that use dynamic size
  static const int _defaultSize = 9;
  static const int _maxSize = 15;
  static const int _minSize = 5;
  static double itemsPadding = 8.w;
  static double horizontalInsidePadding = 120.r;
  static const double bottomInsidePadding = 15;
  static double handleCentralBars = horizontalInsidePadding / 4;

  List<_SortSnapshot> _snapshots = [];

  bool _isPlayingFun = false;

  int _selectedAlgorithmLength = 1;
  int get selectedAlgorithmLength => _selectedAlgorithmLength;
  set selectedAlgorithmLength(int value) {
    if (value == selectedAlgorithmLength) return;
    _selectedAlgorithmLength = value;
  }

  @override
  PlaybackSpeed get getSpeed => state.speed;

  @override
  bool get isPlaying => state.isPlaying;
  @override
  bool get backwardValidation => state.isAtFirstStep;
  @override
  bool get forwardValidation => state.isAtLastStep;

  static List<SortableItem> _generateList(int size) {
    return List.generate(size, (index) => SortableItem(id: index, value: index + 1))..shuffle();
  }

  static double calculateItemWidth(int size) {
    final screenWidth = ScreenUtil().screenWidth - horizontalInsidePadding;
    final availableWidth = screenWidth - (itemsPadding * (size - 1));
    return availableWidth / size > 0 ? availableWidth / size : 1.0;
  }

  static double get calculateMaxListItemHeight {
    final screenHeight = ScreenUtil().screenHeight * 0.27;
    return screenHeight > 0 ? screenHeight : 1.0;
  }

  /// Returns the bar's pixel [actualHeight] and the label to print above it.
  ///
  /// The label is the array [value] itself — it must never be derived from the
  /// rendered pixel height, or it drifts as bars shrink to fit a side-by-side
  /// comparison. Height is pixels; the label is data.
  static (double actualHeight, String writtenHeight) calculateItemHeight(
    int value,
    int size,
    int selectedAlgorithmsLength,
  ) {
    final scaledHeight = (calculateMaxListItemHeight / size) * (value + 1);
    final per = selectedAlgorithmsLength == 1
        ? 0.8
        : selectedAlgorithmsLength <= 2
            ? 0.9
            : selectedAlgorithmsLength <= 4
                ? 0.8
                : selectedAlgorithmsLength <= 6
                    ? 0.7
                    : 0.6;
    final height = scaledHeight.r / selectedAlgorithmsLength * (per - 0.15);
    return (height, '$value');
  }

  String getWrittenHeight(int value) => calculateItemHeight(value, _size, selectedAlgorithmLength).$2;

  /// [tr] is supplied by the widget that has a `BuildContext`; the notifier
  /// only passes it along, so nothing here depends on the widget tree.
  String statusText({
    required SortStep? currentStep,
    required List<SortableItem> list,
    Translator tr = noTranslation,
  }) {
    return buildStatusText(step: currentStep, list: list, isDone: state.isAllSorted, tr: tr);
  }

  @protected
  Duration get speedDuration => state.speed.stepSortingDuration;
  int get _size => state.size;

  SortingEnum get _getOperation => state.operationStatus;
  set _setOperation(SortingEnum value) => state = state.copyWith(operationStatus: value);

  void _initializePositions() {
    final positions = <int, Offset>{};
    final itemWidth = calculateItemWidth(_size);
    for (int i = 0; i < state.list.length; i++) {
      positions[state.list[i].id] = Offset(i * (itemWidth + itemsPadding), 0);
    }
    state = state.copyWith(
      isAllSorted: false,
      positions: positions,
      rolePerIndex: List.filled(state.list.length, SortRole.idle),
    );
    _snapshots = [];
  }

  static Map<int, Offset> _computeInitialPositions(List<SortableItem> list, int size) {
    final positions = <int, Offset>{};
    final itemWidth = calculateItemWidth(size);
    for (int i = 0; i < list.length; i++) {
      positions[list[i].id] = Offset(i * (itemWidth + itemsPadding), 0);
    }
    return positions;
  }

  @override
  void changeSpeed(PlaybackSpeed speed) {
    state = state.copyWith(isAllSorted: false, speed: speed);
  }

  void changeSize(double size) {
    if (_getOperation == SortingEnum.played) return;
    final newSize = _minSize + (_maxSize - _minSize) * size;
    state = state.copyWith(isAllSorted: false, size: newSize.toInt());
    reset();
  }

  Future<void> cancelSorting() async {
    state = state.copyWith(
      list: _generateList(_size),
      operationStatus: SortingEnum.none,
      clearCurrentStep: true,
      totalPlaySteps: 0,
      sortedSteps: [],
      currentStepIndex: 0,
      isAllSorted: false,
    );
    _snapshots = [];
    _initializePositions();
  }

  Future<void> _stopSorting() async {
    state = state.copyWith(operationStatus: SortingEnum.stopped);
  }

  Future<void> _playSorting() async {
    _setOperation = SortingEnum.played;
    await _startSelectedSorting();
  }

  @override
  Future<void> togglePlay() async {
    if (state.isAtLastStep) {
      await reset();

      _playSorting();

      return;
    }

    final isPlaying = state.isPlaying;
    state = state.copyWith(operationStatus: isPlaying ? SortingEnum.stopped : SortingEnum.played);
    isPlaying ? _stopSorting() : _playSorting();
  }

  @override
  Future<void> reset() async {
    state = state.copyWith(
      list: _generateList(_size),
      operationStatus: SortingEnum.none,
      clearCurrentStep: true,
      totalPlaySteps: 0,
      sortedSteps: [],
      currentStepIndex: 0,
      isAllSorted: false,
    );
    _snapshots = [];
    _initializePositions();
  }

  @protected
  void ensureStepsGenerated() {
    if (state.sortedSteps.isNotEmpty) return;

    final values = state.list.map((e) => e.value).toList();
    final steps = buildSorting(values).steps;

    _snapshots = _computeSnapshots(state.list, state.positions, steps);

    state = state.copyWith(sortedSteps: steps, totalPlaySteps: steps.length);
  }

  List<_SortSnapshot> _computeSnapshots(
    List<SortableItem> initialList,
    Map<int, Offset> initialPositions,
    List<SortStep> steps,
  ) {
    var list = List<SortableItem>.from(initialList);
    var positions = Map<int, Offset>.from(initialPositions);
    final itemWidth = calculateItemWidth(_size);

    final snapshots = <_SortSnapshot>[
      _SortSnapshot(List.of(list), positions, List.filled(list.length, SortRole.idle)),
    ];

    for (final step in steps) {
      switch (step.kind) {
        case StepKind.compare:
          break;

        case StepKind.swap:
          list = List.of(list)..swap(step.a, step.b);
          positions = Map<int, Offset>.from(positions);
          final idA = list[step.a].id;
          final idB = list[step.b].id;
          final temp = positions[idA]!;
          positions[idA] = positions[idB]!;
          positions[idB] = temp;
          break;

        case StepKind.write:
          final k = step.a;
          final source = step.source!;

          if (source != k) {
            final moved = list[source];
            final newList = List<SortableItem>.from(list);
            for (int idx = source; idx > k; idx--) {
              newList[idx] = newList[idx - 1];
            }
            newList[k] = moved;
            list = newList;

            positions = Map<int, Offset>.from(positions);
            for (int idx = k; idx <= source; idx++) {
              positions[list[idx].id] = Offset(idx * (itemWidth + itemsPadding), 0);
            }
          }
          break;
      }

      snapshots.add(_SortSnapshot(List.of(list), positions, _resolveRolePerIndex(step, list.length)));
    }

    return snapshots;
  }

  static List<SortRole> _resolveRolePerIndex(SortStep step, int length) {
    final marksPerIndex = List<Set<SortRole>>.generate(length, (_) => <SortRole>{});
    for (final mark in step.marks) {
      for (int i = mark.start; i <= mark.end && i < length; i++) {
        if (i >= 0) marksPerIndex[i].add(mark.role);
      }
    }
    return marksPerIndex.map(resolve).toList(growable: false);
  }

  @override
  void stepForward() {
    if (state.isPlaying) return;

    ensureStepsGenerated();

    final steps = state.sortedSteps;
    final next = state.currentStepIndex + 1;
    if (next > steps.length) return;

    final snapshot = _snapshots[next];
    state = state.copyWith(
      list: snapshot.list,
      positions: snapshot.positions,
      rolePerIndex: snapshot.rolePerIndex,
      currentStepIndex: next,
      currentStep: steps[next - 1],
    );

    if (next == steps.length) greenSortedItemsAsDone();
  }

  @override
  void stepBackward() {
    if (state.isPlaying) return;
    if (state.sortedSteps.isEmpty) return;

    final steps = state.sortedSteps;
    final prev = state.currentStepIndex - 1;
    if (prev < 0) return;

    final snapshot = _snapshots[prev];
    state = state.copyWith(
      list: snapshot.list,
      positions: snapshot.positions,
      rolePerIndex: snapshot.rolePerIndex,
      currentStepIndex: prev,
      currentStep: prev > 0 ? steps[prev - 1] : null,
      clearCurrentStep: prev == 0,
      isAllSorted: false,
    );
  }

  @protected
  Future<void> greenSortedItemsAsDone() async {
    if (_disposed) return;

    final rolePerIndex = List<SortRole>.filled(state.list.length, SortRole.idle);
    for (int i = 0; i < rolePerIndex.length; i++) {
      if (_disposed) return;
      rolePerIndex[i] = SortRole.sorted;
      state = state.copyWith(isAllSorted: true, rolePerIndex: List.of(rolePerIndex));
      await Future.delayed(state.speed.stepSortingDuration);
    }
  }

  Future<void> _startSelectedSorting() async {
    try {
      await updateVisualizeSorting();
    } catch (e) {
      debugPrint("something wrong with sorting: $e");
    }
  }

  @protected
  Future<void> updateVisualizeSorting() async {
    if (_isPlayingFun) return;
    _isPlayingFun = true;

    ensureStepsGenerated();
    final steps = state.sortedSteps;

    for (int i = state.currentStepIndex; i < steps.length; i++) {
      if (_disposed || _getOperation != SortingEnum.played) {
        _isPlayingFun = false;
        return;
      }

      final snapshot = _snapshots[i + 1];
      state = state.copyWith(
        list: snapshot.list,
        positions: snapshot.positions,
        rolePerIndex: snapshot.rolePerIndex,
        currentStep: steps[i],
        currentStepIndex: i + 1,
      );
      await Future.delayed(speedDuration);
    }

    if (_disposed) {
      _isPlayingFun = false;
      return;
    }

    state = state.copyWith(clearCurrentStep: true);
    await Future.delayed(speedDuration);
    await greenSortedItemsAsDone();
    _isPlayingFun = false;
  }

  SortingResult buildSorting(List<int> values);
}
