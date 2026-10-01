import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/password_strength_meter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('the strength of a password', () {
    for (final (password, segments, caption) in [
      ('', 0, StringsManager.pwStrengthEmpty),
      ('abc', 1, '${StringsManager.pwStrengthWeak} · ${StringsManager.pwHintAddLength}'),
      ('abcdefgh', 1, '${StringsManager.pwStrengthWeak} · ${StringsManager.pwHintAddNumber}'),
      ('abcdefgh1', 2, '${StringsManager.pwStrengthFair} · ${StringsManager.pwHintAddCase}'),
      ('Abcdefgh1', 3, '${StringsManager.pwStrengthGood} · ${StringsManager.pwHintAddSymbol}'),
      ('Abcdefgh1!', 4, '${StringsManager.pwStrengthStrong} · ${StringsManager.pwHintStrongEnough}'),
      ('Abcdefghijk1!', 4, '${StringsManager.pwStrengthStrong} · ${StringsManager.pwHintStrongEnough}'),
      ('abcdefghijkl', 2, '${StringsManager.pwStrengthFair} · ${StringsManager.pwHintAddNumber}'),
    ]) {
      test('"$password" lights $segments', () {
        final strength = PasswordStrength.evaluate(password);

        expect(strength.filledSegments, segments);
        expect(strength.caption, caption);
      });
    }

    test('a short password is still told to grow first, whatever else it has', () {
      expect(PasswordStrength.evaluate('A1!').caption, endsWith(StringsManager.pwHintAddLength));
    });
  });

  testWidgets('lights as many of the four segments as the strength, caption under them', (tester) async {
    await pumpApp(tester, const PasswordStrengthMeter(password: 'Abcdefgh1'));
    final context = tester.element(find.byType(PasswordStrengthMeter));

    final segments = tester
        .widgetList<Container>(find.descendant(of: find.byType(Row), matching: find.byType(Container)))
        .map((segment) => (segment.decoration! as BoxDecoration).color)
        .toList();
    final lit = context.getColor(ThemeEnum.dataEasy);
    final off = context.getColor(ThemeEnum.surface);
    expect(segments, [lit, lit, lit, off]);
    const caption = '${StringsManager.pwStrengthGood} · ${StringsManager.pwHintAddSymbol}';
    expect(find.text(caption), findsOneWidget);
  });
}
