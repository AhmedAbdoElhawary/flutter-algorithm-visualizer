part of '../../../../core/widgets/adaptive/padding/adaptive_padding.dart';

class HorizontalPadding extends StatelessWidget {
  const HorizontalPadding(
      {required this.padding, required this.child, super.key});
  final double padding;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return _RPadding(
        padding: REdgeInsets.symmetric(horizontal: padding), child: child);
  }
}
