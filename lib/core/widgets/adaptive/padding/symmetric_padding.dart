part of '../../../../core/widgets/adaptive/padding/adaptive_padding.dart';

class SymmetricPadding extends StatelessWidget {
  const SymmetricPadding({
    required this.horizontal,
    required this.vertical,
    required this.child,
    super.key,
  });
  final double horizontal;
  final double vertical;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return _RPadding(
        padding:
            REdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        child: child);
  }
}
