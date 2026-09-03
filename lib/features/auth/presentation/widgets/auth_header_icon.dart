import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AuthHeaderIconType {
  logo,
  shield,
  key,
}

class AuthHeaderIcon extends StatelessWidget {
  final AuthHeaderIconType type;
  final bool showBadge;

  const AuthHeaderIcon({
    super.key,
    this.type = AuthHeaderIconType.logo,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  context.getColor(ThemeEnum.accent),
                  context.getColor(ThemeEnum.pink),
                ],
              ),
              borderRadius: BorderRadius.circular(22.r),
              boxShadow: [
                BoxShadow(
                  color: context.getColor(ThemeEnum.accent).withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _buildIconContent(context),
            ),
          ),
          if (showBadge && type == AuthHeaderIconType.logo)
            Positioned(
              bottom: -4.r,
              right: -4.r,
              child: Container(
                padding: REdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      context.getColor(ThemeEnum.accentGreen),
                      context.getColor(ThemeEnum.accentGreen).withValues(alpha: 0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.getColor(ThemeEnum.primary),
                    width: 2.5.r,
                  ),
                ),
                child: CustomIcon(
                  Icons.auto_awesome_rounded,
                  size: 11,
                  color: ThemeEnum.solidWhite,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconContent(BuildContext context) {
    switch (type) {
      case AuthHeaderIconType.logo:
        return BoldText(
          '<A/>',
          color: ThemeEnum.solidWhite,
          fontSize: 22,
          fontWeight: FontWeightManager.bold800,
        );
      case AuthHeaderIconType.shield:
        return CustomIcon(
          Icons.verified_user_outlined,
          size: 32,
          color: ThemeEnum.solidWhite,
        );
      case AuthHeaderIconType.key:
        return CustomIcon(
          Icons.vpn_key_rounded,
          size: 30,
          color: ThemeEnum.solidWhite,
        );
    }
  }
}
