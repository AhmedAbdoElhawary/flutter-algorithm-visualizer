import 'package:algorithm_visualizer/core/helpers/app_bar/app_bar.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/base/view/base_navigation.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:algorithm_visualizer/features/visualize/view/visualize_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'unknown_page.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _tabAKey = GlobalKey<NavigatorState>();
final _tabBKey = GlobalKey<NavigatorState>();

class Routes {
  static const RouteConfig home = RouteConfig(
    name: 'home',
    path: '/home',
  );
  static const RouteConfig visualize = RouteConfig(
    name: 'visualize',
    path: '/visualize',
    queryParamsName: "instance",
  );
}

class RouteConfig {
  final String name;
  final String path;
  final String pathParamsName;
  final String queryParamsName;

  const RouteConfig({
    required this.name,
    required this.path,
    this.pathParamsName = "",
    this.queryParamsName = "",
  });
}

class AppRoutes {
  static final router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: _rootKey,
    initialLocation: Routes.home.path,
    errorBuilder: (context, state) => const _UnknownPage(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _tabAKey,
            routes: [
              GoRoute(
                path: Routes.home.path,
                name: Routes.home.name,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _tabBKey,
            routes: [
              GoRoute(
                path: Routes.visualize.path,
                name: Routes.visualize.name,
                builder: (context, state) {
                  final instance = state.uri.queryParameters["instance"];
                  final sortingAlgo =
                      SortingAlgoCards.values.firstWhereOrNull((element) => element.name == instance);
                  final searchingAlgo =
                      SearchingAlgoCards.values.firstWhereOrNull((element) => element.name == instance);
                  if (instance != null && (sortingAlgo == null && searchingAlgo == null)) {
                    return _UnknownPage();
                  }
                  return VisualizePage(sortingCard: sortingAlgo, searchingCard: searchingAlgo);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
