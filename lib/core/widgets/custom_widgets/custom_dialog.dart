import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const double _borderRadius = 15;

class ListDialogParameters {
  final String text;
  final VoidCallback onTap;
  final ThemeEnum? color;
  ListDialogParameters({
    required this.text,
    required this.onTap,
    this.color,
  });
}

class CustomAlertDialog {
  final BuildContext context;
  CustomAlertDialog(this.context);

  Future<bool?> solidDialog(
      {required List<ListDialogParameters> parameters, bool barrierDismissible = true}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsetsDirectional.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius.r),
          ),
          content: _SolidContent(parameters),
        );
      },
    );
  }
}

class _SolidContent extends StatelessWidget {
  const _SolidContent(this.parameters);
  final List<ListDialogParameters> parameters;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          parameters.length,
          (index) {
            final isLast = index == parameters.length - 1;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: index == 0
                      ? BorderRadius.only(
                          topLeft: Radius.circular(_borderRadius.r),
                          topRight: Radius.circular(_borderRadius.r),
                        )
                      : (isLast
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(_borderRadius.r),
                              bottomRight: Radius.circular(_borderRadius.r),
                            )
                          : null),
                  onTap: () {
                    parameters[index].onTap();
                    context.pop();
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: REdgeInsets.symmetric(vertical: 10),
                          child: RegularText(parameters[index].text,
                              color: parameters[index].color ?? ThemeEnum.focusColor),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast) const CustomDivider(withHeight: false, color: ThemeEnum.whiteD4Color),
              ],
            );
          },
        ),
      ],
    );
  }
}
