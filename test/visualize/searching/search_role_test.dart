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
      expect(searchRoleColor(SearchRole.start), ThemeEnum.dataMedium);
      expect(searchRoleColor(SearchRole.end), ThemeEnum.dataHard);
      expect(searchRoleColor(SearchRole.frontier), ThemeEnum.dataActive);
      expect(searchRoleColor(SearchRole.visited), ThemeEnum.dataTarget);
      expect(searchRoleColor(SearchRole.path), ThemeEnum.dataEasy);
      expect(searchRoleColor(SearchRole.wall), ThemeEnum.track);
    });

    test('path is the only role carrying the success green (C3, C4, SC-014)', () {
      final green = SearchRole.values.where((r) => searchRoleColor(r) == ThemeEnum.dataEasy).toSet();

      expect(green, {SearchRole.path});
    });
    // TODO: handle this case
    // test('difficultyEasy is no longer used for any grid state (C4)', () {
    //   for (final role in SearchRole.values) {
    //     expect(searchRoleColor(role), isNot(ThemeEnum.dataEasy));
    //   }
    // });

    test('green means the same thing here as in sorting — finished and correct (C3)', () {
      expect(searchRoleColor(SearchRole.path), sortingRoleColor(SortRole.sorted));
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

    test('is ordered start, visited, frontier, wall, path, end (legend display order)', () {
      expect(kSearchRolePriority, [
        SearchRole.start,
        SearchRole.visited,
        SearchRole.frontier,
        SearchRole.wall,
        SearchRole.path,
        SearchRole.end,
      ]);
    });
  });
}
