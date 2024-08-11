part of "../view/grid_page.dart";

class _SearcherGrid extends StatefulWidget {
  const _SearcherGrid();

  @override
  State<_SearcherGrid> createState() => _SearcherGridState();
}

class _SearcherGridState extends State<_SearcherGrid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _shapeAnimation;

  final startColor = ColorManager.darkBlue;
  final mediumColor = ColorManager.mediumBlue;
  final finishedSearcherColor = ColorManager.finishedSearcherBlue;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Define the scale animation from 0.1 to 1.2 then back to 1.0
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: 1.4), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 40),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Define the color animation
    _colorAnimation = TweenSequence([
      TweenSequenceItem(tween: ColorTween(begin: startColor, end: mediumColor), weight: 40),
      TweenSequenceItem(tween: ColorTween(begin: mediumColor, end: finishedSearcherColor), weight: 60),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
      ),
    );

    //                             (begin => circle, end => rectangle)
    _shapeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.65, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.reverse();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final size = ref.watch(gridNotifierProvider.select((it) => it.gridSize));

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: _thineVerticalBorder(),
                borderRadius: BorderRadius.circular(_shapeAnimation.value * (size / 2)),
                color: _controller.value < 0.4
                    ? Color.lerp(ColorManager.transparent, startColor, _controller.value / 0.4)
                    : _colorAnimation.value,
              ),
            ),
          );
        },
      );
    });
  }
}
