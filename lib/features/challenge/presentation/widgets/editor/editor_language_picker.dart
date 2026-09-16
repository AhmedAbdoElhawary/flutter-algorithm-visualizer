import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show EditorLanguage, EditorLanguageX, supportedLanguages;
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The language chips in the code card's header.
///
/// Every language the editor supports is always shown, so the choice is the
/// same shape on every problem. A language this problem has no starter code
/// for is dimmed and untappable rather than hidden — a learner who can see
/// that Python exists but is greyed out here has learned something true,
/// where an absent chip just looks like the feature is missing (FR-027a).
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

  /// The languages this problem can actually be solved in. Anything outside
  /// this list is still drawn, but disabled.
  final List<EditorLanguage> languages;
  final EditorLanguage selected;
  final ValueChanged<EditorLanguage> onSelected;

  /// False while the code is running, when the editor is read-only anyway.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final language in supportedLanguages)
          Padding(
            padding: REdgeInsetsDirectional.only(end: 6),
            child: _LanguageChip(
              language: language,
              active: language == selected,
              available: languages.contains(language),
              onTap: enabled ? () => onSelected(language) : null,
            ),
          ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.language,
    required this.active,
    required this.available,
    required this.onTap,
  });

  final EditorLanguage language;
  final bool active;
  final bool available;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // There is no disabled ink token, so an unavailable chip keeps the muted
    // colour and is dimmed by the Opacity below instead.
    final color = active ? ThemeEnum.inkTitle : ThemeEnum.inkMuted;

    final chip = Semantics(
      button: available,
      enabled: available,
      selected: active,
      label: language.displayName,
      child: GestureDetector(
        onTap: available ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: available ? 1 : 0.5,
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
      ),
    );

    if (available) return chip;
    return Tooltip(message: StringsManager.onlyAvailableInDart, child: chip);
  }
}
