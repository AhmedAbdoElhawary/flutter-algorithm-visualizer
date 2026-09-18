import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SortingLegend extends StatelessWidget {
  const SortingLegend({required this.roles, this.pointerHints = const {}, super.key});

  final Set<SortRole> roles;

  final Map<SortRole, String> pointerHints;

  @override
  Widget build(BuildContext context) {
    final orderedRoles = kRolePriority.where((role) => role != SortRole.idle && roles.contains(role));

    return Padding(
      padding: REdgeInsets.symmetric(horizontal: 6),
      child: Wrap(
        spacing: 6.r,
        runSpacing: 8.r,
        alignment: WrapAlignment.center,
        children: [
          for (final role in orderedRoles) _LegendChip(role: role, pointerHint: pointerHints[role]),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.role, this.pointerHint});

  final SortRole role;
  final String? pointerHint;

  @override
  Widget build(BuildContext context) {
    final label = pointerHint == null ? roleLabel(role) : '${roleLabel(role)} $pointerHint';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: context.getColor(sortingRoleColor(role)),
            shape: BoxShape.circle,
          ),
        ),
        const RSizedBox(width: 6),
        RegularText(label, fontSize: 11, color: ThemeEnum.inkBody),
      ],
    );
  }
}
