import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/helpers/screen_size.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_page_view_model.dart';
import 'package:flutter/material.dart';

import 'movable_pins.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScreenSize.initContext(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: MovablePinsBackground(
            pinColor: ThemeEnum.whiteD4Color,
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverGrid.builder(
                  itemCount: BasePageViewModel.sortingCards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsetsDirectional.only(
                          start: index % 2 == 0 ? 20 : 0, end: index % 2 != 0 ? 20 : 0),
                      child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          highlightColor: context.getColor(ThemeEnum.primaryColor),
                          onTap: () {
                            context.pushTo(BasePageViewModel.sortingCards[index].route);
                          },
                          child: BasePageViewModel.sortingCards[index].card),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
