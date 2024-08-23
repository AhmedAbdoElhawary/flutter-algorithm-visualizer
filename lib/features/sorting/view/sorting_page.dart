import 'package:algorithm_visualizer/core/helpers/random_int.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_dialog.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SortingPage extends StatelessWidget {
  const SortingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final list = CustomRandom.generateRandomList(150, 70);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              return TextButton(
                onPressed: () {
                  CustomAlertDialog(context).solidDialog(
                    parameters: [
                      ListDialogParameters(
                        text: StringsManager.generateMaze,
                        onTap: () {},
                      ),
                      ListDialogParameters(
                        text: "Dijkstra",
                        onTap: () {},
                      ),
                      ListDialogParameters(
                        text: "BFS",
                        onTap: () {},
                      ),
                      ListDialogParameters(
                        text: StringsManager.clearPath,
                        color: ThemeEnum.redColor,
                        onTap: () {},
                      ),
                      ListDialogParameters(
                        text: StringsManager.clearAll,
                        color: ThemeEnum.redColor,
                        onTap: () {},
                      ),
                    ],
                  );
                },
                child: const CustomIcon(Icons.menu_rounded),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: REdgeInsets.only(top: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            list.length,
            (index) => Flexible(
              child: Container(
                margin: REdgeInsets.symmetric(horizontal: 1),
                height: (1 + (list[index])).toDouble(),
                decoration: BoxDecoration(
                  color: context.getColor(ThemeEnum.darkBlueColor),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
