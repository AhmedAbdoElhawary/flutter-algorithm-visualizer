import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_category_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/screen_matrix.dart';

void main() {
  testScreenMatrix('shows all six topics without overflow', (tester, variant) async {
    await pumpApp(
      tester,
      const Scaffold(body: SingleChildScrollView(child: HomeCategoryGrid())),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.text(StringsManager.topics), findsOneWidget);
    for (final card in SortingAlgoCards.values.take(3)) {
      expect(find.text(BaseViewModel.sortingCards(card).card.algoComplexity.name), findsOneWidget);
    }
    for (final card in SearchingAlgoCards.values) {
      expect(find.text(BaseViewModel.searchingCards(card).card.algoComplexity.name), findsOneWidget);
    }
  });

  testWidgets('both cards in a row are the same height', (tester) async {
    await pumpApp(tester, const Scaffold(body: SingleChildScrollView(child: HomeCategoryGrid())),
        screen: ScreenSize.smallPhone);

    double heightOf(SortingAlgoCards card) => tester
        .getSize(
          find.ancestor(
            of: find.text(BaseViewModel.sortingCards(card).card.algoComplexity.name),
            matching: find.byType(AlgorithmGlassCard),
          ),
        )
        .height;

    expect(heightOf(SortingAlgoCards.bubble), heightOf(SortingAlgoCards.selection));
  });
}
