import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/end_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a target of three rings, outer to inner', (tester) async {
    await tester.pumpWidget(
      const Center(
        child: PFEndPointWidget(size: 30, outerColor: Colors.red, midColor: Colors.white, innerColor: Colors.blue),
      ),
    );

    expect(tester.getSize(find.byType(PFEndPointWidget)), const Size(30, 30));
    expect(
      find.byType(PFEndPointWidget),
      paints
        ..circle(color: Colors.red)
        ..circle(color: Colors.white)
        ..circle(color: Colors.blue),
    );
  });
}
