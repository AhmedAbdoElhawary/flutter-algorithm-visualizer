import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/helpers/svg_picture.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_divider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomSheet {
  static BuildContext? context;
  static initializeContextForPost(BuildContext ctx) {
    context = ctx;
  }

  static Future<void> bottomSheet(
    BuildContext ctx, {
    required Widget child,
    bool isScrollControlled = false,
  }) async {
    final tempContext = context ?? ctx;
    if (isScrollControlled) {
      return scrollableBottomSheet(
        tempContext,
        withDivider: false,
        scrollable: true,
        child: [child],
      );
    }
    return showModalBottomSheet<void>(
      context: tempContext,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: const Radius.circular(15).r),
      ),
      builder: (BuildContext context) {
        return RSizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: AlignmentDirectional.center,
                child: _BottomSheetDash(),
              ),
              child,
              const RSizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _showBottomSheet(
      BuildContext context, Widget child) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      useSafeArea: true,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            context.back();
          },
          child: Container(
            color: ColorManager.transparent,
            child: GestureDetector(
              onTap: () {},
              child: DraggableScrollableSheet(
                initialChildSize: 0.8,
                minChildSize: 0.8,
                maxChildSize: 0.8,
                builder: (_, controller) {
                  return Container(
                    decoration: BoxDecoration(
                      color: context.getColor(ThemeEnum.bottomSheetColor),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: child,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> scrollableBottomSheet(
    BuildContext ctx, {
    required List<Widget> child,
    Widget? title,
    bool withDivider = true,
    bool scrollable = true,
    double childHorizontalPadding = 0,
  }) async {
    final tempContext = context ?? ctx;
    return _showBottomSheet(
      tempContext,
      Padding(
        padding: REdgeInsets.symmetric(vertical: 5),
        child: Padding(
          padding: REdgeInsets.symmetric(horizontal: childHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: AlignmentDirectional.center,
                child: _BottomSheetDash(withLittleBottomPadding: true),
              ),
              title ?? const SizedBox(),
              if (withDivider) const CustomDivider(color: ThemeEnum.greyColor),
              Flexible(
                child: scrollable
                    ? SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: child,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: child,
                      ),
              ),
              const RSizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetDash extends StatelessWidget {
  const _BottomSheetDash({this.withLittleBottomPadding = false});
  final bool withLittleBottomPadding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsetsDirectional.only(
          start: 10,
          end: 10,
          top: 10,
          bottom: withLittleBottomPadding ? 5 : 10),
      child: Container(
        width: 40.w,
        height: 3.5.h,
        decoration: BoxDecoration(
            color: context.getColor(ThemeEnum.hoverColor),
            borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}

class BottomSheetText extends StatelessWidget {
  const BottomSheetText(
    this.text, {
    this.color = ThemeEnum.focusColor,
    this.icon,
    this.iconSize,
    super.key,
  });
  final String text;
  final String? icon;
  final double? iconSize;
  final ThemeEnum color;
  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return RSizedBox(
      width: double.infinity,
      child: SymmetricPadding(
        horizontal: 25,
        vertical: 10,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              CustomAssetsSvg(icon, size: iconSize, color: color),
              const RSizedBox(width: 25),
            ],
            Flexible(child: RegularText(text, color: color)),
          ],
        ),
      ),
    );
  }
}
