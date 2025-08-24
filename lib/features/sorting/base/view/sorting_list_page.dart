import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_rounded_elevated_button.dart';
import 'package:flutter/material.dart';

class SortingListPage extends StatelessWidget {
  const SortingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const InkWell(child: RegularText(StringsManager.sorting)),
      ),
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CustomButton(text: StringsManager.bubbleSort, route: Routes.bubbleSort),
              _CustomButton(text: StringsManager.insertionSort, route: Routes.insertionSort),
              _CustomButton(text: StringsManager.selectionSort, route: Routes.selectionSort),
              _CustomButton(text: StringsManager.mergeSort, route: Routes.mergeSort),
              _CustomButton(text: StringsManager.heapSort, route: Routes.heapSort),
              _CustomButton(text: StringsManager.quickSort, route: Routes.quickSort),
              _CustomButton(text: StringsManager.radixSort, route: Routes.radixSort),
              _CustomButton(text: StringsManager.shellSort, route: Routes.shellSort),
              _CustomButton(text: StringsManager.countingSort, route: Routes.countingSort),
              _CustomButton(text: StringsManager.bucketSort, route: Routes.bucketSort),
              _CustomButton(text: StringsManager.comparisonSort, route: Routes.comparisonSort),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomButton extends StatelessWidget {
  const _CustomButton({required this.text, required this.route});
  final String text;
  final RouteConfig route;
  @override
  Widget build(BuildContext context) {
    return CustomRoundedElevatedButton(
      fixedSize: 160,
      fitToContent: false,
      roundedRadius: 3,
      backgroundColor: ThemeEnum.whiteD5Color,
      child: FittedBox(child: RegularText(text)),
      onPressed: () {
        context.pushTo(route);
      },
    );
  }
}
