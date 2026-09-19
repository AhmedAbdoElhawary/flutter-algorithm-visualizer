import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/primary_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/secondary_button_quiet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The common frame behind the Account dialogs: round icon, title, one line of
/// explanation, the caller's fields, then cancel / confirm.
///
/// It exists so "change password" and "change email" cannot drift apart from
/// each other — or from the deletion dialog they sit beside.
class AccountDialogShell extends StatelessWidget {
  const AccountDialogShell({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.fields,
    required this.confirmLabel,
    required this.loading,
    required this.onCancel,
    required this.onConfirm,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<Widget> fields;
  final String confirmLabel;
  final bool loading;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CardContainer(
        radius: CdRadius.dialog,
        padding: REdgeInsets.all(16),
        child: SizedBox(
          width: ScreenUtil().screenWidth - 67.r,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DialogIcon(icon: icon),
              const RSizedBox(height: 14),
              BoldText(
                title,
                color: ThemeEnum.inkTitle,
                fontSize: 16,
                fontWeight: FontWeightManager.bold800,
                textAlign: TextAlign.center,
              ),
              const RSizedBox(height: 6),
              RegularText(
                description,
                color: ThemeEnum.inkSecondaryTitle,
                fontSize: 12,
                maxLines: 4,
                textAlign: TextAlign.center,
              ),
              const RSizedBox(height: 18),
              ...fields,
              const RSizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButtonQuiet(
                      label: StringsManager.cancel,
                      onPressed: loading ? null : onCancel,
                    ),
                  ),
                  const RSizedBox(width: 10),
                  Expanded(
                    child: PrimaryButtonQuiet(
                      label: confirmLabel,
                      loading: loading,
                      onPressed: loading ? null : onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogIcon extends StatelessWidget {
  const _DialogIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 48.r,
        height: 48.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.raised),
          shape: BoxShape.circle,
        ),
        child: CustomIcon(icon, size: 24, color: ThemeEnum.inkPrimary),
      ),
    );
  }
}
