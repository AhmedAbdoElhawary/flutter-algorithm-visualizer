import 'package:algorithm_visualizer/core/helpers/screen_size.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:async/async.dart';

//SortingAlgorithm
class SortableItem {
  final int id;
  final int value;

  SortableItem(this.id, this.value);
}
//
// class SortingOperations {
//   List<SortableItem> _unSortableList = [];
//   Map<int, Offset> _positions = {};
//   int _i = 0;
//   int _j = 0;
//
//   bool Function()? cancelCondition;
//   Future Function(Map<int, Offset> positions, List<SortableItem> unSortableList)?
//       afterEverySortingStepCallback;
//
//   SortingOperations({
//     required Map<int, Offset> positions,
//     this.afterEverySortingStepCallback,
//     this.cancelCondition,
//     required List<SortableItem> unSortableList,
//   }) {
//     _unSortableList = List<SortableItem>.from(unSortableList);
//     _positions = Map<int, Offset>.from(positions);
//   }
//
//   Future<void> bubbleSort() async {
//     for (_i = 0; _i < _unSortableList.length - 1; _i++) {
//       if (cancelCondition?.call() == true) return;
//
//       for (_j = 0; _j < _unSortableList.length - _i - 1; _j++) {
//         if (cancelCondition?.call() == true) return;
//
//         if (_unSortableList[_j].value > _unSortableList[_j + 1].value) {
//           _unSortableList.swap(_j, _j + 1);
//
//           final tempPosition = _positions[_unSortableList[_j].id]!;
//           _positions[_unSortableList[_j].id] = _positions[_unSortableList[_j + 1].id]!;
//           _positions[_unSortableList[_j + 1].id] = tempPosition;
//
//           afterEverySortingStepCallback?.call(_positions, _unSortableList);
//           // state = state.copyWith(_unSortableList: _unSortableList, positions: positions);
//           // await Future.delayed(swipeDuration);
//         }
//       }
//     }
//   }
//
//   void reset() {
//     _unSortableList = [];
//     _positions = {};
//     _i = 0;
//     _j = 0;
//   }
// }
