// import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
// import 'package:algorithm_visualizer/features/challange/data/models/problem_dto.dart';
// import 'package:algorithm_visualizer/features/challange/presentation/helper/problem_style.dart';
// import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges_notifier.dart';
// import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges_providers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class ChallengesFilterTabs extends ConsumerWidget {
//   const ChallengesFilterTabs({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final activeFilter = ref.watch(challengesProvider.select((s) => s.filter));
//
//     return Padding(
//       padding: REdgeInsets.fromLTRB(16, 0, 16, 14),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: ChallengesNotifier.filters.map((f) {
//             final active = activeFilter == f;
//             final color = f == ProblemDifficulty.all
//                 ? context.getColor(ThemeEnum.accent)
//                 : ProblemStyle.difficultyColor(context, f);
//             final count = ref.watch(difficultyCountProvider(f));
//
//             return GestureDetector(
//               onTap: () => ref.read(challengesProvider.notifier).setFilter(f),
//               child: Container(
//                 margin: REdgeInsetsDirectional.only(end: 8),
//                 padding: REdgeInsets.symmetric(horizontal: 14, vertical: 7),
//                 decoration: BoxDecoration(
//                   color: active ? color.withValues(alpha: 0.10) : context.getColor(ThemeEnum.card),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: active ? color.withValues(alpha: 0.35) : context.getColor(ThemeEnum.border)),
//                   boxShadow: context.cardShadow,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       f.difficultyString,
//                       style: GoogleFonts.inter(
//                         color: active ? color : context.getColor(ThemeEnum.hover),
//                         fontSize: 13.r,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(width: 5),
//                     Text(
//                       '$count',
//                       style: GoogleFonts.inter(
//                         color: active ? color.withValues(alpha: 0.75) : context.getColor(ThemeEnum.hoverSecond),
//                         fontSize: 11.r,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }
