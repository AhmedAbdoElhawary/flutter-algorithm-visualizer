// import 'dart:math';
//
// import 'package:flutter/material.dart';
//
// class FloatingAnimatedButton extends StatefulWidget {
//   final Widget child;
//   final Duration stepDuration;
//
//   const FloatingAnimatedButton({
//     super.key,
//     required this.child,
//     this.stepDuration = const Duration(seconds: 3),
//   });
//
//   @override
//   State<FloatingAnimatedButton> createState() => _FloatingAnimatedButtonState();
// }
//
// class _FloatingAnimatedButtonState extends State<FloatingAnimatedButton> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scale;
//   late Animation<Offset> _offset;
//
//   final Random _random = Random();
//   double _currentScale = 1.0;
//   Offset _currentOffset = Offset.zero;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(vsync: this);
//
//     _setNewRandomAnimation();
//
//     // when one random animation finishes → schedule the next one
//     _controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _currentScale = _scale.value;
//         _currentOffset = _offset.value;
//         _setNewRandomAnimation();
//       }
//     });
//   }
//
//   void _setNewRandomAnimation() {
//     // generate new random target scale and offset
//     final newScale = 0.95 + _random.nextDouble() * 0.1;
//     final newOffset = Offset(
//       (_random.nextDouble() * 40 - 35) / 100,
//       (_random.nextDouble() * 40 - 35) / 100,
//     );
//
//     _scale = Tween<double>(
//       begin: _currentScale,
//       end: newScale,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//
//     _offset = Tween<Offset>(
//       begin: _currentOffset,
//       end: newOffset,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//
//     _controller.duration = widget.stepDuration + Duration(milliseconds: _random.nextInt(2000));
//
//     _controller.reset();
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (_, __) {
//         return Transform.translate(
//           offset: _offset.value * 25,
//           child: Transform.scale(
//             scale: _scale.value,
//             child: widget.child,
//           ),
//         );
//       },
//     );
//   }
// }
