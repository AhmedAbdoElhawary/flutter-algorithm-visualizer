import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension Navigators on BuildContext {
  String? get currentRoute => ModalRoute.of(this)?.settings.name;
  (String?, Object?) get currentRouteSettings => (
        ModalRoute.of(this)?.settings.name,
        ModalRoute.of(this)?.settings.arguments
      );
  void unFocusKeyboard() {
    try {
      if (mounted) FocusScope.of(this).unfocus();
    } catch (e) {
      //
    }
  }

  void back({dynamic result}) {
    try {
      unFocusKeyboard();

      GoRouter.of(this).canPop() ? GoRouter.of(this).pop(result) : null;
    } catch (e) {
      //
    }
  }

  void pop({dynamic result}) {
    try {
      unFocusKeyboard();

      if (Navigator.of(this).canPop()) {
        return Navigator.of(this, rootNavigator: true).pop(result);
      }
    } catch (e) {
      //
    }
  }

  Future pushTo(
    RouteConfig path, {
    Object? arguments,
    String pathParameters = "",
    Map<String, String>? pathParametersRaw,
    String queryParameters = "",
    bool pauseVideo = true,
  }) async {
    unFocusKeyboard();

    if (pathParameters.isNotEmpty && arguments == null) {
      arguments = pathParameters;

      final currentValue = currentRouteSettings.$2;

      if (currentValue is Map &&
          currentRoute == path.name &&
          arguments == currentValue[path.pathParamsName]) {
        return;
      }
    }

    return await GoRouter.of(this)
        .pushNamed(
      path.name,
      extra: arguments,
      pathParameters: pathParametersRaw ??
          (pathParameters.isNotEmpty
              ? {path.pathParamsName: pathParameters}
              : {}),
      queryParameters: queryParameters.isNotEmpty
          ? {path.queryParamsName: queryParameters}
          : {},
    )
        .then((value) {
      unFocusKeyboard();
      return value;
    });
  }

  Future pushAndRemoveCurrent(
    RouteConfig path, {
    Object? arguments,
    String pathParameters = "",
  }) async {
    return await GoRouter.of(this)
        .pushReplacementNamed(
      path.name,
      extra: arguments,
      pathParameters:
          pathParameters.isEmpty ? {} : {path.pathParamsName: pathParameters},
    )
        .then((value) {
      unFocusKeyboard();
      return value;
    });
  }

  Future<void> pushAndRemoveAll(
    RouteConfig path, {
    String pathParameters = "",
    Object? arguments,
  }) async {
    unFocusKeyboard();

    while (GoRouter.of(this).canPop()) {
      GoRouter.of(this).pop();
    }
    await GoRouter.of(this)
        .pushReplacementNamed(
      path.name,
      extra: arguments,
      pathParameters:
          pathParameters.isEmpty ? {} : {path.pathParamsName: pathParameters},
    )
        .then((value) {
      unFocusKeyboard();
      return value;
    });
  }

  Future<void> pushAndRemoveAllUntilBase(
    RouteConfig path, {
    String pathParameters = "",
    Object? arguments,
  }) async {
    unFocusKeyboard();

    while (GoRouter.of(this).canPop()) {
      GoRouter.of(this).pop();
    }
    await GoRouter.of(this)
        .pushNamed(
      path.name,
      extra: arguments,
      pathParameters:
          pathParameters.isEmpty ? {} : {path.pathParamsName: pathParameters},
    )
        .then((value) {
      unFocusKeyboard();
      return value;
    });
  }
}
