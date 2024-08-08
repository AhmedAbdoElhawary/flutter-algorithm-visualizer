part of 'adaptive_padding.dart';

class EndPadding extends StatelessWidget {
  const EndPadding({required this.padding, required this.child, super.key});
  final double padding;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return _RPadding(
        padding: REdgeInsetsDirectional.only(end: padding), child: child);
  }
}
