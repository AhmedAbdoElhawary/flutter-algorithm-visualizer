import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show EditorLanguage, EditorLanguageX, supportedLanguages;
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/code_editor/code_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The colour that stands for a language, drawn as the dot on its row. Reuses
/// the data palette the rest of the app marks things with, so the editor does
/// not introduce a fourth colour vocabulary of its own.
extension _LanguageAccent on EditorLanguage {
  ThemeEnum get accent => switch (this) {
        EditorLanguage.dart => ThemeEnum.dataTarget,
        EditorLanguage.python => ThemeEnum.dataEasy,
        EditorLanguage.javascript => ThemeEnum.dataMedium,
      };
}

/// The language chooser in the title row, beside the copy button.
///
/// A drop-down rather than a row of chips: the title row has the problem name
/// in it, and three chips there would crowd the name off the screen. Closed,
/// it is a quiet outlined control the size of the copy button next to it.
///
/// Every supported language is listed even when a problem cannot take one,
/// disabled with the reason attached. Hiding it would read as the feature
/// being missing rather than as that problem being the exception.
///
/// Switching never warns and never confirms: each language keeps its own
/// draft, so there is nothing to lose (SC-018).
class EditorLanguageMenu extends ConsumerStatefulWidget {
  const EditorLanguageMenu({super.key, required this.problemId});

  final int problemId;

  @override
  ConsumerState<EditorLanguageMenu> createState() => _EditorLanguageMenuState();
}

class _EditorLanguageMenuState extends ConsumerState<EditorLanguageMenu> {
  final _anchor = GlobalKey();
  OverlayEntry? _entry;
  bool _open = false;

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  void _toggle() {
    if (_open) {
      _close();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final box = _anchor.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;

    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final anchorRect = topLeft & box.size;
    final notifier = ref.read(codeEditorControllerProvider(widget.problemId).notifier);

    final entry = OverlayEntry(
      builder: (context) => _LanguageMenuOverlay(
        anchor: anchorRect,
        overlaySize: overlay.size,
        selected: ref.read(codeEditorControllerProvider(widget.problemId)).language,
        available: notifier.languagesAvailable,
        onSelected: (language) {
          notifier.setLanguage(language);
          _close();
        },
        onDismiss: _close,
      ),
    );
    _entry = entry;
    Overlay.of(context).insert(entry);
    setState(() => _open = true);
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = codeEditorControllerProvider(widget.problemId);
    final selected = ref.watch(provider.select((s) => s.language));
    final running = ref.watch(provider.select((s) => s.isRunning));

    return _MenuTrigger(
      key: _anchor,
      language: selected,
      open: _open,
      enabled: !running,
      onTap: running ? null : _toggle,
    );
  }
}

/// What the chooser looks like while closed: an outlined control carrying the
/// language's dot, its name in the editor's own typeface, and the chevron
/// that turns over when the menu opens.
class _MenuTrigger extends StatelessWidget {
  const _MenuTrigger({
    super.key,
    required this.language,
    required this.open,
    required this.enabled,
    required this.onTap,
  });

  final EditorLanguage language;
  final bool open;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: StringsManager.language,
      value: language.displayName,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,

        /// No [Opacity] wrapper. The disabled look is three colours, so it is
        /// expressed as three colours — the same way `icon_button_quiet.dart`
        /// dims to [ThemeEnum.track]. Wrapping instead cost an off-screen
        /// buffer on every paint, and did so even at `opacity: 1`, because an
        /// [Opacity] layer is allocated whatever the value.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: REdgeInsets.symmetric(vertical: 7, horizontal: 10),
          decoration: BoxDecoration(
            color: context.getColor(open ? ThemeEnum.raised : ThemeEnum.transparentColor),
            borderRadius: BorderRadius.circular(CdRadius.smAlt.r),
            border: Border.all(
              color: context.getColor(open ? ThemeEnum.inkThirdTitle : ThemeEnum.hairline),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _LanguageDot(language: language, dim: !enabled),
              const RSizedBox(width: 6),
              SemiBoldText(
                language.displayName,
                fontFamily: FontConstants.fontFamily,
                fontSize: 11,
                color: enabled ? ThemeEnum.inkTitle : ThemeEnum.inkThirdTitle,
                maxLines: 1,
              ),
              const RSizedBox(width: 4),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: CustomIcon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: enabled ? ThemeEnum.inkThirdTitle : ThemeEnum.track,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The open panel: a transparent barrier that catches the dismissing tap, and
/// the card itself pinned under the trigger's trailing edge.
class _LanguageMenuOverlay extends StatefulWidget {
  const _LanguageMenuOverlay({
    required this.anchor,
    required this.overlaySize,
    required this.selected,
    required this.available,
    required this.onSelected,
    required this.onDismiss,
  });

  final Rect anchor;
  final Size overlaySize;
  final EditorLanguage selected;
  final List<EditorLanguage> available;
  final ValueChanged<EditorLanguage> onSelected;
  final VoidCallback onDismiss;

  @override
  State<_LanguageMenuOverlay> createState() => _LanguageMenuOverlayState();
}

class _LanguageMenuOverlayState extends State<_LanguageMenuOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 170),
  );
  late final Animation<double> _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = 186.w;
    // Pinned to the trigger's trailing edge, then nudged back inside the
    // screen if that would hang the card off the side.
    final maxLeft = widget.overlaySize.width - width - CdSpace.x2.w;
    final left = (widget.anchor.right - width).clamp(CdSpace.x2.w, maxLeft > 0 ? maxLeft : 0.0);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
          ),
        ),
        Positioned(
          left: left,
          top: widget.anchor.bottom + CdSpace.x1.h,
          width: width,
          child: FadeTransition(
            opacity: _curve,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, -0.04), end: Offset.zero).animate(_curve),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(_curve),
                // Grows from the corner it is pinned to, not from its middle.
                alignment: Alignment.topRight,
                child: _MenuCard(
                  selected: widget.selected,
                  available: widget.available,
                  onSelected: widget.onSelected,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The card. Flat and outlined like every other surface in the app — the
/// design has no drop shadows anywhere, so this one does not invent any.
class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.selected, required this.available, required this.onSelected});

  final EditorLanguage selected;
  final List<EditorLanguage> available;
  final ValueChanged<EditorLanguage> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.surface),
        borderRadius: BorderRadius.circular(CdRadius.medium.r),
        border: Border.all(color: context.getColor(ThemeEnum.hairline)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final language in supportedLanguages)
            _LanguageOption(
              language: language,
              selected: language == selected,
              available: available.contains(language),
              onTap: () => onSelected(language),
            ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.language,
    required this.selected,
    required this.available,
    required this.onTap,
  });

  final EditorLanguage language;
  final bool selected;
  final bool available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: available,
      enabled: available,
      selected: selected,
      label: language.displayName,
      hint: available ? null : StringsManager.dartOnlyProblem,
      child: GestureDetector(
        onTap: available ? onTap : null,
        behavior: HitTestBehavior.opaque,

        /// Dimmed by colour, not by [Opacity] — see `_MenuTrigger`. It matters
        /// more here than there: the panel builds one of these per language,
        /// so the wrapper meant one off-screen buffer per row.
        child: Container(
          padding: REdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: context.getColor(selected ? ThemeEnum.raised : ThemeEnum.transparentColor),
            borderRadius: BorderRadius.circular(CdRadius.xs.r),
          ),
          child: Row(
            children: <Widget>[
              _LanguageDot(language: language, dim: !available),
              const RSizedBox(width: 8),
              Expanded(
                child: SemiBoldText(
                  language.displayName,
                  fontFamily: FontConstants.fontFamily,
                  fontSize: 11,
                  color: !available
                      ? ThemeEnum.inkThirdTitle
                      : selected
                          ? ThemeEnum.inkTitle
                          : ThemeEnum.inkSecondaryTitle,
                  maxLines: 1,
                ),
              ),
              const RSizedBox(width: 6),
              RegularText(
                '.${language.fileExtension}',
                fontFamily: FontConstants.fontFamily,
                fontSize: 9,
                color: available ? ThemeEnum.inkThirdTitle : ThemeEnum.track,
                maxLines: 1,
              ),
              const RSizedBox(width: 6),
              // One trailing slot, always the same width, so the rows line
              // up whether or not any of them is the current one.
              SizedBox(
                width: 12.r,
                child: selected
                    ? const CustomIcon(Icons.check_rounded, size: 12, color: ThemeEnum.inkTitle)
                    : available
                        ? null
                        : const CustomIcon(Icons.remove_rounded, size: 12, color: ThemeEnum.track),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The small colour mark that identifies a language, echoing the three dots
/// in the code card's own header strip.
class _LanguageDot extends StatelessWidget {
  const _LanguageDot({required this.language, this.dim = false});

  final EditorLanguage language;

  /// Fades the accent for a row the learner cannot pick.
  ///
  /// Alpha on this one colour, rather than an [Opacity] over the whole row —
  /// same idea as `primary_button_quiet.dart`, and it keeps the row out of an
  /// off-screen buffer.
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6.r,
      height: 6.r,
      decoration: BoxDecoration(
        color: context.getColor(language.accent).withValues(alpha: dim ? 0.4 : 1),
        shape: BoxShape.circle,
      ),
    );
  }
}
