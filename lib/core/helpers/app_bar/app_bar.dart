import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/helpers/app_bar/back_button.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';

class CustomAppBar {
  static AppBar iconAppBar(
      {bool isShadowTransparent = true, bool withBackButton = true}) {
    return GlobalAppBar(
      centerTitle: true,
      // title: const AppLogo(),
      leading: withBackButton ? null : const SizedBox(),
      shadowColor: isShadowTransparent ? ColorManager.transparent : null,
    );
  }
}

class GlobalAppBar extends AppBar {
  GlobalAppBar({
    super.key,
    Widget? leading,
    super.automaticallyImplyLeading = true,
    Widget? title,
    super.actions,
    super.flexibleSpace,
    super.bottom,
    super.elevation,
    super.scrolledUnderElevation,
    super.notificationPredicate,
    super.shadowColor,
    super.surfaceTintColor,
    super.shape,
    super.backgroundColor,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary = true,
    super.centerTitle,
    super.excludeHeaderSemantics = false,
    // super.titleSpacing,
    super.toolbarOpacity = 1.0,
    super.bottomOpacity = 1.0,
    super.toolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
    super.forceMaterialTransparency = false,
    super.clipBehavior,
  }) : super(
          title: getTitle(title),
          titleSpacing: 15,
          leading: leading ?? const CustomAppBarBackButton(),
        );

  static Widget? getTitle(Widget? title) {
    final text = getText(title);

    if (text != null) return GlobalAppBarText(text: text);

    return title;
  }

  static String? getText(Widget? title) {
    if (title is LightText) return title.text;
    if (title is RegularText) return title.text;
    if (title is MediumText) return title.text;
    if (title is SemiBoldText) return title.text;
    if (title is BoldText) return title.text;
    if (title is AdaptiveText) return title.text;
    if (title is Text) return title.data;
    return null;
  }
}

const double secondAppBarIconSize = 28;

class AppBarCloseButton extends StatelessWidget {
  const AppBarCloseButton({this.onTap, this.withPopup = true, super.key});
  final VoidCallback? onTap;
  final bool withPopup;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final onTap = this.onTap;
        if (onTap != null) onTap();
        if (withPopup) {
          Navigator.maybePop(context); // will be helpful for PopScope
        }
      },
      icon: const CloseButtonIcon(),
    );
  }
}

class AppBarCheckButton extends StatelessWidget {
  const AppBarCheckButton({
    this.onTap,
    this.withPopup = true,
    this.enableTap = true,
    super.key,
  });
  final VoidCallback? onTap;
  final bool withPopup;
  final bool enableTap;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: enableTap
          ? const Icon(Icons.check_rounded,
              size: secondAppBarIconSize, color: ColorManager.blue)
          : const Icon(Icons.check_rounded,
              size: secondAppBarIconSize, color: ColorManager.lightBlue),
      onPressed: () {
        final onTap = this.onTap;
        if (onTap != null) onTap();
        if (withPopup) context.back();
      },
    );
  }
}

class GlobalAppBarText extends StatelessWidget {
  const GlobalAppBarText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return MediumText(
      text,
      color: ThemeEnum.focusColor,
      fontSize: 20,
      maxLines: 1,
      letterSpacing: 0.5,
    );
  }
}
