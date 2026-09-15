import 'package:algorithm_visualizer/core/helpers/svg_picture.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/logo_assets.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 60px logo tile — CoreDive screen 11, the three-strata mark in ink on the
/// shared [CdSurface.main] card. The mark is a symbol: it never mirrors in RTL.
class AuthLogoTile extends StatelessWidget {
  const AuthLogoTile({super.key});

  @override
  Widget build(BuildContext context) {
    final side = 60.r;
    return CardContainer(
      surface: CdSurface.main,
      radius: CdRadius.lg,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: side,
        height: side,
        child: const Center(
          child: CustomAssetsSvg(
            LogoAssets.markSilhouetteBlack,
            size: 32,
            color: ThemeEnum.inkTitle,
          ),
        ),
      ),
    );
  }
}

class AuthRecoveryTile extends StatelessWidget {
  const AuthRecoveryTile({this.icon = Icons.key_rounded, super.key});
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final side = 56.r;
    return Container(
      width: side,
      height: side,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.hairline),
        borderRadius: BorderRadius.circular(CdRadius.lg.r),
        border: Border.all(color: context.getColor(ThemeEnum.inkPrimary)),
      ),
      child: CustomIcon(icon, size: 26, color: ThemeEnum.inkTitle),
    );
  }
}
