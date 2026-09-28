import 'dart:io';

import 'package:algorithm_visualizer/core/resources/logo_assets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every logo path points at a file that ships', () {
    for (final path in [
      LogoAssets.markSilhouetteBlack,
      LogoAssets.markGreenLogoBlack,
      LogoAssets.markGreenLogoWhite,
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}
