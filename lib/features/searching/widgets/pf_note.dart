// import 'package:algorithm_visualizer/lib%202/pathfinding/models/searching_state.dart';
// import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../providers/searching_notifier.dart';
//
// class PFNote extends ConsumerWidget {
//   const PFNote({required this.instance,super.key});
//   final StateNotifierProvider<SearchingNotifier, SearchingState> instance;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final algo = ref.watch(instance.select((s) => s.algo));
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: context.accentBg,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: context.borderAccent),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('💡 How it works',
//                 style: GoogleFonts.inter(color: context.accent, fontSize: 11, fontWeight: FontWeight.w600)),
//             const SizedBox(height: 4),
//             Text(algo.explanation,
//                 style: GoogleFonts.inter(color: context.textMuted, fontSize: 12, height: 1.5)),
//           ],
//         ),
//       ),
//     );
//   }
// }
