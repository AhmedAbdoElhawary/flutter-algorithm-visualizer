import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_page_view_model.dart';
import 'package:algorithm_visualizer/features/searching/base/view/visualizer_page.dart';
import 'package:flutter/material.dart';

class AStarSearchingPage extends StatelessWidget {
  const AStarSearchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final instance = BasePageViewModel.searchingCards[StringsManager.aStarSearch]!.instance;
    return VisualizerScreen(instance: instance, title: StringsManager.aStarSearch);
  }
}
