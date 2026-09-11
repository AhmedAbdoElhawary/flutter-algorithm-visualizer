import 'package:flutter/material.dart';

class PFStartPointWidget extends StatelessWidget {
  const PFStartPointWidget({required this.size, required this.color, super.key});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final iconStr = String.fromCharCode(Icons.arrow_forward_ios_rounded.codePoint);
    return Center(
      child: Text(
        iconStr,
        style: TextStyle(
          fontSize: size * 1,
          fontFamily: Icons.arrow_forward_ios_rounded.fontFamily,
          package: Icons.arrow_forward_ios_rounded.fontPackage,
          color: color,
        ),
      ),
    );
  }
}
