import 'package:algorithm_visualizer/core/monitoring/monitoring.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/auth/presentation/forgot_password/view/forgot_password_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view/login_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/signup/view/sign_up_page.dart';
import 'package:algorithm_visualizer/features/base/view/base_navigation.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/celebration_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/challenge_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/profile_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/sub_views/bookmarked_problems_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/sub_views/practice_history_page.dart';
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
  static const RouteConfig login = RouteConfig(
    name: 'login',
    path: '/login',
  );
  static const RouteConfig signUp = RouteConfig(
    name: 'signUp',
    path: '/signup',
  );
  static const RouteConfig forgotPassword = RouteConfig(
    name: 'forgotPassword',
    path: '/forgot-password',
  );
  // static const RouteConfig resetPassword = RouteConfig(
  //   name: 'resetPassword',
  //   path: '/reset-password',
  // );

  static const RouteConfig home = RouteConfig(
    name: 'home',
    path: '/home',
  );
  static const RouteConfig visualize = RouteConfig(
    name: 'visualize',
    path: '/visualize',
    queryParamsName: "instance",
  );

  static const RouteConfig practice = RouteConfig(
    name: 'practice',
    path: '/practice',
  );

  static const RouteConfig problem = RouteConfig(
    name: 'problem',
    path: '/problem',
    queryParamsName: "problem_id",
  );
  static const RouteConfig subProblem = RouteConfig(
    name: 'subProblem',
    path: 'sub',
    queryParamsName: "problem_id",
  );
  static const RouteConfig celebration = RouteConfig(
    name: 'celebration',
    path: '/celebration',
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
  AppRoutes._();
  static final instance = AppRoutes._();

  final routerProvider = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: _rootKey,
    initialLocation: Routes.home.path,
    errorBuilder: (context, state) => const _UnknownPage(),
    // Screen tracking with no per-page code: Firebase logs each route
    // change as a `screen_view`, Sentry times how long the screen took to
    // render. Monitoring owns the list — it is empty in debug/profile
    // builds and whenever an SDK did not start, so the router never holds
    // an observer backed by an uninitialized SDK.
    observers: Monitoring.navigatorObservers,
    routes: [
      GoRoute(
        path: Routes.login.path,
        name: Routes.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.signUp.path,
        name: Routes.signUp.name,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: Routes.forgotPassword.path,
        name: Routes.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      // GoRoute(
      //   path: Routes.resetPassword.path,
      //   name: Routes.resetPassword.name,
      //   builder: (context, state) => const ResetPasswordPage(),
      // ),
      GoRoute(
        path: Routes.celebration.path,
        name: Routes.celebration.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => CelebrationPage(args: state.extra! as CelebrationArgs),
      ),
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
                    return const _UnknownPage();
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
                path: Routes.problem.path,
                name: Routes.problem.name,
                builder: (context, state) {
                  final id = int.tryParse(state.uri.queryParameters["problem_id"] ?? "") ?? -1;
                  return ProblemPage(problemId: id);
                },
                routes: [
                  GoRoute(
                    path: Routes.subProblem.path,
                    name: Routes.subProblem.name,
                    builder: (context, state) {
                      final id = int.tryParse(state.uri.queryParameters["problem_id"] ?? "") ?? -1;
                      return ProblemPage(problemId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _tabDKey,
            routes: [
              GoRoute(
                path: Routes.practice.path,
                name: Routes.practice.name,
                builder: (context, state) => const ChallengePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _tabEKey,
            routes: [
              GoRoute(
                path: Routes.profile.path,
                name: Routes.profile.name,
                builder: (context, state) => const ProfileScreen(),
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
