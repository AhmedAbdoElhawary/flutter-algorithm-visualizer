import 'package:algorithm_visualizer/core/widgets/adaptive/ltr_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('code stays left to right inside a right-to-left app', (tester) async {
    late TextDirection inside;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: LtrContent(
          child: Builder(
            builder: (context) {
              inside = Directionality.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(inside, TextDirection.ltr);
  });
}
