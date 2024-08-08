part of'../../../../core/widgets/adaptive/padding/adaptive_padding.dart';
class StartPadding extends StatelessWidget {
  const StartPadding(
      {required this.padding, required this.child, super.key});
  final double padding;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return _RPadding(
        padding: REdgeInsetsDirectional.only(start: padding), child: child);
  }
}
