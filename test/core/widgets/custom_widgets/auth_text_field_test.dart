import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/ltr_content.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpField(WidgetTester tester, AuthTextField field) =>
      pumpApp(tester, Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: field)));

  ThemeEnum? prefixColor(WidgetTester tester) =>
      tester.widget<CustomIcon>(find.byType(CustomIcon).first).color;

  testWidgets('shows the label and the hint, and reports what is typed', (tester) async {
    final typed = <String>[];
    await pumpField(
      tester,
      AuthTextField(label: 'Email', hintText: 'you@example.com', onChanged: typed.add),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('you@example.com'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'a@b.co');
    expect(typed, ['a@b.co']);
  });

  testWidgets('focus lights the icon, and leaving dims it again', (tester) async {
    await pumpField(
      tester,
      const AuthTextField(label: 'Email', hintText: '', prefixIcon: Icons.mail_outline_rounded),
    );
    expect(prefixColor(tester), ThemeEnum.inkThirdTitle);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(prefixColor(tester), ThemeEnum.inkTitle);

    FocusManager.instance.primaryFocus!.unfocus();
    await tester.pump();
    expect(prefixColor(tester), ThemeEnum.inkThirdTitle);
  });

  testWidgets('an error shows under the field and turns the icon red', (tester) async {
    await pumpField(
      tester,
      const AuthTextField(
        label: 'Email',
        hintText: '',
        prefixIcon: Icons.mail_outline_rounded,
        errorText: 'Enter a valid email',
      ),
    );

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(prefixColor(tester), ThemeEnum.dataHard);
  });

  testWidgets('an empty error shows nothing', (tester) async {
    await pumpField(tester, const AuthTextField(label: 'Email', hintText: '', errorText: ''));

    expect(find.byType(TopPadding), findsNothing);
  });

  testWidgets('a password is hidden, and the eye asks to show it', (tester) async {
    var toggles = 0;
    await pumpField(
      tester,
      AuthTextField(
        label: 'Password',
        hintText: '',
        isPassword: true,
        onTogglePasswordVisibility: () => toggles++,
      ),
    );

    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    expect(toggles, 1);
  });

  testWidgets('a shown password is readable, and the eye offers to hide it', (tester) async {
    await pumpField(
      tester,
      const AuthTextField(label: 'Password', hintText: '', isPassword: true, isPasswordVisible: true),
    );

    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('emails and passwords stay left to right, names follow the page', (tester) async {
    await pumpField(
      tester,
      const AuthTextField(label: 'Email', hintText: '', keyboardType: TextInputType.emailAddress),
    );
    expect(find.byType(LtrContent), findsOneWidget);

    await pumpField(tester, const AuthTextField(label: 'Name', hintText: ''));
    expect(find.byType(LtrContent), findsNothing);
  });

  testWidgets('a focus node from outside is used, and left for its owner to dispose', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await pumpField(tester, AuthTextField(label: 'Email', hintText: '', focusNode: node));

    node.requestFocus();
    await tester.pump();

    expect(tester.widget<TextField>(find.byType(TextField)).focusNode, node);
    await pumpApp(tester, const SizedBox());
    expect(() => node.hasFocus, returnsNormally);
  });

  testWidgets('a widget next to the label is shown', (tester) async {
    await pumpField(
      tester,
      const AuthTextField(label: 'Password', hintText: '', trailingLabelWidget: Text('Forgot?')),
    );

    expect(find.text('Forgot?'), findsOneWidget);
  });
}
