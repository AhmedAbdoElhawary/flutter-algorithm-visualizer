import 'package:algorithm_visualizer/core/helpers/svg_picture.dart';
import 'package:algorithm_visualizer/core/resources/logo_assets.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('draws the asset in the theme colour, at the given size, with its label', (tester) async {
    await pumpApp(
      tester,
      const CustomAssetsSvg(LogoAssets.markGreenLogoBlack, size: 40, semanticLabel: 'AlgoDive'),
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    final context = tester.element(find.byType(SvgPicture));
    expect(svg.height, greaterThan(0));
    expect(svg.semanticsLabel, 'AlgoDive');
    expect(svg.colorFilter, ColorFilter.mode(context.getColor(ThemeEnum.inkTitle), BlendMode.srcIn));
  });

  testWidgets('with no colour, the asset keeps its own colours', (tester) async {
    await pumpApp(tester, const CustomAssetsSvg(LogoAssets.markGreenLogoBlack, color: null));

    expect(tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter, isNull);
  });

  testWidgets('an empty path draws nothing instead of failing to load', (tester) async {
    await pumpApp(tester, const CustomAssetsSvg(''));

    expect(find.byType(SvgPicture), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
