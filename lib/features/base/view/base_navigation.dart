import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // The nav is a real child in the layout flow — not a stack overlay, not a
    // transparent-body bottom bar. Content lives in the flexible slot, clipped
    // so an overflowing child clips instead of painting over the nav.
    return Material(
      // The shell owns the ground for the tabbed screens so the nav floats over
      // the aurora. It stays static — only Home drifts, from its own ground.
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          AuroraGround(
              child: Padding(
            padding: REdgeInsets.only(bottom: kBottomPageSpacing),
            child: SafeArea(bottom: false,child: navigationShell),
          )),
          _AuroraNavBar(navigationShell: navigationShell),
        ],
      ),
    );
  }
}

class _AuroraNavBar extends StatelessWidget {
  const _AuroraNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<_NavDestination> _destinations = [
    _NavDestination(Icons.home_outlined, Icons.home_rounded, StringsManager.home),
    _NavDestination(Icons.bar_chart_outlined, Icons.bar_chart_rounded, StringsManager.visual),
    _NavDestination(Icons.code_rounded, Icons.code_rounded, StringsManager.code),
    _NavDestination(Icons.emoji_events_outlined, Icons.emoji_events_rounded, StringsManager.practice),
    _NavDestination(Icons.person_outline_rounded, Icons.person_rounded, StringsManager.profile),
  ];

  void _go(int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final current = navigationShell.currentIndex;
    return Padding(
      padding: REdgeInsets.fromLTRB(16, 10, 16, 20),
      child: RSizedBox(
        height: 62,
        child: GlassContainer(
          depth: GlassDepth.floating,
          borderRadius: CdRadius.pill,
          padding: REdgeInsets.all(5),
          child: Row(
            children: List.generate(_destinations.length, (i) {
              final d = _destinations[i];
              return Expanded(
                child: _NavItem(
                  icon: i == current ? d.activeIcon : d.icon,
                  label: d.label,
                  active: i == current,
                  onTap: () => _go(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? ThemeEnum.textPrimary : ThemeEnum.navInactive;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50.r,
        decoration: active
            ? BoxDecoration(
                color: context.getColor(ThemeEnum.primaryTint),
                borderRadius: BorderRadius.circular(CdRadius.pill.r),
                border: Border(
                  top: BorderSide(color: context.getColor(ThemeEnum.glassSheenCard)),
                ),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIcon(icon, size: 21, color: color),
            const RSizedBox(height: 4),
            active
                ? SemiBoldText(label, fontSize: 10, color: color)
                : MediumText(label, fontSize: 10, color: color),
          ],
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
