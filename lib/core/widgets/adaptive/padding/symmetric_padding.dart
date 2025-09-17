part of '../../../../core/widgets/adaptive/padding/adaptive_padding.dart';

class SymmetricPadding extends StatelessWidget {
  const SymmetricPadding({
    this.horizontal = 0,
    this.vertical = 0,
    required this.child,
    super.key,
  });
  final double horizontal;
  final double vertical;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return _RPadding(padding: REdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: child);
  }
}
