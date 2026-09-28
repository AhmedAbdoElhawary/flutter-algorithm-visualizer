import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/small_stats_strip.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/stat_tile.dart';
import 'package:algorithm_visualizer/features/profile/domain/entities/profile_statistics.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final stats = ProfileStatistics(
    totalProblems: 40, solvedCount: 12, easySolved: 6, mediumSolved: 4, //
    hardSolved: 2, easyTotal: 20, mediumTotal: 15, hardTotal: 5, //
    totalAttempts: 30, correctAttempts: 20, accuracyRate: 0.666, //
    bookmarkedCount: 3, currentStreak: 5, bestStreak: 9, //
    weeklyActivity: List<int>.filled(7, 0), heatmapData: List<int>.filled(84, 0), //
    categorySolved: const {}, recentSubmissions: const [], practiceHistory: const [], //
  );

  Future<void> pumpStrip(WidgetTester tester, SmallStatsStrip strip) => pumpApp(
        tester,
        strip,
        overrides: [profileStatisticsProvider.overrideWithValue(stats)],
      );

  testWidgets('shows the streak, solved, accuracy and attempts', (tester) async {
    await pumpStrip(tester, const SmallStatsStrip());

    expect(find.byType(StatTile), findsNWidgets(4));
    expect(find.text('5'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.byType(Icon), findsNWidgets(4));
  });

  testWidgets('can leave out the attempts and the icons', (tester) async {
    await pumpStrip(tester, const SmallStatsStrip(showAttempts: false, showIcons: false));

    expect(find.byType(StatTile), findsNWidgets(3));
    expect(find.text(StringsManager.attempts), findsNothing);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('fits a small screen with large text', (tester) async {
    await pumpApp(
      tester,
      const SmallStatsStrip(),
      overrides: [profileStatisticsProvider.overrideWithValue(stats)],
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
