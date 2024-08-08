import 'package:flutter/material.dart';

class HeroWidget extends StatelessWidget {
  const HeroWidget({super.key, required this.tag, required this.child});
  final String tag;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    try {
      if (tag.isEmpty) return child;

      return Hero(tag: tag, child: child);
    } catch (e) {
      return child;
    }
  }
}
