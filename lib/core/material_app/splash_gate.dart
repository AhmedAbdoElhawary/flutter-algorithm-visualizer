import 'package:algorithm_visualizer/core/material_app/my_app.dart';
import 'package:algorithm_visualizer/core/widgets/splash/algodive_splash.dart';
import 'package:flutter/material.dart';

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
      return AlgoDiveSplash(
        dark: MediaQuery.platformBrightnessOf(context) == Brightness.dark,
        onFinished: () => setState(() => _showSplash = false),
      );
    }
    return const MyApp();
  }
}
