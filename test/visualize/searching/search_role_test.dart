import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/search_role.dart';
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
      expect(searchRoleColor(SearchRole.start), ThemeEnum.searchStart);
      expect(searchRoleColor(SearchRole.end), ThemeEnum.searchEnd);
      expect(searchRoleColor(SearchRole.searcher), ThemeEnum.searchSearcher);
      expect(searchRoleColor(SearchRole.visited), ThemeEnum.searchVisited);
      expect(searchRoleColor(SearchRole.path), ThemeEnum.searchPath);
      expect(searchRoleColor(SearchRole.wall), ThemeEnum.searchWall);
    });

    test('path is the only role carrying its own dedicated amber (C3, C4, SC-014)', () {
      final amber = SearchRole.values.where((r) => searchRoleColor(r) == ThemeEnum.searchPath).toSet();

      expect(amber, {SearchRole.path});
    });
    // difficultyEasy (ThemeEnum.dataEasy) is no longer used for any grid state
    // — search roles now have their own dedicated search* colors (C4).
    test('none of the six roles borrow a data* role any more (C4)', () {
      const dataRoles = {
        ThemeEnum.dataEasy,
        ThemeEnum.dataMedium,
        ThemeEnum.dataHard,
        ThemeEnum.dataTarget,
        ThemeEnum.dataActive,
      };
      for (final role in SearchRole.values) {
        expect(dataRoles.contains(searchRoleColor(role)), isFalse);
      }
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

    test('is ordered start, visited, searcher, wall, path, end (legend display order)', () {
      expect(kSearchRolePriority, [
        SearchRole.start,
        SearchRole.visited,
        SearchRole.searcher,
        SearchRole.wall,
        SearchRole.path,
        SearchRole.end,
      ]);
    });
  });
}
