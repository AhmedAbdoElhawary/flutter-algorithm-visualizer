import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';

/// The six meanings a grid cell can carry, drawn from the same shared palette
/// the sorting bars use.
enum SearchRole { wall, frontier, visited, path, start, end }

/// Total, single-valued, exhaustive — no `default`, no fallback.
ThemeEnum searchRoleColor(SearchRole role) {
  switch (role) {
    case SearchRole.start:
      return ThemeEnum.barAnchor;
    case SearchRole.end:
      return ThemeEnum.barSwap;
    case SearchRole.frontier:
      return ThemeEnum.barCompare;
    case SearchRole.visited:
      return ThemeEnum.barTarget;
    case SearchRole.path:
      return ThemeEnum.barDone;
    case SearchRole.wall:
      return ThemeEnum.borderStrong;
  }
}

/// Total, centralized — every string is a [StringsManager] constant.
String searchRoleLabel(SearchRole role) {
  switch (role) {
    case SearchRole.start:
      return StringsManager.searchRoleStart;
    case SearchRole.end:
      return StringsManager.searchRoleEnd;
    case SearchRole.frontier:
      return StringsManager.searchRoleFrontier;
    case SearchRole.visited:
      return StringsManager.searchRoleVisited;
    case SearchRole.path:
      return StringsManager.searchRolePath;
    case SearchRole.wall:
      return StringsManager.searchRoleWall;
  }
}

/// Fixed precedence, shared by the painter and the legend so the two can never
/// disagree. [SearchRole.path] outranks everything so the answer stays visible
/// over the exploration that found it; [SearchRole.wall] is last because a wall
/// is never also a search state.
const List<SearchRole> kSearchRolePriority = [
  SearchRole.start,
  SearchRole.visited,
  SearchRole.frontier,
  SearchRole.wall,
  SearchRole.path,
  SearchRole.end,
];
