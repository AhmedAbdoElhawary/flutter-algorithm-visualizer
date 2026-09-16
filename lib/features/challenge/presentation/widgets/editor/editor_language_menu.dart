import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show EditorLanguage, EditorLanguageX, supportedLanguages;
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/code_editor/code_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The language chooser in the title row, beside the copy button.
///
/// A drop-down rather than a row of chips: the title row has one name and two
/// controls in it, and three chips there would crowd the problem name off the
/// screen. Closed, it reads as the old language label did — which is what it
/// replaces — so the row looks the same until it is opened.
///
/// Every supported language is listed even when this problem cannot take it,
/// disabled with the reason attached. Hiding it would read as the feature
/// being missing rather than as this problem being the exception.
///
/// Switching never warns and never confirms: each language keeps its own
/// draft, so there is nothing to lose (SC-018).
class EditorLanguageMenu extends ConsumerWidget {
  const EditorLanguageMenu({super.key, required this.problemId});

  final int problemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = codeEditorControllerProvider(problemId);
    final notifier = ref.read(provider.notifier);
    final selected = ref.watch(provider.select((s) => s.language));
    final running = ref.watch(provider.select((s) => s.isRunning));
    final available = notifier.languagesAvailable;

    // PopupMenuButton draws an ink response, which needs a Material ancestor.
    // The title row sits on the page background rather than on a Material, so
    // a transparent one is supplied here — it changes nothing visually.
    return Material(
      type: MaterialType.transparency,
      child: PopupMenuButton<EditorLanguage>(
        enabled: !running,
        tooltip: StringsManager.language,
        position: PopupMenuPosition.under,
        onSelected: notifier.setLanguage,
        itemBuilder: (context) => <PopupMenuEntry<EditorLanguage>>[
          for (final language in supportedLanguages)
            PopupMenuItem<EditorLanguage>(
              value: language,
              enabled: available.contains(language),
              child: _MenuRow(
                language: language,
                selected: language == selected,
                available: available.contains(language),
              ),
            ),
        ],
        child: _ClosedMenu(language: selected, enabled: !running),
      ),
    );
  }
}

/// What the drop-down looks like while closed: the current language, bordered
/// the way the old static label was, plus the chevron that says it opens.
class _ClosedMenu extends StatelessWidget {
  const _ClosedMenu({required this.language, required this.enabled});

  final EditorLanguage language;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        padding: REdgeInsets.symmetric(vertical: 8, horizontal: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CdRadius.sm.r),
          border: Border.all(color: context.getColor(ThemeEnum.hairline)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RegularText(
              language.displayName,
              fontFamily: FontConstants.fontJetBrainsMono,
              fontSize: 11,
              color: ThemeEnum.inkBody,
              maxLines: 1,
            ),
            const RSizedBox(width: 3),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14.r,
              color: context.getColor(ThemeEnum.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.language, required this.selected, required this.available});

  final EditorLanguage language;
  final bool selected;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 20.r,
          child: selected
              ? Icon(Icons.check_rounded, size: 14.r, color: context.getColor(ThemeEnum.inkTitle))
              : null,
        ),
        Expanded(
          child: RegularText(
            available ? language.displayName : '${language.displayName} — ${StringsManager.dartOnlyProblem}',
            fontFamily: FontConstants.fontJetBrainsMono,
            fontSize: 11,
            color: available ? ThemeEnum.inkBody : ThemeEnum.inkMuted,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
