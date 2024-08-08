part of 'adaptive_padding.dart';

class AllPadding extends StatelessWidget {
  const AllPadding({required this.padding, required this.child, super.key});
  final double padding;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return _RPadding(
        padding: REdgeInsetsDirectional.all(padding), child: child);
  }
}
