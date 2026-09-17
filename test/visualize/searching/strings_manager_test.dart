import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/search_role.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every searching constant this feature added, keyed by name so a failure
/// says which one is at fault.
const _roleLabels = <String, String>{
  'searchRoleStart': StringsManager.searchRoleStart,
  'searchRoleEnd': StringsManager.searchRoleEnd,
  'searchRoleFrontier': StringsManager.searchRoleFrontier,
  'searchRoleVisited': StringsManager.searchRoleVisited,
  'searchRolePath': StringsManager.searchRolePath,
  'searchRoleWall': StringsManager.searchRoleWall,
};

const _rulePhrases = <String, String>{
  'searchRuleOldestFirst': StringsManager.searchRuleOldestFirst,
  'searchRuleNewestFirst': StringsManager.searchRuleNewestFirst,
  'searchRuleCheapestFirst': StringsManager.searchRuleCheapestFirst,
};

const _statusText = <String, String>{
  'searchWaiting': StringsManager.searchWaiting,
  'searchDepth': StringsManager.searchDepth,
  'searchCost': StringsManager.searchCost,
  'searchToGo': StringsManager.searchToGo,
  'searchPathFound': StringsManager.searchPathFound,
  'searchStepsSuffix': StringsManager.searchStepsSuffix,
  'searchNotShortest': StringsManager.searchNotShortest,
  'searchNoPath': StringsManager.searchNoPath,
  'searchPreRunHint': StringsManager.searchPreRunHint,
  'searchStepCounterTemplate': StringsManager.searchStepCounterTemplate,
  'clearWalls': StringsManager.clearWalls,
  'randomWalls': StringsManager.randomWalls,
};

void main() {
  group('the searching constants are present and non-empty (FR-033)', () {
    for (final group in [_roleLabels, _rulePhrases, _statusText]) {
      for (final entry in group.entries) {
        test('${entry.key} holds text', () {
          expect(entry.value.trim(), isNotEmpty);
        });
      }
    }
  });

  group('uniqueness', () {
    test('the six role labels are pairwise distinct', () {
      expect(_roleLabels.values.toSet(), hasLength(_roleLabels.length));
    });

    test('the three rule phrases are pairwise distinct', () {
      expect(_rulePhrases.values.toSet(), hasLength(_rulePhrases.length));
    });

    test('the two wall-button tooltips are distinct', () {
      expect(StringsManager.clearWalls, isNot(StringsManager.randomWalls));
    });
  });

  group('wiring', () {
    test('every SearchRole label is one of the six constants', () {
      for (final role in SearchRole.values) {
        expect(_roleLabels.values, contains(searchRoleLabel(role)));
      }
    });

    test('the step counter template carries both placeholders', () {
      expect(StringsManager.searchStepCounterTemplate, contains('{current}'));
      expect(StringsManager.searchStepCounterTemplate, contains('{total}'));
    });

    test('the counter template renders with both placeholders substituted', () {
      final rendered = StringsManager.searchStepCounterTemplate
          .replaceFirst('{current}', '3')
          .replaceFirst('{total}', '40');

      expect(rendered, 'Step 3 of 40');
      expect(rendered, isNot(contains('{')));
    });
  });
}
