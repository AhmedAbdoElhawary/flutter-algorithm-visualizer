import 'package:algorithm_visualizer/features/visualize/sub_view/searching/widgets/pf_grid.dart';
import 'package:flutter/material.dart';

class PFEndPointWidget extends StatelessWidget {
  const PFEndPointWidget({required this.size, super.key});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TargetPainter(
        outerColor: kTargetOuterColor,
        midColor: kTargetMidColor,
        innerColor: kTargetInnerColor,
      ),
    );
  }
}

class _TargetPainter extends CustomPainter {
  final Color outerColor;
  final Color midColor;
  final Color innerColor;

  _TargetPainter({required this.outerColor, required this.midColor, required this.innerColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2.3;
    final midRadius = maxRadius * (20.0 / 30.0);
    final minRadius = maxRadius * (12.0 / 30.0);

    canvas.drawCircle(center, maxRadius, Paint()..color = outerColor);
    canvas.drawCircle(center, midRadius, Paint()..color = midColor);
    canvas.drawCircle(center, minRadius, Paint()..color = innerColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
