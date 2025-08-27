import 'dart:math';

import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';

class MovablePinsBackground extends StatefulWidget {
  const MovablePinsBackground({this.pinColor = ThemeEnum.whiteD5Color, required this.child, super.key});
  final ThemeEnum pinColor;
  final Widget child;
  @override
  State<MovablePinsBackground> createState() => _MovablePinsBackgroundState();
}

class _MovablePinsBackgroundState extends State<MovablePinsBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  /// 🔧 Adjustable parameters
  double speedFactor = 0.3;
  double densityFactor = 0.45;
  final int maxPins = 150;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    )..addListener(_update);

    _controller.repeat();
  }

  void _createParticles(Size size) {
    if (_particles.isNotEmpty) return;

    final baseCount = (size.width * size.height / 2500).round();
    final count = (baseCount * densityFactor).round();

    for (int i = 0; i < count; i++) {
      _particles.add(Particle.random(_random, size, speedFactor));
    }
  }

  void _update() {
    final size = MediaQuery.of(context).size;

    setState(() {
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.randomWalk();
        p.update();

        // remove if outside screen
        if (!p.isInside(size)) {
          _particles.removeAt(i);
          _particles.add(Particle.random(_random, size, speedFactor));
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _createParticles(size);

    return GestureDetector(
      // set max pins limit

      onTapDown: (d) {
        setState(() {
          // add new pin
          _particles.add(Particle(
            d.localPosition,
            Offset((_random.nextDouble() * 2 - 1) * 0.5, (_random.nextDouble() * 2 - 1) * 0.5),
            _random,
            size,
            speedFactor,
          ));

          // if exceeded maxPins → remove the oldest one (index 0)
          if (_particles.length > maxPins) {
            _particles.removeAt(0);
          }
        });
      },
      onPanUpdate: (d) {
        setState(() {
          const influenceRadius = 100.0; // 👈 adjust how far the finger affects pins
          for (var p in _particles) {
            final distance = (p.position - d.localPosition).distance;
            if (distance < influenceRadius) {
              // push away
              final direction = (p.position - d.localPosition).normalize();
              p.velocity += direction * 0.5; // 👈 adjust strength
            }
          }
        });
      },

      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          CustomPaint(
            painter: ParticlePainter(_particles, context.getColor(widget.pinColor)),
            child: const SizedBox.expand(),
          ),
          widget.child
        ],
      ),
    );
  }
}

class Particle {
  Offset position;
  Offset velocity;
  final Size screenSize;
  final Random random;
  final double speedFactor;

  Particle(this.position, this.velocity, this.random, this.screenSize, this.speedFactor);

  factory Particle.random(Random random, Size screenSize, double speedFactor) {
    return Particle(
      Offset(
        random.nextDouble() * screenSize.width,
        random.nextDouble() * screenSize.height,
      ),
      Offset(
        (random.nextDouble() * 2 - 1) * 0.5,
        (random.nextDouble() * 2 - 1) * 0.5,
      ),
      random,
      screenSize,
      speedFactor,
    );
  }

  void randomWalk() {
    final dx = (random.nextDouble() * 0.2 - 0.1) * speedFactor;
    final dy = (random.nextDouble() * 0.2 - 0.1) * speedFactor;
    velocity += Offset(dx, dy);

    final maxSpeed = 1.5 * speedFactor;
    if (velocity.distance > maxSpeed) {
      velocity = (velocity / velocity.distance) * maxSpeed;
    }
  }

  void update() {
    position += velocity;
  }

  bool isInside(Size size) {
    return position.dx >= -20 &&
        position.dx <= size.width + 20 &&
        position.dy >= -20 &&
        position.dy <= size.height + 20;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color pinColor;

  ParticlePainter(this.particles, this.pinColor);

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()..color = pinColor;
    final linePaint = Paint()
      ..color = pinColor.withOpacity(0.2)
      ..strokeWidth = 0.5;

    const maxDistance = 150.0;

    for (var p in particles) {
      canvas.drawCircle(p.position, 3, circlePaint);

      for (var other in particles) {
        if (p == other) continue;
        final dist = (p.position - other.position).distance;
        if (dist < maxDistance) {
          linePaint.color = pinColor.withOpacity(1 - dist / maxDistance);
          canvas.drawLine(p.position, other.position, linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension OffsetX on Offset {
  Offset normalize() {
    final len = distance;
    if (len == 0) return Offset.zero;
    return this / len;
  }
}
