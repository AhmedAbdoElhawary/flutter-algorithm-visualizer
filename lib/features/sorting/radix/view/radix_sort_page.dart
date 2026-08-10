import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_view.dart';
import 'package:flutter/material.dart';

class RadixSortPage extends StatelessWidget {
  const RadixSortPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SortingView(card: SortingAlgoCards.radix);
  }
}
