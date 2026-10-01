import 'package:algorithm_visualizer/core/helpers/svg_picture.dart';
import 'package:algorithm_visualizer/core/resources/logo_assets.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_logo_tile.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the logo tile shows the mark', (tester) async {
    await pumpApp(tester, const Center(child: AuthLogoTile()));

    expect(tester.widget<CustomAssetsSvg>(find.byType(CustomAssetsSvg)).path, LogoAssets.markSilhouetteBlack);
  });

  testWidgets('the recovery tile shows a key unless given another icon', (tester) async {
    await pumpApp(tester, const Center(child: AuthRecoveryTile()));
    expect(tester.widget<CustomIcon>(find.byType(CustomIcon)).icon, Icons.key_rounded);

    await pumpApp(tester, const Center(child: AuthRecoveryTile(icon: Icons.mail_rounded)));
    expect(tester.widget<CustomIcon>(find.byType(CustomIcon)).icon, Icons.mail_rounded);
  });
}
