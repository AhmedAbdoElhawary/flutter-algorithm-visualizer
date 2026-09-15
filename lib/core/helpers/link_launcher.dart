import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// How a link should leave the app.
enum LinkTarget {
  /// A sheet over AlgoDive — Chrome Custom Tabs on Android, `SFSafariViewController`
  /// on iOS. Right for the legal pages: the user reads and swipes back, and
  /// never loses their place in the app.
  inApp,

  /// Hands the URL to whichever app owns it, so a LinkedIn or GitHub link
  /// opens in their installed app (already signed in) rather than in a browser
  /// asking them to log in again.
  external,
}

/// Opening a URL is the one thing on the settings screen that can fail for
/// reasons the user can do something about — no browser, no mail app, airplane
/// mode. Every call site needs the same "say so, don't fail silently" handling,
/// so it lives here once.
extension LinkLauncher on BuildContext {
  /// Opens [url], telling the user if nothing on the device can.
  Future<void> openLink(String url, {LinkTarget target = LinkTarget.inApp}) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _reportFailure();
      return;
    }

    final mode = switch (target) {
      LinkTarget.inApp => LaunchMode.inAppBrowserView,
      LinkTarget.external => LaunchMode.externalApplication,
    };

    try {
      final opened = await launchUrl(uri, mode: mode);
      if (!opened) _reportFailure();
    } catch (_) {
      /// `launchUrl` throws rather than returning false when no activity can
      /// handle the intent, which is the common case on a device with no
      /// browser or no mail client.
      _reportFailure();
    }
  }

  /// Opens the user's mail app with [address] filled in.
  Future<void> sendEmail(String address, {String? subject}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: address,
      query: subject == null ? null : 'subject=${Uri.encodeComponent(subject)}',
    );

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) _reportFailure(StringsManager.linkNoMailApp);
    } catch (_) {
      _reportFailure(StringsManager.linkNoMailApp);
    }
  }

  void _reportFailure([String? message]) {
    if (!mounted) return;
    showSnackBar(
      message: message ?? StringsManager.linkCouldNotOpen,
      type: CustomSnackBarType.error,
    );
  }
}
