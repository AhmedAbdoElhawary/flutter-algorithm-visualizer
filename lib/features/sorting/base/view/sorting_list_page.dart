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
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomRoundedElevatedButton(
                roundedRadius: 3,
                backgroundColor: ThemeEnum.whiteD5Color,
                child: const RegularText(StringsManager.bubbleSort),
                onPressed: () {
                  context.pushTo(Routes.bubbleSort);
                },
              ),
              CustomRoundedElevatedButton(
                roundedRadius: 3,
                backgroundColor: ThemeEnum.whiteD5Color,
                child: const RegularText(StringsManager.insertionSort),
                onPressed: () {
                  context.pushTo(Routes.insertionSort);
                },
              ),
              CustomRoundedElevatedButton(
                roundedRadius: 3,
                backgroundColor: ThemeEnum.whiteD5Color,
                child: const RegularText(StringsManager.selectionSort),
                onPressed: () {
                  context.pushTo(Routes.selectionSort);
                },
              ),
              CustomRoundedElevatedButton(
                roundedRadius: 3,
                backgroundColor: ThemeEnum.whiteD5Color,
                child: const RegularText(StringsManager.mergeSort),
                onPressed: () {
                  context.pushTo(Routes.mergeSort);
                },
              ),
              CustomRoundedElevatedButton(
                roundedRadius: 3,
                backgroundColor: ThemeEnum.whiteD5Color,
                child: const RegularText(StringsManager.heapSort),
                onPressed: () {
                  context.pushTo(Routes.heapSort);
                },
              ),
              CustomRoundedElevatedButton(
                roundedRadius: 3,
                backgroundColor: ThemeEnum.whiteD5Color,
                child: const RegularText(StringsManager.quickSort),
                onPressed: () {
                  context.pushTo(Routes.quickSort);
                },
              ),
              CustomRoundedElevatedButton(
                roundedRadius: 3,
                backgroundColor: ThemeEnum.whiteD5Color,
                child: const RegularText(StringsManager.radixSort),
                onPressed: () {
                  context.pushTo(Routes.radixSort);
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
