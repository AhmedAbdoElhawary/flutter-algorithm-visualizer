import 'package:algorithm_visualizer/core/material_app/my_app.dart';
import 'package:algorithm_visualizer/core/widgets/splash/algodive_splash.dart';
import 'package:flutter/material.dart';

/// Shows [AlgoDiveSplash] until its animation finishes, then swaps to [MyApp].
///
/// The native launch screen (Android `styles.xml` / iOS `LaunchScreen.storyboard`)
/// already follows the system's light/dark setting, so this widget reads the
/// same signal via [MediaQuery.platformBrightnessOf] rather than the in-app
/// theme setting — the Flutter tail must match whichever native screen the
/// user just saw, or the handoff shows a color flip.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      return AlgoDiveSplash(
        dark: dark,
        onFinished: () => setState(() => _showSplash = false),
      );
    }
    return const MyApp();
  }
}
