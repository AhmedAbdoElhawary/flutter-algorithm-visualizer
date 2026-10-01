import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/features/onboarding/view_model/onboarding_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/material_app/app_launch.dart';

void main() {
  setUpLaunch(onboardingSeen: false);

  test('debugReset picks the start page again from what is saved now', () async {
    final first = AppRoutes.instance.routerProvider;
    expect(first.routeInformationProvider.value.uri.path, Routes.onboarding.path);

    await GetStorage().write(OnboardingStore.seenKey, true);
    AppRoutes.debugReset();

    final second = AppRoutes.instance.routerProvider;
    expect(second, isNot(same(first)));
    expect(second.routeInformationProvider.value.uri.path, Routes.home.path);
  });
}
