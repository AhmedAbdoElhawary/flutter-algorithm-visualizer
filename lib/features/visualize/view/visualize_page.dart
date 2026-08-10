import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algo_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisualizePage extends StatefulWidget {
  const VisualizePage({super.key});

  @override
  State<VisualizePage> createState() => _VisualizePageState();
}

class _VisualizePageState extends State<VisualizePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            titleSpacing: 0,
            leadingWidth: 16.r,
            leading: SizedBox(),
            // title: AlgorithmTitle(title: title, description: description),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: REdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: AlgoTab(
                        isSelected: true,
                        addEndPadding: false,
                        label: StringsManager.sorting,
                        verticalPadding: 3,
                        icon: Icons.filter_list_rounded,
                      ),
                    ),
                  ),
                  RSizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: AlgoTab(
                        isSelected: false,
                        addEndPadding: false,
                        label: StringsManager.searching,
                        verticalPadding: 3,
                        icon: Icons.map_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            // child: ,
          ),
        ],
      ),
    );
  }
}
