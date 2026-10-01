import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/complexity_details.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  AlgorithmComplexity complexity({required bool stable}) => AlgorithmComplexity(
        name: 'Merge Sort',
        bestTimeComplexity: ONotationComplexity.nLogN,
        averageTimeComplexity: ONotationComplexity.nLogN,
        worstTimeComplexity: ONotationComplexity.n2,
        spaceComplexity: ONotationComplexity.n,
        stable: stable,
      );

  testWidgets('shows the worst time, the space and whether it is stable', (tester) async {
    await pumpApp(tester, ComplexityDetails(complexity: complexity(stable: true)));

    expect(find.text(StringsManager.time), findsOneWidget);
    expect(find.text('O(n²)'), findsOneWidget);
    expect(find.text(StringsManager.space), findsOneWidget);
    expect(find.text('O(n)'), findsOneWidget);
    expect(find.text(StringsManager.yes), findsOneWidget);
  });

  testWidgets('an unstable sort says no', (tester) async {
    await pumpApp(tester, ComplexityDetails(complexity: complexity(stable: false)));

    expect(find.text(StringsManager.no), findsOneWidget);
  });

  testWidgets('scrolls sideways instead of overflowing a small screen with large text', (tester) async {
    await pumpApp(
      tester,
      ComplexityDetails(complexity: complexity(stable: true)),
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
