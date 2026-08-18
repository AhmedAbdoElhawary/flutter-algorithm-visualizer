import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/profile_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_category_chart.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_heatmap.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_practice_history.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_problems_solved.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_stats_grid.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_weekly_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileName = ref.watch(profileNameProvider);

    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.primary),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: REdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 14.r,
            children: [
              _ProfileHeader(name: profileName, ref: ref),
              const ProfileStatsGrid(),
              const ProfileDifficultyBreakdown(),
              const ProfileWeeklyChart(),
              const ProfileHeatmap(),
              const ProfileCategoryChart(),
              const ProfilePracticeHistory(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.ref});

  final String name;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return HorizontalPadding(
      padding: 16,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          RegularText(StringsManager.profile, color: ThemeEnum.hoverSecond, fontSize: 12),
          const Spacer(),
          CustomIcon(Icons.settings_rounded, size: 18, color: ThemeEnum.hoverSecond),
        ]),
        RSizedBox(height: 12),
        Row(children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: [
                    context.getColor(ThemeEnum.accent),
                    context.getColor(ThemeEnum.pink),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                  child: BoldText(
                name.isNotEmpty ? name[0].toUpperCase() : 'A',
                color: ThemeEnum.solidWhite,
                fontSize: 26,
              )),
            ),
            Positioned(
              bottom: -6.r,
              right: -6.r,
              child: Container(
                padding: REdgeInsets.all(1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: [
                      context.getColor(ThemeEnum.accent),
                      context.getColor(ThemeEnum.pink),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(7.r),
                  border: Border.all(color: context.getColor(ThemeEnum.primary), width: 2.r),
                ),
                child: CustomIcon(Icons.bolt_rounded, size: 14, color: ThemeEnum.solidWhite),
              ),
            ),
          ]),
          RSizedBox(width: 14),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _EditableName(name: name, ref: ref),
          ])),
        ]),
      ]),
    );
  }
}

class _EditableName extends StatefulWidget {
  const _EditableName({required this.name, required this.ref});

  final String name;
  final WidgetRef ref;

  @override
  State<_EditableName> createState() => _EditableNameState();
}

class _EditableNameState extends State<_EditableName> {
  late TextEditingController _controller;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(covariant _EditableName oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.name != widget.name) _controller.text = widget.name;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return TextField(
        controller: _controller,
        autofocus: true,
        style: GetBoldStyle(
          color: context.getColor(ThemeEnum.textPrimary),
          fontSize: 22,
          letterSpacing: -0.4,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: REdgeInsets.symmetric(vertical: 4),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: context.getColor(ThemeEnum.accent)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: context.getColor(ThemeEnum.accent), width: 2),
          ),
        ),
        onSubmitted: (value) {
          final trimmed = value.trim();
          if (trimmed.isNotEmpty) {
            widget.ref.read(profileNameProvider.notifier).updateName(trimmed);
          }
          setState(() => _editing = false);
        },onTapOutside: (event) {
        final trimmed = _controller.text.trim();
        if (trimmed.isNotEmpty) {
          widget.ref.read(profileNameProvider.notifier).updateName(trimmed);
        }
        setState(() => _editing = false);
        },
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _editing = true),
      child: Row(children: [
        BoldText(widget.name, color: ThemeEnum.textPrimary, fontSize: 22,fontWeight: FontWeightManager.bold800),
        RSizedBox(width: 6),
        CustomIcon(Icons.edit_rounded, size: 14, color: ThemeEnum.hoverSecond),
      ]),
    );
  }
}
