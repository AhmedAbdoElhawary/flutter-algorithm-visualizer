import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/bottom_cta_bar.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_back_button.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/difficulty_chip.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/primary_button_quiet.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/example.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/problem_tile.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

enum _ProblemTab { problem, hints, similar }

class ProblemPage extends ConsumerStatefulWidget {
  const ProblemPage({super.key, required this.problemId});

  final int problemId;

  @override
  ConsumerState<ProblemPage> createState() => _ProblemPageState();
}

class _ProblemPageState extends ConsumerState<ProblemPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _ProblemTab.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setTabScrollable(int index) {
    _tabController.animateTo(index, duration: const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    final problemId = widget.problemId <= 0
        ? (ref.read(homeDataProvider.select((s) => s.continueProblem))?.getProblemId ?? -1)
        : widget.problemId;

    final problem = ref.watch(getProblemProvider(problemId).select((a) => a.value));

    // Scaffold/Metrial written in base_navigation, why?
    // to control all main pages with the structure of them
    if (problem == null) return const Center(child: MediumText(StringsManager.noChallengeSelected));

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(child: _CollapsingHeaderTags(problem: problem)),
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: context.getColor(ThemeEnum.primary),
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                leading: const SizedBox.shrink(),
                flexibleSpace: _ProblemTabBar(controller: _tabController),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _ProblemTabView(
                  problem: problem,
                  onScrollableChanged: (scrollable) => _setTabScrollable(0),
                ),
                _HintsTabView(
                  problem: problem,
                  onScrollableChanged: (scrollable) => _setTabScrollable(1),
                ),
                _SimilarTabView(
                  problem: problem,
                  onScrollableChanged: (scrollable) => _setTabScrollable(2),
                ),
              ],
            ),
          ),
          _PinnedCta(
            onSolve: () {
              final isSubProblem = GoRouterState.of(context).name == Routes.subProblem.name;
              context.pushRoute(
                isSubProblem ? Routes.subEditor : Routes.editor,
                queryParameters: "${problem.getProblemId}",
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CollapsingHeaderTags extends StatelessWidget {
  const _CollapsingHeaderTags({required this.problem});

  final CodingProblem problem;

  @override
  Widget build(BuildContext context) {
    final chipDifficulty = problem.getDifficulty;
    final tags = problem.getTags;
    return Padding(
      padding: REdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomBackButton(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BoldText(problem.getName, color: ThemeEnum.textPrimary, fontSize: 17, maxLines: 1),
                if (tags.isNotEmpty) ...[
                  const RSizedBox(height: 2),
                  RegularText(tags.join(', '), color: ThemeEnum.textSecond, fontSize: 10, maxLines: 1),
                ],
              ],
            ),
          ),
          if (chipDifficulty != ProblemDifficulty.none) ...[
            const RSizedBox(width: 8),
            DifficultyChip(difficulty: chipDifficulty, label: problem.getDifficulty.difficultyString),
          ],
        ],
      ),
    );
  }
}

class _ProblemTabBar extends StatelessWidget {
  const _ProblemTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.getColor(ThemeEnum.primary),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: context.getColor(ThemeEnum.hover),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: context.getColor(ThemeEnum.solidWhite),
        labelColor: context.getColor(ThemeEnum.textPrimary),
        unselectedLabelColor: context.getColor(ThemeEnum.textSecond),
        overlayColor: WidgetStatePropertyAll(context.getColor(ThemeEnum.hover).withValues(alpha: 0.05)),
        labelStyle: GetSemiBoldStyle(fontSize: 12.sp),
        unselectedLabelStyle: GetMediumStyle(fontSize: 12.sp),
        tabs: const [
          Tab(text: StringsManager.problemTab),
          Tab(text: StringsManager.hints),
          Tab(text: StringsManager.similarQuestions),
        ],
      ),
    );
  }
}

class _ProblemTabView extends StatefulWidget {
  const _ProblemTabView({required this.problem, required this.onScrollableChanged});

  final CodingProblem problem;
  final ValueChanged<bool> onScrollableChanged;

  @override
  State<_ProblemTabView> createState() => _ProblemTabViewState();
}

class _ProblemTabViewState extends State<_ProblemTabView> {
  final ValueNotifier<bool> _constraintsOpen = ValueNotifier(false);

  @override
  void dispose() {
    _constraintsOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final problem = widget.problem;
    return _MeasuredTabScrollView(
      pageStorageKey: PageStorageKey('problem-${problem.getProblemId}-problem'),
      children: [
        if (problem.getDescription.trim().isNotEmpty)
          RegularText(
            problem.getDescription.trim(),
            color: ThemeEnum.textBody,
            fontSize: 12.5,
            height: 1.75,
            maxLines: 40,
          ),
        if (problem.getConstraints.isNotEmpty) ...[
          const RSizedBox(height: 13),
          ValueListenableBuilder(
            valueListenable: _constraintsOpen,
            builder: (context, value, child) => _ConstraintsCard(
              constraints: problem.getConstraints,
              open: value,
              onToggle: () => setState(() => _constraintsOpen.value = !value),
            ),
          ),
        ],
        for (var i = 0; i < problem.getExamples.length; i++) ...[
          const RSizedBox(height: 13),
          _ExampleBlock(index: i, example: problem.getExamples[i]),
        ],
      ],
    );
  }
}

class _HintsTabView extends StatelessWidget {
  const _HintsTabView({required this.problem, required this.onScrollableChanged});

  final CodingProblem problem;
  final ValueChanged<bool> onScrollableChanged;

  @override
  Widget build(BuildContext context) {
    final hints = problem.getHints;
    return _MeasuredTabScrollView(
      pageStorageKey: PageStorageKey('problem-${problem.getProblemId}-hints'),
      children: hints.isEmpty
          ? const [MediumText(StringsManager.noHintsYet, color: ThemeEnum.textSecond)]
          : [
              for (var i = 0; i < hints.length; i++)
                Padding(
                  padding: REdgeInsets.only(bottom: 10),
                  child: CardContainer(
                    surface: CdSurface.secondary,
                    child: RegularText('${i + 1}.  ${hints[i]}',
                        color: ThemeEnum.textBody, fontSize: 12, height: 1.6, maxLines: 20),
                  ),
                ),
            ],
    );
  }
}

class _SimilarTabView extends ConsumerStatefulWidget {
  const _SimilarTabView({required this.problem, required this.onScrollableChanged});

  final CodingProblem problem;
  final ValueChanged<bool> onScrollableChanged;

  @override
  ConsumerState<_SimilarTabView> createState() => _SimilarTabViewState();
}

class _SimilarTabViewState extends ConsumerState<_SimilarTabView> {
  int _expandedId = 0;

  @override
  Widget build(BuildContext context) {
    final problem = widget.problem;

    final similarIds = ref.read(similarProblemIdsProvider(problem));

    return _MeasuredTabScrollView(
      pageStorageKey: PageStorageKey('problem-${problem.getProblemId}-similar'),
      children: similarIds.isEmpty
          ? const [MediumText(StringsManager.noSimilarQuestionsYet, color: ThemeEnum.textSecond)]
          : [
              for (final similarId in similarIds)
                ProblemTile(
                  problemId: similarId,
                  expanded: _expandedId == similarId,
                  onToggle: () => setState(() => _expandedId = _expandedId == similarId ? 0 : similarId),
                  onSolveTap: () => context.pushRoute(Routes.subProblem, queryParameters: "$similarId"),
                ),
            ],
    );
  }
}

class _MeasuredTabScrollView extends StatefulWidget {
  const _MeasuredTabScrollView({
    required this.pageStorageKey,
    required this.children,
  });

  final Key pageStorageKey;
  final List<Widget> children;

  @override
  State<_MeasuredTabScrollView> createState() => _MeasuredTabScrollViewState();
}

class _MeasuredTabScrollViewState extends State<_MeasuredTabScrollView> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: widget.pageStorageKey,
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: REdgeInsets.fromLTRB(16, 4, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: kBottomPageSpacing * 4)),
      ],
    );
  }
}

class _ConstraintsCard extends StatelessWidget {
  const _ConstraintsCard({required this.constraints, required this.open, required this.onToggle});

  final List<String> constraints;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      surface: CdSurface.main,
      padding: REdgeInsets.symmetric(horizontal: 15, vertical: 13),
      onTap: onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SemiBoldText(StringsManager.constraints, color: ThemeEnum.textBright, fontSize: 12),
              ),
              CustomIcon(open ? Icons.remove_rounded : Icons.add_rounded,
                  size: 16, color: ThemeEnum.textSecond),
            ],
          ),
          AnimatedSize(
            duration: CdMotion.expand,
            curve: Curves.easeInOut,
            child: open
                ? Padding(
                    padding: REdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final c in constraints)
                          Padding(
                            padding: REdgeInsets.only(bottom: 4),
                            child: RegularText('•  $c',
                                color: ThemeEnum.textBody, fontSize: 11.5, height: 1.5, maxLines: 10),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ExampleBlock extends StatelessWidget {
  const _ExampleBlock({required this.index, required this.example});

  final int index;
  final Example example;

  @override
  Widget build(BuildContext context) {
    final explanation = example.explanation?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemiBoldText(
          '${StringsManager.example} ${index + 1}'.toUpperCase(),
          color: ThemeEnum.textSecond,
          fontSize: 10,
          letterSpacing: 1,
        ),
        const RSizedBox(height: 9),
        CardContainer(
          surface: CdSurface.secondary,
          padding: REdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((example.input ?? '').trim().isNotEmpty)
                _MonoRow(label: StringsManager.input, value: example.input!.trim(), strong: false),
              if ((example.output ?? '').trim().isNotEmpty) ...[
                const RSizedBox(height: 7),
                _MonoRow(label: StringsManager.output, value: example.output!.trim(), strong: true),
              ],
              if (explanation != null && explanation.isNotEmpty) ...[
                const RSizedBox(height: 7),
                Container(height: 1, color: context.getColor(ThemeEnum.borderSubtle)),
                Padding(
                  padding: REdgeInsets.only(top: 7),
                  child: RegularText(
                    explanation,
                    color: ThemeEnum.textSecond,
                    fontFamily: FontConstants.fontJetBrainsMono,
                    fontSize: 11,
                    height: 1.6,
                    maxLines: 20,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MonoRow extends StatelessWidget {
  const _MonoRow({required this.label, required this.value, required this.strong});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegularText('$label: ',
            color: ThemeEnum.textBody,
            fontFamily: FontConstants.fontJetBrainsMono,
            fontSize: 11,
            maxLines: 1),
        Expanded(
          child: RegularText(
            value,
            color: strong ? ThemeEnum.textPrimary : ThemeEnum.textBright,
            fontFamily: FontConstants.fontJetBrainsMono,
            fontSize: 11,
            height: 1.5,
            maxLines: 10,
          ),
        ),
      ],
    );
  }
}

class _PinnedCta extends StatelessWidget {
  const _PinnedCta({required this.onSolve});

  final VoidCallback onSolve;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: BottomCtaBar(
        child: PrimaryButtonQuiet(label: StringsManager.solveInEditor, onPressed: onSolve),
      ),
    );
  }
}
