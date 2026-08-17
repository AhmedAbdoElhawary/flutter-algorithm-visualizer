import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/base/view/base_navigation.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view/challenge_page.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view/code_editor_page.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/pages/bookmarked_problems_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/pages/practice_history_page.dart';
import 'package:algorithm_visualizer/features/profile/profile_page.dart';
import 'package:algorithm_visualizer/features/visualize/view/visualize_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'unknown_page.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _tabAKey = GlobalKey<NavigatorState>();
final _tabBKey = GlobalKey<NavigatorState>();
final _tabCKey = GlobalKey<NavigatorState>();
final _tabDKey = GlobalKey<NavigatorState>();
final _tabEKey = GlobalKey<NavigatorState>();

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

  static const RouteConfig code = RouteConfig(
    name: 'code',
    path: '/code',
    queryParamsName: "problem_id",
  );
  static const RouteConfig practice = RouteConfig(
    name: 'practice',
    path: '/practice',
  );
  static const RouteConfig profile = RouteConfig(
    name: 'profile',
    path: '/profile',
  );
  static const RouteConfig recentSubmissions = RouteConfig(
    name: 'recentSubmissions',
    path: 'recent_submissions',
  );
  static const RouteConfig bookmarkedProblems = RouteConfig(
    name: 'bookmarkedProblems',
    path: 'bookmarked',
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
          StatefulShellBranch(
            navigatorKey: _tabCKey,
            routes: [
              GoRoute(
                path: Routes.code.path,
                name: Routes.code.name,
                builder: (context, state) {
                  final id = int.tryParse(state.uri.queryParameters["problem_id"] ?? "")??-1;

                  return CodeEditorPage(problemId: id);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _tabDKey,
            routes: [
              GoRoute(
                path: Routes.practice.path,
                name: Routes.practice.name,
                builder: (context, state) => ChallengePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _tabEKey,
            routes: [
              GoRoute(
                path: Routes.profile.path,
                name: Routes.profile.name,
                builder: (context, state) => ProfileScreen(),
                routes: [
                  GoRoute(
                    path: Routes.recentSubmissions.path,
                    name: Routes.recentSubmissions.name,
                    builder: (context, state) => const RecentSubmissionsPage(),
                  ),
                  GoRoute(
                    path: Routes.bookmarkedProblems.path,
                    name: Routes.bookmarkedProblems.name,
                    builder: (context, state) => const BookmarkedProblemsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
