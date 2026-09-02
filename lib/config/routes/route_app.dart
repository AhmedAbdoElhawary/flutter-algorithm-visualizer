import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view/forgot_password_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view/login_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view/reset_password_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view/sign_up_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/base/view/base_navigation.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/challenge_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/code_editor_page.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/profile_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/sub_views/bookmarked_problems_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/sub_views/practice_history_page.dart';
import 'package:algorithm_visualizer/features/visualize/view/visualize_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  static const RouteConfig resetPassword = RouteConfig(
    name: 'resetPassword',
    path: '/reset-password',
  );

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
  AppRoutes._();
  static final instance = AppRoutes._();

  final routerProvider = Provider<GoRouter>((ref) {
    return GoRouter(
      debugLogDiagnostics: true,
      navigatorKey: _rootKey,
      initialLocation: ref.read(isLoggedInProvider) ? Routes.home.path : Routes.login.path,
      errorBuilder: (context, state) => const _UnknownPage(),
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
        GoRoute(
          path: Routes.resetPassword.path,
          name: Routes.resetPassword.name,
          builder: (context, state) => const ResetPasswordPage(),
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
                  builder: (context, state) => HomePage(),
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
                    final id = int.tryParse(state.uri.queryParameters["problem_id"] ?? "") ?? -1;

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
  });
}
