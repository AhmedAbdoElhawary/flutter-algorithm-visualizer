import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/section_header.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeCategoryGrid extends ConsumerWidget {
  const HomeCategoryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiles = [
      for (final card in SortingAlgoCards.values.take(3))
        _TopicTile(card: BaseViewModel.sortingCards(card).card, name: card.name),
      for (final card in SearchingAlgoCards.values)
        _TopicTile(card: BaseViewModel.searchingCards(card).card, name: card.name),
    ];

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      bottomPadding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: StringsManager.topics),
          const RSizedBox(height: 12),
          // Rows sized by their tallest card, not a fixed tile shape: the title wraps on narrow phones
          // and grows with the system text, and a fixed shape clipped it.
          for (var i = 0; i < tiles.length; i += 2) ...[
            if (i > 0) SizedBox(height: 16.r),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tiles[i]),
                  SizedBox(width: 16.r),
                  Expanded(child: tiles[i + 1]),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.card, required this.name});

  final Widget card;
  final String name;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: context.getColor(ThemeEnum.ground),
      onTap: () => context.goTo(Routes.visualize, queryParameters: name),
      child: card,
    );
  }
}
