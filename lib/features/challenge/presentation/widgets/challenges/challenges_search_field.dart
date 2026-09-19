import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChallengesSearchField extends ConsumerStatefulWidget {
  const ChallengesSearchField({super.key});

  @override
  ConsumerState<ChallengesSearchField> createState() => _ChallengesSearchFieldState();
}

class _ChallengesSearchFieldState extends ConsumerState<ChallengesSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(challengesProvider.select((s) => s.search));

    return Padding(
      padding: REdgeInsets.fromLTRB(16, 0, 16, 12),
      child: CardContainer(
        radius: CdRadius.medium,
        surface: CdSurface.main,
        padding: REdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            const CustomIcon(Icons.search_rounded, size: 18, color: ThemeEnum.track),
            const RSizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (v) => ref.read(challengesProvider.notifier).setSearch(v),
                style: GetMediumStyle(
                    color: context.getColor(ThemeEnum.inkTitle), fontSize: 14, letterSpacing: 0.2),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: StringsManager.searchProblem.tr(context),
                  hintStyle: TextStyle(
                      color: context.getColor(ThemeEnum.inkSecondaryTitle),
                      fontSize: 14.r,
                      fontFamily: FontConstants.fontFamily),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (search.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  ref.read(challengesProvider.notifier).clearSearch();
                },
                child: const RegularText('×', color: ThemeEnum.track, fontSize: 18),
              ),
            ] else ...[
              const RegularText('', fontSize: 18),
            ],
          ],
        ),
      ),
    );
  }
}
