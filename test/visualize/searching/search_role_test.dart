import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/helper/search_role.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('searchRoleColor (C1)', () {
    test('is total over every SearchRole value', () {
      for (final role in SearchRole.values) {
        expect(searchRoleColor(role), isA<ThemeEnum>());
      }
    });

    test('the six roles resolve to six pairwise distinct ThemeEnum values (FR-024, SC-008)', () {
      final colors = SearchRole.values.map(searchRoleColor).toSet();

      expect(colors.length, SearchRole.values.length);
    });

    test('matches the normative role table (FR-023)', () {
      expect(searchRoleColor(SearchRole.start), ThemeEnum.barAnchor);
      expect(searchRoleColor(SearchRole.end), ThemeEnum.barSwap);
      expect(searchRoleColor(SearchRole.frontier), ThemeEnum.barCompare);
      expect(searchRoleColor(SearchRole.visited), ThemeEnum.barTarget);
      expect(searchRoleColor(SearchRole.path), ThemeEnum.barDone);
      expect(searchRoleColor(SearchRole.wall), ThemeEnum.borderStrong);
    });

    test('path is the only role carrying the success green (C3, C4, SC-014)', () {
      final green = SearchRole.values.where((r) => searchRoleColor(r) == ThemeEnum.barDone).toSet();

      expect(green, {SearchRole.path});
    });

    test('difficultyEasy is no longer used for any grid state (C4)', () {
      for (final role in SearchRole.values) {
        expect(searchRoleColor(role), isNot(ThemeEnum.difficultyEasy));
      }
    });

    test('green means the same thing here as in sorting — finished and correct (C3)', () {
      expect(searchRoleColor(SearchRole.path), roleColor(SortRole.sorted));
    });
  });

  group('searchRoleLabel (C2)', () {
    test('is total and no two roles share a label', () {
      final labels = <String>{};
      for (final role in SearchRole.values) {
        final label = searchRoleLabel(role);
        expect(label, isNotEmpty);
        expect(labels.add(label), isTrue, reason: '$role duplicates label "$label"');
      }
    });
  });

  group('kSearchRolePriority (R1–R4, G1, G5)', () {
    test('contains every SearchRole exactly once', () {
      expect(kSearchRolePriority.toSet(), SearchRole.values.toSet());
      expect(kSearchRolePriority.length, SearchRole.values.length);
    });

    test('is ordered path, frontier, visited, start, end, wall', () {
      expect(kSearchRolePriority, [
        SearchRole.path,
        SearchRole.frontier,
        SearchRole.visited,
        SearchRole.start,
        SearchRole.end,
        SearchRole.wall,
      ]);
    });

    test('path outranks visited, so the answer stays visible over the exploration (R1)', () {
      expect(
        kSearchRolePriority.indexOf(SearchRole.path),
        lessThan(kSearchRolePriority.indexOf(SearchRole.visited)),
      );
    });
  });
}
