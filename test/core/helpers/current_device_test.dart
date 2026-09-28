import 'package:algorithm_visualizer/core/helpers/current_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (platform, isAndroid) in [
    (TargetPlatform.android, true),
    (TargetPlatform.iOS, false),
  ]) {
    testWidgets('on ${platform.name}, isAndroid is $isAndroid', (tester) async {
      late bool result;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          home: Builder(
            builder: (context) {
              result = context.isAndroid;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result, isAndroid);
    });
  }
}
