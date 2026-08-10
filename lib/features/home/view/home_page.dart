import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/helpers/screen_size.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'movable_pins.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final controller = TabController(length: 2, vsync: this);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScreenSize.initContext(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardValues = BaseViewModel.baseCategory.sortingCards.values.toList();
    final searchingCardValues = BaseViewModel.baseCategory.searchingCards.values.toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: MovablePinsBackground(
            pinColor: ThemeEnum.whiteD4Color,
            child: DefaultTabController(
              length: 2,
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    shadowColor: ColorManager.transparent,
                    backgroundColor: context.getColor(ThemeEnum.primaryColor).withValues(alpha: 0.7),
                    title: Padding(
                      padding: REdgeInsets.symmetric(horizontal: 20),
                      child: _TabView(controller),
                    ),
                  ),
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: controller,
                      children: [
                        GridView.builder(
                          itemCount: BaseViewModel.baseCategory.sortingCards.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.1,
                          ),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: REdgeInsetsDirectional.only(
                                  start: index % 2 == 0 ? 20 : 0, end: index % 2 != 0 ? 20 : 0),
                              child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  highlightColor: context.getColor(ThemeEnum.primaryColor),
                                  onTap: () {
                                    context.pushTo(cardValues[index].route);
                                  },
                                  child: cardValues[index].card),
                            );
                          },
                        ),
                        GridView.builder(
                          itemCount: BaseViewModel.baseCategory.searchingCards.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.1,
                          ),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: REdgeInsetsDirectional.only(
                                  start: index % 2 == 0 ? 20 : 0, end: index % 2 != 0 ? 20 : 0),
                              child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  highlightColor: context.getColor(ThemeEnum.primaryColor),
                                  onTap: () {
                                    context.pushTo(searchingCardValues[index].route);
                                  },
                                  child: searchingCardValues[index].card),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabView extends StatefulWidget {
  const _TabView(this.controller);
  final TabController controller;

  @override
  State<_TabView> createState() => _TabViewState();
}

class _TabViewState extends State<_TabView> {
  int value = 0;
  @override
  void initState() {
    widget.controller.addListener(listener);
    super.initState();
  }

  void listener() {
    final currentIndex = widget.controller.index;
    if (currentIndex != value) {
      setState(() {
        value = currentIndex;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text1Color = value == 0 ? ThemeEnum.mainDarkColor : ThemeEnum.textDarkColor;
    final text2Color = value == 1 ? ThemeEnum.mainDarkColor : ThemeEnum.textDarkColor;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            highlightColor: context.getColor(ThemeEnum.primaryColor),
            onTap: () {
              widget.controller.animateTo(0);
            },
            child: GlassContainer(
              borderRadius: 10,
              withAboveShadow: false,
              highlightCard: value == 0,
              padding: REdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Center(
                child: BoldText(StringsManager.sorting, fontSize: 14, color: text1Color),
              ),
            ),
          ),
        ),
        RSizedBox(width: 20),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            highlightColor: context.getColor(ThemeEnum.primaryColor),
            onTap: () {
              widget.controller.animateTo(1);
            },
            child: GlassContainer(
              borderRadius: 10,
              withAboveShadow: false,
              highlightCard: value == 1,
              padding: REdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Center(
                child: BoldText(StringsManager.searching, fontSize: 14, color: text2Color),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
