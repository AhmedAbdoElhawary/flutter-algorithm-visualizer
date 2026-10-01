import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/status_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  for (final (isCorrect, icon, color) in [
    (true, Icons.check_rounded, ThemeEnum.dataEasy),
    (false, Icons.close_rounded, ThemeEnum.dataHard),
  ]) {
    testWidgets(isCorrect ? 'a pass is a green tick' : 'a fail is a red cross', (tester) async {
      await pumpApp(tester, StatusBox(isCorrect: isCorrect));

      final drawn = tester.widget<Icon>(find.byType(Icon));
      expect(drawn.icon, icon);
      expect(drawn.color, tester.element(find.byType(Icon)).getColor(color));
    });
  }
}
