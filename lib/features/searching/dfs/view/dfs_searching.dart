import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/searching/base/view/searching_page.dart';
import 'package:flutter/material.dart';

class DFSSearchingPage extends StatelessWidget {
  const DFSSearchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final instance = BaseViewModel.baseCategory.searchingCards[StringsManager.dFS]!.instance;
    return VisualizerScreen(instance: instance, title: StringsManager.dFS);
  }
}
