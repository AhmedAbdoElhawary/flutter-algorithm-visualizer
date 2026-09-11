import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // The nav is a real, non-flexible child in a Column — content and nav are
    // siblings, never a Stack overlay.
    return Material(
      color: context.getColor(ThemeEnum.primary),
      child: Column(
        children: [
          Expanded(child: ClipRect(child: navigationShell)),
          _BottomNavBar(navigationShell: navigationShell),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.navigationShell});

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
    return SafeArea(
      top: false,
      child: Container(
        height: 64.h,
        width: double.infinity,
        padding: REdgeInsetsDirectional.fromSTEB(0, 6, 0, 6),
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.primary),
          border: Border(top: BorderSide(color: context.getColor(ThemeEnum.borderSubtle))),
        ),
        child: Row(
          children: List.generate(_destinations.length, (i) {
            final d = _destinations[i];
            final active = i == current;
            return Expanded(
              child: _NavItem(
                icon: active ? d.activeIcon : d.icon,
                label: d.label,
                active: active,
                onTap: () => _go(i),
              ),
            );
          }),
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
    final color = active ? ThemeEnum.textBright : ThemeEnum.textSecond;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIcon(icon, size: 20, color: color),
          RSizedBox(height: 5),
          active
              ? MediumText(label, fontSize: 9.5, color: color, maxLines: 1)
              : RegularText(label, fontSize: 9.5, color: color, maxLines: 1),
        ],
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
