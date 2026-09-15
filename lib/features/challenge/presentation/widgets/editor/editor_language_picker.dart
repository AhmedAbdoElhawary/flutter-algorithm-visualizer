import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show EditorLanguage, EditorLanguageX;
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The language chips in the code card's header.
///
/// Shows **exactly** the languages the problem has starter code for, so a
/// language is never offered that the learner would then find empty
/// (FR-027a). With only one language available there is nothing to choose,
/// so the picker renders nothing at all rather than a single dead chip.
///
/// Switching never warns and never confirms: each language keeps its own
/// draft, so there is nothing to lose (SC-018).
class EditorLanguagePicker extends StatelessWidget {
  const EditorLanguagePicker({
    super.key,
    required this.languages,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final List<EditorLanguage> languages;
  final EditorLanguage selected;
  final ValueChanged<EditorLanguage> onSelected;

  /// False while the code is running, when the editor is read-only anyway.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (languages.length < 2) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final language in languages)
          Padding(
            padding: REdgeInsetsDirectional.only(end: 6),
            child: _LanguageChip(
              language: language,
              active: language == selected,
              onTap: enabled ? () => onSelected(language) : null,
            ),
          ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.language, required this.active, required this.onTap});

  final EditorLanguage language;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? ThemeEnum.inkTitle : ThemeEnum.inkMuted;

    return Semantics(
      button: true,
      selected: active,
      label: language.displayName,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: REdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: active ? context.getColor(ThemeEnum.inkTitle).withValues(alpha: 0.08) : null,
            borderRadius: BorderRadius.circular(CdRadius.xs),
            border: Border.all(
              color: active
                  ? context.getColor(ThemeEnum.inkTitle).withValues(alpha: 0.28)
                  : context.getColor(ThemeEnum.hairline),
            ),
          ),
          child: SemiBoldText(language.displayName, color: color, fontSize: 10, maxLines: 1),
        ),
      ),
    );
  }
}
