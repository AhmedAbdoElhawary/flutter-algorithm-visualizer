import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Records every URL the app tries to open, instead of opening it.
class FakeUrlLauncher extends UrlLauncherPlatform with MockPlatformInterfaceMixin {
  final urls = <String>[];
  final modes = <PreferredLaunchMode>[];
  bool succeed = true;
  bool throws = false;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    if (throws) throw Exception('no app can open this');
    urls.add(url);
    modes.add(options.mode);
    return succeed;
  }

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;

  @override
  Future<bool> supportsCloseForMode(PreferredLaunchMode mode) async => true;

  @override
  LinkDelegate? get linkDelegate => null;
}
