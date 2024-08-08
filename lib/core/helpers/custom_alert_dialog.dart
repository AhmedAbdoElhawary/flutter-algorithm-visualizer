import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const double _borderRadius = 15;

class DialogParameters {
  final String title;
  final String content;
  final VoidCallback? onTapCancel;
  final bool allowCancelPopup;
  final String cancelText;
  final String actionText;
  final VoidCallback onTapAction;

  DialogParameters({
    required this.title,
    required this.content,
    this.allowCancelPopup = false,
    this.onTapCancel,
    this.cancelText = StringsManager.cancel,
    required this.actionText,
    required this.onTapAction,
  });
}

class CustomAlertDialog {
  final BuildContext context;
  CustomAlertDialog(this.context);

  Future<bool?> openDialog(DialogParameters parameters,
      {bool barrierDismissible = true}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsetsDirectional.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius.r),
          ),
          content: _Content(parameters),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content(this.parameters);
  final DialogParameters parameters;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: REdgeInsets.symmetric(horizontal: 25, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SemiBoldText(
                  parameters.title,
                  fontSize: 20,
                  textAlign: TextAlign.center,
                ),
                const RSizedBox(height: 5),
                RegularText(
                  parameters.content,
                  maxLines: 15,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const CustomDivider(withHeight: false),
        InkWell(
          onTap: parameters.onTapAction,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: REdgeInsets.symmetric(vertical: 10),
                  child: BoldText(parameters.actionText,
                      color: ThemeEnum.redColor),
                ),
              ],
            ),
          ),
        ),
        const CustomDivider(withHeight: false),
        InkWell(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(_borderRadius.r),
              bottomRight: Radius.circular(_borderRadius.r)),
          onTap: () {
            final onTapCancel = parameters.onTapCancel;
            if (onTapCancel != null) onTapCancel();

            if (parameters.allowCancelPopup || onTapCancel == null) {
              context.pop();
            }
          },
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: REdgeInsets.symmetric(vertical: 10),
                  child: RegularText(parameters.cancelText,
                      color: ThemeEnum.focusColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
