import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/searching/base/view/searching_view.dart';
import 'package:flutter/material.dart';

class BFSSearchingPage extends StatelessWidget {
  const BFSSearchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchingView(card: SearchingAlgoCards.bfs);
  }
}
