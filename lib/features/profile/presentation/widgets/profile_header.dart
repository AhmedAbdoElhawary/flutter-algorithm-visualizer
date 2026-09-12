import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/helpers/current_device.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/avatar_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      topPadding: context.isAndroid ? kAndroidTopPageSpacing*1.5 : kIOSTopPageSpacing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Consumer(builder: (context, ref, child) {
                final name = ref.watch(
                  currentUserNameProvider.select(
                    (value) => value.maybeWhen(data: (data) => data, orElse: () => StringsManager.anonymous),
                  ),
                );

                return AvatarQuiet(
                    initial: name.isNotEmpty ? name[0].toUpperCase() : StringsManager.anonymous);
              }),
              const RSizedBox(width: 14),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) => _EditableName(
                    name: ref.watch(
                      currentUserNameProvider.select(
                        (value) =>
                            value.maybeWhen(data: (data) => data, orElse: () => StringsManager.anonymous),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
      child: Row(
        children: [
          Expanded(
            child: BoldText(widget.name,
                maxLines: 1,
                color: ThemeEnum.textPrimary,
                fontSize: 22,
                fontWeight: FontWeightManager.bold800),
          ),
          const RSizedBox(width: 6),
          const IconButtonQuiet(
            icon: Icons.edit_outlined,
            size: 32,
            iconSize: 16,
          ),
        ],
      ),
    );
  }
}
