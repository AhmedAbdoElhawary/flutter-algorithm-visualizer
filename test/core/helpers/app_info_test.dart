import 'package:algorithm_visualizer/core/helpers/app_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  test('load reads the version the build was tagged with', () async {
    PackageInfo.setMockInitialValues(
      appName: 'AlgoDive',
      packageName: 'com.elhawary.algodive',
      version: '2.4.1',
      buildNumber: '41',
      buildSignature: '',
    );

    await AppInfo.load();

    expect(AppInfo.version, '2.4.1');
  });
}
