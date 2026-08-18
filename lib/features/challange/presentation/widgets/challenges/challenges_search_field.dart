import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/challenges_providers.dart';
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
      child: Container(
        padding: REdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.card),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.getColor(ThemeEnum.border)),
          boxShadow: context.cardShadow,
        ),
        child: Row(
          children: [
            CustomIcon(Icons.search_rounded, size: 16, color: ThemeEnum.hover),
            const RSizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (v) => ref.read(challengesProvider.notifier).setSearch(v),
                style: GetSemiBoldStyle(
                    color: context.getColor(ThemeEnum.textPrimary), fontSize: 14, letterSpacing: 0.2),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: StringsManager.searchProblem,
                  hintStyle: TextStyle(
                      color: context.getColor(ThemeEnum.textSecond),
                      fontSize: 14.r,
                      fontFamily: FontConstants.fontFamily),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (search.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  ref.read(challengesProvider.notifier).clearSearch();
                },
                child: RegularText('×', color: ThemeEnum.hover, fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
