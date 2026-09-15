import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/features/onboarding/data/onboarding_store.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/onboarding_button.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/onboarding_dots.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/onboarding_header.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/onboarding_slide.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/onboarding_text.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/onboarding_tokens.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/visuals/editor_visual.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/visuals/heatmap_visual.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/visuals/pathfinding_visual.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/visuals/sorting_visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// The four-screen first-run flow.
///
/// Every exit — Skip, Get started, Continue as guest — records
/// [OnboardingStore.seenKey], so the flow is shown exactly once.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  static const int pageCount = 4;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();

  int _page = 0;

  /// Screen 4 holds its buttons back until the heatmap has finished filling.
  bool _ctaReady = false;

  /// White, white, white, then sand — the accent progression the flow tells.
  static const List<ThemeEnum> _accents = [
    OnboardingTokens.accent,
    OnboardingTokens.accent,
    OnboardingTokens.accent,
    OnboardingTokens.sand,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.elasticInOut,
    );
  }

  Future<void> _finish({required bool toLogin}) async {
    await ref.read(onboardingStoreProvider).markSeen();
    if (!mounted) return;
    context.goNamed(toLogin ? Routes.login.name : Routes.home.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.getColor(OnboardingTokens.bgBase),
      body: SafeArea(
        child: HorizontalPadding(
          padding: OnboardingTokens.screenPadding,
          child: Column(
            children: [
              OnboardingHeader(onSkip: () => _finish(toLogin: false)),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _page = page),
                  children: [
                    OnboardingSlide(
                      visual: SortingVisual(isActive: _page == 0),
                      headline: StringsManager.onboardingSeeItHeadline,
                      body: StringsManager.onboardingSeeItBody,
                    ),
                    OnboardingSlide(
                      visual: PathfindingVisual(isActive: _page == 1),
                      headline: StringsManager.onboardingExploreHeadline,
                      body: StringsManager.onboardingExploreBody,
                    ),
                    OnboardingSlide(
                      visual: EditorVisual(isActive: _page == 2),
                      headline: StringsManager.onboardingWriteHeadline,
                      body: StringsManager.onboardingWriteBody,
                    ),
                    OnboardingSlide(
                      visual: HeatmapVisual(
                        isActive: _page == 3,
                        onFinished: () {
                          if (mounted && !_ctaReady) {
                            setState(() => _ctaReady = true);
                          }
                        },
                      ),
                      headline: StringsManager.onboardingTrackHeadline,
                      body: StringsManager.onboardingTrackBody,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              OnboardingDots(
                count: OnboardingPage.pageCount,
                currentPage: _page,
                activeColor: _accents[_page],
              ),
              SizedBox(height: 20.h),
              _page == OnboardingPage.pageCount - 1
                  ? _FinalControls(
                      visible: _ctaReady,
                      onGetStarted: () => _finish(toLogin: true),
                      onGuest: () => _finish(toLogin: false),
                    )
                  : OnboardingButton(
                      label: StringsManager.onboardingNext,
                      onPressed: _next,
                    ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen 4's pair. Same height, same radius, same label size — only the fill
/// tells them apart. They rise 8 px and fade in together once the grid lands.
class _FinalControls extends StatelessWidget {
  const _FinalControls({
    required this.visible,
    required this.onGetStarted,
    required this.onGuest,
  });

  final bool visible;
  final VoidCallback onGetStarted;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 0.15),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 260),
        // A fully transparent button would still take taps.
        child: IgnorePointer(
          ignoring: !visible,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OnboardingButton(
                label: StringsManager.onboardingGetStarted,
                style: OnboardingButtonStyle.filled,
                onPressed: onGetStarted,
              ),
              SizedBox(height: 10.h),
              OnboardingButton(
                label: StringsManager.onboardingContinueAsGuest,
                onPressed: onGuest,
              ),
              SizedBox(height: 10.h),
              const MonoText(
                StringsManager.onboardingGuestNote,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
