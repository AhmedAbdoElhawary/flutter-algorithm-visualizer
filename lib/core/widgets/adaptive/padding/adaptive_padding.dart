import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
part 'all_padding.dart';
part 'bottom_padding.dart';
part 'top_padding.dart';
part 'start_padding.dart';
part 'end_padding.dart';
part 'vertical_padding.dart';
part 'horizontal_padding.dart';
part 'symmetric_padding.dart';
part 'only_padding.dart';

class _RPadding extends StatelessWidget {
  const _RPadding({required this.padding, required this.child});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}
