import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_title.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the name and the one-line description', (tester) async {
    await pumpApp(tester, const AlgorithmTitle(title: 'Bubble Sort', description: 'Swaps neighbours'));

    expect(find.text('Bubble Sort'), findsOneWidget);
    expect(find.text('Swaps neighbours'), findsOneWidget);
  });
}
