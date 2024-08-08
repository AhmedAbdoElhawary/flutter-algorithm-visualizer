part of'../../../../core/widgets/adaptive/padding/adaptive_padding.dart';
class TopPadding extends StatelessWidget {
  const TopPadding(
      {required this.padding, required this.child, super.key});
  final double padding;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return _RPadding(
        padding: REdgeInsetsDirectional.only(top: padding), child: child);
  }
}
