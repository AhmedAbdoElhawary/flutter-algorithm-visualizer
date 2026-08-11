import 'dart:async';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/code_editor.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:algorithm_visualizer/lib-temp/utils/syntax_highlight.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


// ─── Sample code ──────────────────────────────────────────────────────────────
const _dartCode = r'''
// Binary Search Algorithm
int binarySearch(List<int> arr, int target) {
  int left = 0;
  int right = arr.length - 1;

  while (left <= right) {
    int mid = (left + right) ~/ 2;

    if (arr[mid] == target) {
      return mid;
    } else if (arr[mid] < target) {
      left = mid + 1;
    } else {
      right = mid - 1;
    }
  }

  return -1;
}

// Example usage
void main() {
  final arr = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91];
  final idx = binarySearch(arr, 23);

  print(idx); // → 5
}
''';
const _jsCode = r"""// Binary Search Algorithm
function binarySearch(arr, target) {
  let left = 0;
  let right = arr.length - 1;

  while (left <= right) {
    let mid = Math.floor((left + right) / 2);

    if (arr[mid] === target) {
      return mid;
    } else if (arr[mid] < target) {
      left = mid + 1;
    } else {
      right = mid - 1;
    }
  }

  return -1;
}

// Example usage
const arr = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91];
const idx = binarySearch(arr, 23);
console.log(idx); // → 5""";

const _pyCode = r"""# Binary Search Algorithm
def binary_search(arr, target):
    left, right = 0, len(arr) - 1

    while left <= right:
        mid = (left + right) // 2

        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1

    return -1

# Example usage
arr = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91]
idx = binary_search(arr, 23)
print(idx)  # → 5""";

const _topics = ['Binary Search', 'Linked List', 'Two Pointers', 'Dynamic Prog', 'Graph BFS'];

const _testCases = [
  (label: 'Find 23 in array', expected: '5', input: '[2,5,8,12,16,23,38,56,72,91], 23'),
  (label: 'Find 72 in array', expected: '8', input: '[2,5,8,12,16,23,38,56,72,91], 72'),
  (label: 'Target not found', expected: '-1', input: '[2,5,8,12,16,23,38,56,72,91], 10'),
  (label: 'Single element', expected: '0', input: '[7], 7'),
];

// Always-dark code colors
const _codeConsoleRt = Color(0xFF3D506E);
const _codeConsoleTok = Color(0xFF7DCFFF);
const _codeConsoleDef = Color(0xFFC0CAF5);
const _codeConsoleOut = Color(0xFF34D399);
const _codeBg = Color(0xFF0D1117);

// ─── Screen ───────────────────────────────────────────────────────────────────

class CodeEditorPage extends StatefulWidget {
  const CodeEditorPage({super.key});
  @override
  State<CodeEditorPage> createState() => _CodeEditorPageState();
}

class _CodeEditorPageState extends State<CodeEditorPage> {
  String _lang = 'js';
  int _topicIdx = 0;
  bool _running = false;
  bool _showOutput = false;
  bool _copied = false;
  int? _hlLine;
  Timer? _timer;

  String get _code => _lang == 'js' ? _jsCode : _pyCode;

  void _handleRun() {
    if (_running) return;
    setState(() {
      _running = true;
      _showOutput = false;
      _hlLine = null;
    });
    final lines = [3, 4, 7, 9, 11, 14, 9, 11, 14, 9, 12, 9];
    int idx = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 120), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (idx < lines.length) {
        setState(() => _hlLine = lines[idx++]);
      } else {
        t.cancel();
        setState(() {
          _hlLine = null;
          _running = false;
          _showOutput = true;
        });
      }
    });
  }

  void _handleCopy() {
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              _buildLangBar(context, isDark),
              _buildCodeView(context),
              if (_showOutput) _buildOutput(context),
              _buildComplexityCards(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('CODE EDITOR',
            style: GoogleFonts.inter(
                color: context.textMuted, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Row(children: [
          Text(_topics[_topicIdx],
              style: GoogleFonts.inter(
                  color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: context.textMuted),
          const Spacer(),
          _badge('Easy', context.accentBlue, isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE), context),
          const SizedBox(width: 8),
          Text('O(log n)', style: GoogleFonts.inter(color: context.textMuted, fontSize: 11)),
        ]),
        const SizedBox(height: 10),
        // Topic pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: _topics.asMap().entries.map((e) {
                final active = e.key == _topicIdx;
                return GestureDetector(
                  onTap: () => setState(() {
                    _topicIdx = e.key;
                    _showOutput = false;
                    _hlLine = null;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: active ? (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE)) : context.bgCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                          active ? (isDark ? const Color(0x663B82F6) : const Color(0x662563EB)) : context.borderColor),
                      boxShadow: context.cardShadow,
                    ),
                    child: Text(e.value,
                        style: GoogleFonts.inter(
                          color: active ? context.accentBlue : context.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                );
              }).toList()),
        ),
      ]),
    );
  }

  // ── Language bar ───────────────────────────────────────────────────────────
  Widget _buildLangBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(children: [
        // Lang toggle
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: context.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.borderColor),
            boxShadow: context.cardShadow,
          ),
          child: Row(children: [
            for (final l in ['js', 'py'])
              GestureDetector(
                onTap: () => setState(() {
                  _lang = l;
                  _showOutput = false;
                  _hlLine = null;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: _lang == l ? context.accentBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    l == 'js' ? 'JavaScript' : 'Python',
                    style: GoogleFonts.inter(
                      color: _lang == l ? context.accent : context.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ]),
        ),
        const Spacer(),
        // Copy button
        GestureDetector(
          onTap: _handleCopy,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.borderColor),
              boxShadow: context.cardShadow,
            ),
            child: Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 15,
              color: _copied ? context.accentGreen : context.textMuted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Run button
        GestureDetector(
          onTap: _running ? null : _handleRun,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _running ? context.bgCard : null,
              gradient: _running
                  ? null
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [context.accentGreen, isDark ? const Color(0xFF10B981) : const Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(9),
              border: _running ? Border.all(color: context.borderColor) : null,
              boxShadow: _running
                  ? context.cardShadow
                  : [
                BoxShadow(
                    color: context.accentGreen.withValues(alpha: isDark ? 0.3 : 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.play_arrow_rounded, size: 14, color: _running ? context.textMuted : Colors.white),
              const SizedBox(width: 4),
              Text(_running ? 'Running…' : 'Run',
                  style: GoogleFonts.inter(
                    color: _running ? context.textMuted : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── Code view ──────────────────────────────────────────────────────────────
  Widget _buildCodeView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: CodeEditorBlock(_dartCode),
      // child: CodeBlockContainer(
      //   code: _code,
      //   lang: _lang,
      //   highlightLine: _hlLine,
      //   executing: _running,
      // ),
    );
  }

  // ── Output ─────────────────────────────────────────────────────────────────
  Widget _buildOutput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: Container(
          decoration: BoxDecoration(
            color: context.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.accentGreen.withValues(alpha: 0.18)),
            boxShadow: context.cardShadow,
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Container(
              color: context.bgElevated,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(children: [
                Icon(Icons.terminal_rounded, size: 14, color: context.accentGreen),
                const SizedBox(width: 6),
                Text('Output',
                    style: GoogleFonts.inter(color: context.accentGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: context.accentGreenBg, borderRadius: BorderRadius.circular(6)),
                  child: Text('All tests passed ✓',
                      style: GoogleFonts.inter(color: context.accentGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            // Test cases
            ..._testCases.asMap().entries.map((e) {
              final i = e.key;
              final tc = e.value;
              return Container(
                padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
                decoration: i > 0 ? BoxDecoration(border: Border(top: BorderSide(color: context.borderColor))) : null,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                        color: context.accentGreenBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.accentGreen.withValues(alpha: 0.6), width: 1.4)),
                    child: Icon(Icons.check_rounded, size: 10, color: context.accentGreen),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(tc.label, style: GoogleFonts.inter(color: context.textSec, fontSize: 12)),
                        const SizedBox(height: 2),
                        RichText(
                            text: TextSpan(style: GoogleFonts.jetBrainsMono(fontSize: 11), children: [
                              TextSpan(text: '→ ', style: TextStyle(color: context.textMuted)),
                              TextSpan(text: tc.expected, style: TextStyle(color: context.accentGreen)),
                            ])),
                      ])),
                  Text('0ms', style: GoogleFonts.inter(color: context.textMuted, fontSize: 10)),
                ]),
              );
            }),
            // Console
            Container(
              width: double.infinity,
              color: _codeBg,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: RichText(
                  text: const TextSpan(
                      style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, height: 1.6),
                      children: [
                        TextSpan(text: '> ', style: TextStyle(color: _codeConsoleRt)),
                        TextSpan(text: 'console.log', style: TextStyle(color: _codeConsoleTok)),
                        TextSpan(text: '(binarySearch(arr, 23))\n', style: TextStyle(color: _codeConsoleDef)),
                        TextSpan(text: '← ', style: TextStyle(color: _codeConsoleRt)),
                        TextSpan(text: '5', style: TextStyle(color: _codeConsoleOut)),
                      ])),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Complexity cards ───────────────────────────────────────────────────────
  Widget _buildComplexityCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        Expanded(child: _complexityCard(context, 'Time Complexity', 'O(log n)', 'Logarithmic', context.accent)),
        const SizedBox(width: 10),
        Expanded(child: _complexityCard(context, 'Space Complexity', 'O(1)', 'Constant', context.accentGreen)),
      ]),
    );
  }

  Widget _complexityCard(BuildContext context, String label, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: context.cardDecoration(),
      child: Column(children: [
        Text(label, style: GoogleFonts.inter(color: context.textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.jetBrainsMono(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(sub, style: GoogleFonts.inter(color: context.textMuted, fontSize: 11)),
      ]),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _badge(String text, Color fg, Color bg, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: GoogleFonts.inter(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
