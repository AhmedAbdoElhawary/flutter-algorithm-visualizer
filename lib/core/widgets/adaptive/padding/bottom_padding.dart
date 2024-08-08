part of 'adaptive_padding.dart';


class BottomPadding extends StatelessWidget {
  const BottomPadding({required this.padding, required this.child, super.key});
  final double padding;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return _RPadding(
        padding: REdgeInsetsDirectional.only(bottom: padding), child: child);
  }
}
