import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/quiet_progress_bar.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_difficulty_progress.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../profile_test_data.dart';

void main() {
  List<double> bars(WidgetTester tester) =>
      tester.widgetList<QuietProgressBar>(find.byType(QuietProgressBar)).map((bar) => bar.value).toList();

  testWidgets('no problems shows empty bars, not a division by zero', (tester) async {
    await pumpProfileWidget(tester, const ProfileDifficultyProgress());

    expect(find.text(' / 0', findRichText: true), findsNothing);
    expect(find.text('0 / 0', findRichText: true), findsNWidgets(3));
    expect(bars(tester), [0, 0, 0]);
  });

  testWidgets('each difficulty shows solved over total, and its bar fills to match', (tester) async {
    await pumpProfileWidget(tester, const ProfileDifficultyProgress(), list: fullProfile());

    expect(find.text(StringsManager.easy), findsOneWidget);
    expect(find.text('1 / 2', findRichText: true), findsOneWidget);
    expect(find.text('1 / 1', findRichText: true), findsOneWidget);
    expect(find.text('0 / 1', findRichText: true), findsOneWidget);
    expect(bars(tester), [0.5, 1, 0]);
  });

  testWidgets('the title takes the colour it is given', (tester) async {
    await pumpProfileWidget(tester, const ProfileDifficultyProgress(titleColor: ThemeEnum.inkTitle));

    expect(tester.widget<ProfileDifficultyProgress>(find.byType(ProfileDifficultyProgress)).titleColor,
        ThemeEnum.inkTitle);
    expect(find.text(StringsManager.difficultyProgress), findsOneWidget);
  });

  testWidgets('fits a small screen with large text', (tester) async {
    await pumpProfileWidget(tester, const ProfileDifficultyProgress(),
        list: fullProfile(), screen: ScreenSize.smallPhone, textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
