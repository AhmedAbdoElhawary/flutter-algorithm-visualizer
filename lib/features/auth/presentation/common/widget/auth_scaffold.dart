import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared shell for the three auth screens (CoreDive 11 / 12 / 13).
///
/// Radial background wash (one of the two gradients the system allows), 24px
/// screen inset, scrollable column. The old particle-constellation background is
/// gone — it fought the form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.topInset = CdSpace.x12,
  });

  final List<Widget> children;

  /// Distance from the safe-area top to the first child. Screen 11 starts at
  /// 44px, screen 12 at 8px (its own eyebrow row), screen 13 at 20px.
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.primary),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1),
            radius: 1.2,
            stops: const [0, 0.62],
            colors: [
              context.getColor(ThemeEnum.authWash),
              context.getColor(ThemeEnum.primary),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: HorizontalPadding(
              padding: CdSpace.authInset,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: topInset.h),
                  ...children,
                  SizedBox(height: CdSpace.x6.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
