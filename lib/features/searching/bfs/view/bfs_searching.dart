import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/visualize/view/visualize_page.dart';
import 'package:flutter/material.dart';

class BFSSearchingPage extends StatelessWidget {
  const BFSSearchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VisualizePage(searchingCard: SearchingAlgoCards.bfs);
  }
}
