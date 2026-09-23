import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/features/onboarding/view_model/onboarding_store.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_button.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_dots.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_header.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_slide.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_text.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/visuals/editor_visual.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/visuals/heatmap_visual.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/visuals/pathfinding_visual.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/visuals/sorting_visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  /// Live scroll position, not the settled page index. Everything outside the
  /// PageView — dots, controls, which visual is running — reads this, so the
  /// whole screen moves with your finger instead of snapping when the page
  /// change fires.
  double _offset = 0;

  /// White, white, white, then sand — the accent progression the flow tells.
  static const List<ThemeEnum> _accents = [
    ThemeEnum.inkPrimary,
    ThemeEnum.inkPrimary,
    ThemeEnum.inkPrimary,
    ThemeEnum.dataMedium,
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_pageController.hasClients) return;
    if (!_pageController.position.hasContentDimensions) return;
    final page = _pageController.page ?? 0;
    if ((page - _offset).abs() < 0.001) return;
    setState(() => _offset = page);
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
    );
  }

  /// A visual starts a little before its page is fully on screen, so it is
  /// already running when it slides in rather than sitting frozen.
  bool _isActive(int page) => (_offset - page).abs() < 0.6;

  Future<void> _finish({required bool toLogin}) async {
    await ref.read(onboardingStoreProvider).markSeen();
    if (!mounted) return;
    context.pushAndRemoveAll(toLogin ? Routes.login : Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    // 0 on page 3, 1 on page 4, and every value in between while swiping.
    final reveal = (_offset - (OnboardingPage.pageCount - 2)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.ground),
      body: SafeArea(
        child: HorizontalPadding(
          padding: 22,
          child: Column(
            children: [
              OnboardingHeader(onSkip: () => _finish(toLogin: false)),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    OnboardingSlide(
                      visual: SortingVisual(isActive: _isActive(0)),
                      headline: StringsManager.onboardingSeeItHeadline,
                      body: StringsManager.onboardingSeeItBody,
                    ),
                    OnboardingSlide(
                      visual: PathfindingVisual(isActive: _isActive(1)),
                      headline: StringsManager.onboardingExploreHeadline,
                      body: StringsManager.onboardingExploreBody,
                    ),
                    OnboardingSlide(
                      visual: EditorVisual(isActive: _isActive(2)),
                      headline: StringsManager.onboardingWriteHeadline,
                      body: StringsManager.onboardingWriteBody,
                    ),
                    OnboardingSlide(
                      visual: HeatmapVisual(isActive: _isActive(3)),
                      headline: StringsManager.onboardingTrackHeadline,
                      body: StringsManager.onboardingTrackBody,
                    ),
                  ],
                ),
              ),
              const RSizedBox(height: 10),
              OnboardingDots(offset: _offset, accents: _accents),
              const RSizedBox(height: 10),
              _Controls(
                reveal: reveal,
                onNext: _next,
                onGetStarted: () => _finish(toLogin: true),
                onGuest: () => _finish(toLogin: false),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// The controls strip.
///
/// One box that grows from a single `Next` to the two final buttons as
/// [reveal] goes 0 -> 1. Both layouts are bottom-anchored inside it and
/// cross-fade, so nothing is ever inserted or removed mid-swipe — which is
/// what used to make the page jump when the last page settled.
class _Controls extends StatelessWidget {
  const _Controls({
    required this.reveal,
    required this.onNext,
    required this.onGetStarted,
    required this.onGuest,
  });

  /// 0 while `Next` owns the strip, 1 once the final pair does.
  final double reveal;

  final VoidCallback onNext;
  final VoidCallback onGetStarted;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    const single = 52;
    const dual = single * 2 + 10 * 2 + 24;

    return SizedBox(
      height: (single + (dual - single) * reveal).h,
      child: Stack(
        children: [
          if (reveal < 1)
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 0,

              /// [FadeTransition], not [Opacity], for both halves of this
              /// cross-fade. [reveal] changes on every `PageController` tick,
              /// so this repaints continuously for the length of a swipe, and
              /// `Opacity` resolves that with a `saveLayer` — an off-screen
              /// buffer — while `FadeTransition` marks the subtree for
              /// compositing and fades it as a layer instead.
              ///
              /// [reveal] is a plain double rather than an `Animation` (it is
              /// driven by the scroll offset, see `_onScroll`), hence the
              /// [AlwaysStoppedAnimation] wrapper. It is already clamped to
              /// 0..1 where it is computed.
              child: FadeTransition(
                opacity: AlwaysStoppedAnimation<double>(1 - reveal),
                child: IgnorePointer(
                  ignoring: reveal > 0.5,
                  child: OnboardingButton(
                    label: StringsManager.onboardingNext,
                    onPressed: onNext,
                  ),
                ),
              ),
            ),
          if (reveal > 0)
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 0,
              child: FadeTransition(
                opacity: AlwaysStoppedAnimation<double>(reveal),
                child: IgnorePointer(
                  ignoring: reveal < 0.5,
                  // The 8 px rise the spec asks for, now driven by the swipe
                  // instead of waiting on the heatmap.
                  child: Transform.translate(
                    offset: Offset(0, 8.h * (1 - reveal)),
                    child: _FinalControls(
                      onGetStarted: onGetStarted,
                      onGuest: onGuest,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Screen 4's pair. Same height, same radius, same label size — only the fill
/// tells them apart. Fading and rising are [_Controls]' job, not theirs.
class _FinalControls extends StatelessWidget {
  const _FinalControls({required this.onGetStarted, required this.onGuest});

  final VoidCallback onGetStarted;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
