import 'package:algorithm_visualizer/core/widgets/custom_widgets/tag_chip.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows its label', (tester) async {
    await pumpApp(tester, const TagChip(label: 'Hash Map'));

    expect(find.text('Hash Map'), findsOneWidget);
  });
}
