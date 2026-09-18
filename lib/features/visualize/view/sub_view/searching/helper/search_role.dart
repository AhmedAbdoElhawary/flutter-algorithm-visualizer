import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';

/// The six meanings a grid cell can carry.
///
/// [searcher] is the cell the algorithm is expanding *right now* — not the
/// whole frontier set. Every expanded cell is painted in the searcher colour
/// first and fades to [visited] over its own animation, so the bright colour
/// is only ever on the newest cell and leaves a fading trail behind it.
///
/// These used to borrow the `data*` roles the sorting bars use, which put the
/// searcher on [ThemeEnum.dataActive] — an alias for [ThemeEnum.inkPrimary],
/// so the advancing edge was pure white in dark mode and near-black in light,
/// indistinguishable from a wall. They now have their own `search*` roles,
/// separated by hue and lightness so all six read apart at cell size.
enum SearchRole { wall, searcher, visited, path, start, end }

/// Total, single-valued, exhaustive — no `default`, no fallback.
ThemeEnum searchRoleColor(SearchRole role) {
  switch (role) {
    case SearchRole.start:
      return ThemeEnum.searchStart;
    case SearchRole.end:
      return ThemeEnum.searchEnd;
    case SearchRole.searcher:
      return ThemeEnum.searchSearcher;
    case SearchRole.visited:
      return ThemeEnum.searchVisited;
    // Amber, not green: the path is always drawn on top of the blue visited
    // cells that found it, and a warm hue is what survives that overlap.
    case SearchRole.path:
      return ThemeEnum.searchPath;
    case SearchRole.wall:
      return ThemeEnum.searchWall;
  }
}

/// Total, centralized — every string is a [StringsManager] constant.
String searchRoleLabel(SearchRole role) {
  switch (role) {
    case SearchRole.start:
      return StringsManager.searchRoleStart;
    case SearchRole.end:
      return StringsManager.searchRoleEnd;
    case SearchRole.searcher:
      return StringsManager.searchRoleSearcher;
    case SearchRole.visited:
      return StringsManager.searchRoleVisited;
    case SearchRole.path:
      return StringsManager.searchRolePath;
    case SearchRole.wall:
      return StringsManager.searchRoleWall;
  }
}

/// Display order for the legend. The painter does NOT use this order directly
/// for color precedence — it special-cases [SearchRole.path] to win over
/// every other role first (see `_roleFor` in `pf_grid_painter.dart`), so the
/// answer stays visible over the exploration that found it, regardless of
/// where `path` sits in this list.
const List<SearchRole> kSearchRolePriority = [
  SearchRole.start,
  SearchRole.visited,
  SearchRole.searcher,
  SearchRole.wall,
  SearchRole.path,
  SearchRole.end,
];
