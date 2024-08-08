part of '../../../../core/widgets/adaptive/padding/adaptive_padding.dart';

class OnlyPadding extends StatelessWidget {
  const OnlyPadding({
    this.startPadding = 0,
    this.endPadding = 0,
    this.topPadding = 0,
    this.bottomPadding = 0,
    required this.child,
    super.key,
  });
  final double startPadding;
  final double endPadding;
  final double topPadding;
  final double bottomPadding;
  final Widget child;
  @override
  Widget build(BuildContext context) {

    return _RPadding(
      padding: REdgeInsetsDirectional.only(
        start: startPadding,
        end: endPadding,
        top: topPadding,
        bottom: bottomPadding,
      ),
      child: child,
    );
  }
}
