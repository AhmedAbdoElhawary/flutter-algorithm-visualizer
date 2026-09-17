import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/ltr_content.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_card.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Screen 3 · Write it — the solution finishes typing itself, then twelve test
/// ticks fill left to right. The ticks are the progress; there is no spinner.
class EditorVisual extends StatefulWidget {
  const EditorVisual({required this.isActive, super.key});

  final bool isActive;

  @override
  State<EditorVisual> createState() => _EditorVisualState();
}

class _EditorVisualState extends State<EditorVisual> with SingleTickerProviderStateMixin {
  /// How many lines, counted from the bottom, are typed in rather than already
  /// on screen. The spec pins this at the last two.
  static const int _typedLines = 2;
  static const int _testCount = 12;

  static const int _charMs = 24;
  static const int _caretBlinkMs = 500;
  static const int _caretBlinks = 2;
  static const int _tickMs = 45;
  static const int _verdictFadeMs = 300;
  static const int _holdMs = 1400;

  static final List<String> _lines = StringsManager.onboardingCodeSample.split('\n');

  late final int _typedChars =
      _lines.skip(_lines.length - _typedLines).fold<int>(0, (total, line) => total + line.length);

  late final int _typingMs = _typedChars * _charMs;
  late final int _caretMs = _caretBlinks * 2 * _caretBlinkMs;
  late final int _runMs = _testCount * _tickMs;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _typingMs + _caretMs + _runMs + _verdictFadeMs + _holdMs),
  );

  @override
  void didUpdateWidget(EditorVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  void _sync() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
      return;
    }
    if (widget.isActive) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingCard(
      clip: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _EditorFileRow(),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final elapsed = _controller.value * _controller.duration!.inMilliseconds;
              final typed = (elapsed / _charMs).floor().clamp(0, _typedChars);

              final runMs = elapsed - _typingMs - _caretMs;
              final ticks = runMs <= 0 ? 0 : (runMs / _tickMs).floor().clamp(0, _testCount);
              final verdict = runMs <= _runMs ? 0.0 : ((runMs - _runMs) / _verdictFadeMs).clamp(0.0, 1.0);

              // Two blinks between the last character and the first tick.
              final caretMs = elapsed - _typingMs;
              final caretVisible =
                  caretMs >= 0 && caretMs < _caretMs && (caretMs / _caretBlinkMs).floor().isEven;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CodeBlock(
                    lines: _lines,
                    typedLines: _typedLines,
                    typedChars: typed,
                    showCaret: caretVisible,
                  ),
                  _TestResults(
                    total: _testCount,
                    passed: ticks,
                    verdictOpacity: verdict,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EditorFileRow extends StatelessWidget {
  const _EditorFileRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.getColor(ThemeEnum.hairline)),
        ),
      ),
      child: const SymmetricPadding(
        horizontal: 16,
        vertical: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MonoText(StringsManager.onboardingEditorFile, translate: false),
            MonoText(StringsManager.onboardingEditorLanguage, translate: false),
          ],
        ),
      ),
    );
  }
}

/// The syntax-coloured sample. The font size is measured down from 12.5 so the
/// longest line always fits the card, at 360 px as much as at 430 px.
class _CodeBlock extends StatelessWidget {
  const _CodeBlock({
    required this.lines,
    required this.typedLines,
    required this.typedChars,
    required this.showCaret,
  });

  final List<String> lines;
  final int typedLines;
  final int typedChars;
  final bool showCaret;

  static const double _baseFontSize = 12.5;
  static const double _lineHeight = 1.45;

  /// Room left for the caret, plus a little slack so rounding between the
  /// measurement and the real layout can never tip a line over the edge.
  static const double _caretAllowance = 4;
  static const double _fitSlack = 0.98;

  double _fitFontSize(double available) {
    final longest = lines.reduce((a, b) => a.length >= b.length ? a : b);
    final painter = TextPainter(
      text: TextSpan(
        text: longest,
        style: TextStyle(
          fontFamily: FontConstants.fontFamily,
          fontSize: _baseFontSize.sp,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final width = painter.width;
    painter.dispose();
    final budget = (available - _caretAllowance) * _fitSlack;
    if (width <= budget || width == 0) return _baseFontSize;
    return _baseFontSize * (budget / width);
  }

  @override
  Widget build(BuildContext context) {
    final firstTypedLine = lines.length - typedLines;

    /// The sample is Dart source, so it does not mirror. `_fitFontSize`
    /// already measures it with an explicit `TextDirection.ltr`; this makes
    /// what is painted agree with what was measured.
    return LtrContent(
      child: AllPadding(
        padding: 16,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fontSize = _fitFontSize(constraints.maxWidth);
            // Characters already typed are consumed line by line, so a line only
            // starts appearing once the one above it is finished.
            var remaining = typedChars;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(lines.length, (index) {
                final line = lines[index];
                String visible;
                var caretHere = false;

                if (index < firstTypedLine) {
                  visible = line;
                } else {
                  final take = remaining.clamp(0, line.length);
                  visible = line.substring(0, take);
                  caretHere = showCaret && index == lines.length - 1;
                  remaining -= take;
                }

                return BottomPadding(
                  padding: index == lines.length - 1 ? 0 : 4,
                  child: _CodeLine(
                    text: visible,
                    fontSize: fontSize,
                    showCaret: caretHere,
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine({required this.text, required this.fontSize, required this.showCaret});

  final String text;
  final double fontSize;
  final bool showCaret;

  /// Whole-word match on the keywords and the function name. Everything else
  /// stays body grey — the sample never needs more than three colours.
  static final RegExp _pattern = RegExp(
    '\\b(${[...StringsManager.onboardingCodeKeywords, StringsManager.onboardingCodeFunction].join('|')})\\b',
  );

  List<({String text, ThemeEnum color})> _tokens() {
    final tokens = <({String text, ThemeEnum color})>[];
    var cursor = 0;
    for (final match in _pattern.allMatches(text)) {
      if (match.start > cursor) {
        tokens.add((text: text.substring(cursor, match.start), color: ThemeEnum.inkBody));
      }
      tokens.add((
        text: match[0]!,
        color:
            match[0] == StringsManager.onboardingCodeFunction ? ThemeEnum.dataTarget : ThemeEnum.dataMedium,
      ));
      cursor = match.end;
    }
    if (cursor < text.length) {
      tokens.add((text: text.substring(cursor), color: ThemeEnum.inkBody));
    }
    return tokens;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final token in _tokens())
          RegularText(
            token.text,
            fontSize: fontSize,
            height: _CodeBlock._lineHeight,
            color: token.color,
            maxLines: 1,
            fontFamily: FontConstants.fontFamily,
          ),
        // if (showCaret)
        Container(
          width: 2.w,
          height: (fontSize * _CodeBlock._lineHeight).sp,
          color: Colors.transparent,
        ),
      ],
    );
  }
}

/// `TEST CASES`, the rolling verdict, twelve ticks and the offline note.
class _TestResults extends StatelessWidget {
  const _TestResults({
    required this.total,
    required this.passed,
    required this.verdictOpacity,
  });

  final int total;
  final int passed;
  final double verdictOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.getColor(ThemeEnum.hairline)),
        ),
      ),
      child: SymmetricPadding(
        horizontal: 16,
        vertical: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(child: MonoText(StringsManager.testCases, letterSpacing: 0.96)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MonoBoldText(
                      StringsManager.onboardingTestCount(passed, total),
                      color: ThemeEnum.dataEasy,
                    ),
                    FadeTransition(
                      opacity: AlwaysStoppedAnimation<double>(verdictOpacity),
                      child: const MonoBoldText(
                        StringsManager.onboardingPassedWord,
                        color: ThemeEnum.dataEasy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            RSizedBox(height: 11.h),
            Row(
              children: List<Widget>.generate(total, (index) {
                return Expanded(
                  child: EndPadding(
                    padding: index == total - 1 ? 0 : 5,
                    child: Container(
                      height: 3.h,
                      decoration: BoxDecoration(
                        color: context.getColor(
                          index < passed ? ThemeEnum.dataEasy : ThemeEnum.track,
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 11.h),
            const MonoText(StringsManager.onboardingGradedOnDevice),
          ],
        ),
      ),
    );
  }
}
