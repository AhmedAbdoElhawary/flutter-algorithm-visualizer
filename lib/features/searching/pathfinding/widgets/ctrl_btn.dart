import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  const CtrlBtn({super.key, required this.icon, required this.onTap, this.tooltip});

  bool get _disabled => onTap == null;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: context.cardDecoration(),
        child: Icon(icon, size: 18.r, color: _disabled ? context.textVMuted : context.textSec),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: button) : button;
  }
}
