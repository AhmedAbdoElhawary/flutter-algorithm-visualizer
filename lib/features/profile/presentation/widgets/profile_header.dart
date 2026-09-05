import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return HorizontalPadding(
      padding: 16,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: REdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Row(
            children: [
              MediumText(
                StringsManager.profile.toUpperCase(),
                color: ThemeEnum.hover,
                letterSpacing: 0.5,
                fontSize: 12,
              ),
              // const Spacer(),
              // CustomIcon(Icons.settings_rounded, size: 18, color: ThemeEnum.hoverSecond),
            ],
          ),
        ),
        RSizedBox(height: 10),
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
                child: Consumer(builder: (context, ref, child) {
                  final name = ref.watch(currentUserNameProvider.select((value) => value));

                  return BoldText(
                    name.isNotEmpty ? name[0].toUpperCase() : StringsManager.anonymous,
                    color: ThemeEnum.solidWhite,
                    fontSize: 26,
                  );
                }),
              ),
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
            Consumer(
                builder: (context, ref, child) =>
                    _EditableName(name: ref.watch(currentUserNameProvider.select((value) => value)))),
          ])),
        ]),
      ]),
    );
  }
}

class _EditableName extends ConsumerStatefulWidget {
  const _EditableName({required this.name});

  final String name;

  @override
  ConsumerState<_EditableName> createState() => _EditableNameState();
}

class _EditableNameState extends ConsumerState<_EditableName> {
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
        maxLines: 1,
        maxLength: 20,
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
          final text = value.trim();
          if (text.isNotEmpty) ref.read(profileProvider.notifier).updateDisplayName(name: text);

          setState(() => _editing = false);
        },
        onTapOutside: (event) {
          final text = _controller.text.trim();
          if (text.isNotEmpty) ref.read(profileProvider.notifier).updateDisplayName(name: text);

          setState(() => _editing = false);
        },
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _editing = true),
      child: Row(children: [
        Flexible(
          child: BoldText(widget.name,
              maxLines: 1, color: ThemeEnum.textPrimary, fontSize: 22, fontWeight: FontWeightManager.bold800),
        ),
        RSizedBox(width: 6),
        CustomIcon(Icons.edit_rounded, size: 14, color: ThemeEnum.hoverSecond),
      ]),
    );
  }
}
