import 'package:algorithm_visualizer/core/helpers/app_bar/app_bar.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/base/view/base_page.dart';
import 'package:algorithm_visualizer/features/searching/view/grid_page.dart';
import 'package:algorithm_visualizer/features/sorting/view/sorting_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static const RouteConfig base = RouteConfig(
    name: 'base',
    path: '/',
  );
  static const RouteConfig searching = RouteConfig(
    name: 'searching',
    path: '/searching',
  );
  static const RouteConfig sorting = RouteConfig(
    name: 'sorting',
    path: '/sorting',
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
    initialLocation: Routes.base.path,
    errorBuilder: (context, state) => const _UnknownPage(),
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return child;
        },

        routes: [

          GoRoute(
            path: Routes.base.path,
            name: Routes.base.name,
            builder: (context, state) => const BasePage(),
          ),
          GoRoute(
            path: Routes.searching.path,
            name: Routes.searching.name,
            builder: (context, state) => const SearchingPage(),
          ),
          GoRoute(
            path: Routes.sorting.path,
            name: Routes.sorting.name,
            builder: (context, state) => const SortingPage(),
          ),
        ],
      ),

      ///------------------------------------------------------------>
    ],
  );
}

class _UnknownPage extends StatelessWidget {
  const _UnknownPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(),
      body: const Center(child: RegularText(StringsManager.unknownPage)),
    );
  }
}
