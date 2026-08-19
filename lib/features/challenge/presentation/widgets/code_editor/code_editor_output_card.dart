// import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
// import 'package:algorithm_visualizer/features/challange/challange/domain/entities/execution_result.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// const _codeConsoleRt = Color(0xFF3D506E);
// const _codeConsoleOut = Color(0xFF34D399);
// const _codeBg = Color(0xFF0D1117);
//
// class CodeEditorOutputCard extends StatelessWidget {
//   const CodeEditorOutputCard({super.key, required this.result});
//
//   final ExecutionResult result;
//
//   @override
//   Widget build(BuildContext context) {
//     return SliverPadding(
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
//       sliver: SliverToBoxAdapter(
//         child: AnimatedSize(
//           duration: const Duration(milliseconds: 250),
//           child: Container(
//             decoration: BoxDecoration(
//               color: context.getColor(ThemeEnum.card),
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: context.getColor(ThemeEnum.accentGreen).withValues(alpha: 0.18)),
//               boxShadow: context.cardShadow,
//             ),
//             clipBehavior: Clip.hardEdge,
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               _Header(allPassed: result.allPassed),
//               ...result.testCaseResults.asMap().entries.map(
//                     (e) => _TestCaseRow(index: e.key, result: e.value),
//                   ),
//               _Console(output: result.consoleOutput),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _Header extends StatelessWidget {
//   const _Header({required this.allPassed});
//   final bool allPassed;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: context.getColor(ThemeEnum.outputHeader),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       child: Row(children: [
//         Icon(Icons.terminal_rounded, size: 14, color: context.getColor(ThemeEnum.accentGreen)),
//         const SizedBox(width: 6),
//         Text('Output',
//             style: GoogleFonts.inter(color: context.getColor(ThemeEnum.accentGreen), fontSize: 12, fontWeight: FontWeight.w600)),
//         const Spacer(),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//           decoration: BoxDecoration(color: context.getColor(ThemeEnum.accentGreenBg), borderRadius: BorderRadius.circular(6)),
//           child: Text(
//             allPassed ? 'All tests passed ✓' : 'Some tests failed',
//             style: GoogleFonts.inter(color: context.getColor(ThemeEnum.accentGreen), fontSize: 11, fontWeight: FontWeight.w600),
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// class _TestCaseRow extends StatelessWidget {
//   const _TestCaseRow({required this.index, required this.result});
//   final int index;
//   final TestCaseResult result;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
//       decoration: index > 0 ? BoxDecoration(border: Border(top: BorderSide(color: context.getColor(ThemeEnum.border)))) : null,
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           width: 18,
//           height: 18,
//           decoration: BoxDecoration(
//               color: context.getColor(ThemeEnum.accentGreenBg),
//               shape: BoxShape.circle,
//               border: Border.all(color: context.getColor(ThemeEnum.accentGreen).withValues(alpha: 0.6), width: 1.4)),
//           child: Icon(
//             result.passed ? Icons.check_rounded : Icons.close_rounded,
//             size: 10,
//             color: context.getColor(ThemeEnum.accentGreen),
//           ),
//         ),
//         const SizedBox(width: 10),
//         // Expanded(
//         //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         //   Text(result.testCase.label, style: GoogleFonts.inter(color: context.getColor(ThemeEnum.textSecond), fontSize: 12)),
//         //   const SizedBox(height: 2),
//         //   RichText(
//         //       text: TextSpan(style: GoogleFonts.jetBrainsMono(fontSize: 11), children: [
//         //     TextSpan(text: '→ ', style: TextStyle(color: context.getColor(ThemeEnum.hover))),
//         //     TextSpan(text: result.testCase.expectedOutput, style: TextStyle(color: context.getColor(ThemeEnum.accentGreen))),
//         //   ])),
//         // ])),
//       ]),
//     );
//   }
// }
//
// class _Console extends StatelessWidget {
//   const _Console({required this.output});
//   final String output;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       color: _codeBg,
//       padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
//       child: RichText(
//         text: TextSpan(
//           style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, height: 1.6),
//           children: [
//             const TextSpan(text: '← ', style: TextStyle(color: _codeConsoleRt)),
//             TextSpan(text: output, style: const TextStyle(color: _codeConsoleOut)),
//           ],
//         ),
//       ),
//     );
//   }
// }
