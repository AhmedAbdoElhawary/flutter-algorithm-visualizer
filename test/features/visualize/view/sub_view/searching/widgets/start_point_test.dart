import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/start_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('an arrow of the given size and colour', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: PFStartPointWidget(size: 18, color: Colors.teal),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.arrow_forward_ios_rounded);
    expect(icon.size, 18);
    expect(icon.color, Colors.teal);
  });
}
