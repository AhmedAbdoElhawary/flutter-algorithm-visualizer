import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeCategoryGrid extends ConsumerWidget {
  const HomeCategoryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(homeDataProvider.select((s) => s.categoryItems));

    if (categories.isEmpty) return const SizedBox.shrink();

    final sortingCardValues = SortingAlgoCards.values;
    final searchingCardValues = SearchingAlgoCards.values;

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      bottomPadding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoldText(StringsManager.topics, fontSize: 15, color: ThemeEnum.textPrimary),
          SizedBox(height: 12.h),
          GridView.builder(
            itemCount: 6,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.r,
              mainAxisSpacing: 16.r,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (context, index) {
              final Widget child;
              final String name;
              if (index < 3) {
                final cardSorting = BaseViewModel.sortingCards(sortingCardValues[index]);
                child = cardSorting.card;
                name = cardSorting.page.name;
              } else {
                final i = index - 3;
                final cardSearching = BaseViewModel.searchingCards(searchingCardValues[i]);
                child = cardSearching.card;
                name = cardSearching.page.name;
              }

              return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  highlightColor: context.getColor(ThemeEnum.primary),
                  onTap: () {
                    context.pushTo(Routes.visualize, queryParameters: name);
                  },
                  child: child);
            },
          ),
        ],
      ),
    );
  }
}
