import 'package:flutter/material.dart';

class PFStartPointWidget extends StatelessWidget {
  const PFStartPointWidget({required this.size, required this.color, super.key});

  /// Already-resolved pixels — the grid passes its cell size, so the marker
  /// fills exactly one cell and needs no further scaling.
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.arrow_forward_ios_rounded, size: size, color: color),
    );
  }
}
