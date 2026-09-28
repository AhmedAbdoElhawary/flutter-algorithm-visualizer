import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('padding grows with the screen, as every size in the app does', (tester) async {
    // A screen twice the width and height of the design doubles every padding.
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => const Directionality(
          textDirection: TextDirection.ltr,
          child: AllPadding(padding: 8, child: SizedBox()),
        ),
      ),
    );

    final padding = tester.widget<Padding>(find.byType(Padding)).padding;
    expect(padding.resolve(TextDirection.ltr), const EdgeInsets.all(16));
  });
}
