import 'package:package_info_plus/package_info_plus.dart';

/// The running build's own version, read from the platform once at boot.
///
/// This used to be a hand-written constant. CI sets the real version from the
/// git tag (`--build-name`), so the constant went stale the moment a tag
/// shipped without someone remembering to edit it, and Settings then told the
/// user a version they were not running.
abstract final class AppInfo {
  /// Empty until [load] has run. `main` awaits it before `runApp`, so the UI
  /// never reads it in that state.
  static String version = '';

  static Future<void> load() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
  }
}
