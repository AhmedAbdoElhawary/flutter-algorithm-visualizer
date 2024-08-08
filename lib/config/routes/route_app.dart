import 'package:algorithm_visualizer/core/helpers/app_bar/app_bar.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/grid/view/grid_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static const RouteConfig grid = RouteConfig(
    name: 'grid',
    path: '/',
  );

  // name: 'hashtag',
  // path: '/hashtag/:hashtagId',
  // pathParamsName: "hashtagId",
  // queryParamsName: 'mid',
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
    initialLocation: Routes.grid.path,
    errorBuilder: (context, state) => const _UnknownPage(),
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return child;
        },
        routes: [
          GoRoute(
            path: Routes.grid.path,
            name: Routes.grid.name,
            builder: (context, state) => const GridPage(),
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
