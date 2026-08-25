import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A lightweight, GPU-friendly animated pin/particle background.
///
/// Perf changes vs. the previous implementation:
/// - No `setState` per frame. The simulation mutates typed-array particle
///   data directly and repaints only the [CustomPaint] layer through a
///   dedicated [Listenable], so the rest of the tree (including [child])
///   never rebuilds.
/// - The loop is throttled to [targetFps], independent of the device's
///   real display refresh rate (60/90/120Hz).
/// - Particle positions/velocities live in [Float32List]s instead of one
///   `Offset` object per particle per frame, removing most per-frame
///   allocations / GC churn.
/// - Connections between nearby pins use a spatial hash grid instead of
///   an all-pairs O(n²) scan (the old code also scanned all pairs twice
///   and drew every line twice). Lines and dots are drawn with a handful
///   of batched `drawRawPoints` calls instead of one canvas call per pin
///   / per pair.
/// - The particle count is now hard-capped by [maxPins] even before any
///   pins are tapped in (previously only the tap-to-add path was capped).
/// - The ticker pauses while the app is backgrounded.
class MovablePinsBackground extends StatefulWidget {
  const MovablePinsBackground({
    this.pinColor = ThemeEnum.whiteD5Color,
    required this.child,
    this.maxPins = 80,
    this.densityFactor = 0.35,
    this.speedFactor = 0.3,
    this.connectionDistance = 130,
    this.enableConnections = true,
    this.targetFps = 30,
    super.key,
  });

  final ThemeEnum pinColor;
  final Widget child;

  /// Hard cap on particle count, regardless of screen size.
  final int maxPins;

  /// Fraction of the size-based particle count that actually spawns.
  final double densityFactor;

  /// Base particle movement speed.
  final double speedFactor;

  /// Max distance (px) at which two pins get a connecting line. This is
  /// also the spatial-grid cell size used to find nearby pins.
  final double connectionDistance;

  /// Whether to draw connecting lines at all. This is the single most
  /// expensive part of the paint pass — turn it off first on low-end
  /// devices.
  final bool enableConnections;

  /// Simulation/paint updates per second. Lower = cheaper, less smooth.
  final int targetFps;

  @override
  State<MovablePinsBackground> createState() => _MovablePinsBackgroundState();
}

class _MovablePinsBackgroundState extends State<MovablePinsBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker=createTicker(_onTick);
  final _Repainter _repainter = _Repainter();
  final Random _random = Random();

  Float32List _posX = Float32List(0);
  Float32List _posY = Float32List(0);
  Float32List _velX = Float32List(0);
  Float32List _velY = Float32List(0);
  int _particleCount = 0;

  Size _size = Size.zero;
  bool _particlesReady = false;
  bool _appInForeground = true;

  Duration _lastElapsed = Duration.zero;
  Duration _accumulated = Duration.zero;
  late final Duration _frameInterval;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _frameInterval = Duration(microseconds: (1000000 / widget.targetFps).round());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newSize = MediaQuery.sizeOf(context);
    if (newSize != _size) {
      _size = newSize;
      if (!_particlesReady && !_size.isEmpty) {
        _createParticles(_size);
        _particlesReady = true;
        if (!_ticker.isTicking) _ticker.start();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appInForeground = state == AppLifecycleState.resumed;
    if (!_particlesReady) return;
    if (_appInForeground && !_ticker.isTicking) {
      _lastElapsed = Duration.zero;
      _accumulated = Duration.zero;
      _ticker.start();
    } else if (!_appInForeground && _ticker.isTicking) {
      _ticker.stop();
    }
  }

  void _createParticles(Size size) {
    final baseCount = (size.width * size.height / 2500).round();
    final count = min((baseCount * widget.densityFactor).round(), widget.maxPins);

    _posX = Float32List(widget.maxPins);
    _posY = Float32List(widget.maxPins);
    _velX = Float32List(widget.maxPins);
    _velY = Float32List(widget.maxPins);

    for (int i = 0; i < count; i++) {
      _spawn(i, size);
    }
    _particleCount = count;
  }

  void _spawn(int i, Size size) {
    _posX[i] = _random.nextDouble() * size.width;
    _posY[i] = _random.nextDouble() * size.height;
    _velX[i] = (_random.nextDouble() * 2 - 1) * 0.5;
    _velY[i] = (_random.nextDouble() * 2 - 1) * 0.5;
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    if (!_appInForeground) return;

    _accumulated += delta;
    if (_accumulated < _frameInterval) return;
    _accumulated = Duration.zero;

    final maxSpeed = 1.5 * widget.speedFactor;
    final w = _size.width;
    final h = _size.height;

    for (int i = 0; i < _particleCount; i++) {
      double vx = _velX[i] + (_random.nextDouble() * 0.2 - 0.1) * widget.speedFactor;
      double vy = _velY[i] + (_random.nextDouble() * 0.2 - 0.1) * widget.speedFactor;

      final speed = sqrt(vx * vx + vy * vy);
      if (speed > maxSpeed) {
        vx = vx / speed * maxSpeed;
        vy = vy / speed * maxSpeed;
      }

      final px = _posX[i] + vx;
      final py = _posY[i] + vy;

      if (px < -20 || px > w + 20 || py < -20 || py > h + 20) {
        _spawn(i, _size);
      } else {
        _posX[i] = px;
        _posY[i] = py;
        _velX[i] = vx;
        _velY[i] = vy;
      }
    }

    _repainter.tick();
  }

  void _addPinAt(Offset position) {
    if (!_particlesReady) return;
    int i;
    if (_particleCount < widget.maxPins) {
      i = _particleCount++;
    } else {
      // Drop the oldest pin, shift the rest down (rare: only on tap).
      for (int k = 1; k < widget.maxPins; k++) {
        _posX[k - 1] = _posX[k];
        _posY[k - 1] = _posY[k];
        _velX[k - 1] = _velX[k];
        _velY[k - 1] = _velY[k];
      }
      i = widget.maxPins - 1;
    }
    _posX[i] = position.dx;
    _posY[i] = position.dy;
    _velX[i] = (_random.nextDouble() * 2 - 1) * 0.5;
    _velY[i] = (_random.nextDouble() * 2 - 1) * 0.5;
    _repainter.tick();
  }

  void _applyDragInfluence(Offset dragPosition) {
    if (!_particlesReady) return;
    const influenceRadius = 100.0;
    const influenceRadiusSq = influenceRadius * influenceRadius;

    for (int i = 0; i < _particleCount; i++) {
      final dx = _posX[i] - dragPosition.dx;
      final dy = _posY[i] - dragPosition.dy;
      final distSq = dx * dx + dy * dy;
      if (distSq < influenceRadiusSq && distSq > 0) {
        final dist = sqrt(distSq);
        _velX[i] += dx / dist * 0.5;
        _velY[i] += dy / dist * 0.5;
      }
    }
    _repainter.tick();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _repainter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.getColor(widget.pinColor);
    return GestureDetector(
      onTapDown: (d) => _addPinAt(d.localPosition),
      onPanUpdate: (d) => _applyDragInfluence(d.localPosition),
      child: Stack(
        fit: StackFit.expand,
        alignment: AlignmentDirectional.center,
        children: [
          AnimatedBackground(),
          RepaintBoundary(
            child: CustomPaint(
              painter: _ParticlePainter(
                repaint: _repainter,
                posX: _posX,
                posY: _posY,
                getCount: () => _particleCount,
                color: color,
                connectionDistance: widget.connectionDistance,
                enableConnections: widget.enableConnections,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

/// Minimal `Listenable` used purely to trigger a repaint of the
/// [_ParticlePainter] without touching the widget tree.
class _Repainter extends ChangeNotifier {
  void tick() => notifyListeners();
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required Listenable repaint,
    required this.posX,
    required this.posY,
    required this.getCount,
    required this.color,
    required this.connectionDistance,
    required this.enableConnections,
  }) : super(repaint: repaint);

  final Float32List posX;
  final Float32List posY;
  final int Function() getCount;
  final Color color;
  final double connectionDistance;
  final bool enableConnections;

  @override
  void paint(Canvas canvas, Size size) {
    final count = getCount();
    if (count == 0) return;

    if (enableConnections && count > 1) {
      _drawConnections(canvas, size, count);
    }

    // Batch every pin into a single draw call instead of one
    // canvas.drawCircle per pin.
    final dots = Float32List(count * 2);
    for (int i = 0; i < count; i++) {
      dots[i * 2] = posX[i];
      dots[i * 2 + 1] = posY[i];
    }
    final dotPaint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawRawPoints(ui.PointMode.points, dots, dotPaint);
  }

  void _drawConnections(Canvas canvas, Size size, int count) {
    final cellSize = connectionDistance;
    final cols = max(1, (size.width / cellSize).ceil());
    final rows = max(1, (size.height / cellSize).ceil());
    final grid = List.generate(cols * rows, (_) => <int>[], growable: false);

    int cellIndexOf(double x, double y) {
      final c = max(0, min(cols - 1, (x / cellSize).floor()));
      final r = max(0, min(rows - 1, (y / cellSize).floor()));
      return r * cols + c;
    }

    for (int i = 0; i < count; i++) {
      grid[cellIndexOf(posX[i], posY[i])].add(i);
    }

    // Bucket segments by distance so the fade effect survives batching:
    // each bucket gets one drawRawPoints(lines) call with one alpha.
    const bucketCount = 6;
    final buckets = List.generate(bucketCount, (_) => <double>[], growable: false);
    final maxDistSq = connectionDistance * connectionDistance;

    void considerPair(int i, int j) {
      final dx = posX[i] - posX[j];
      final dy = posY[i] - posY[j];
      final distSq = dx * dx + dy * dy;
      if (distSq >= maxDistSq) return;
      final dist = sqrt(distSq);
      final t = 1 - dist / connectionDistance; // guaranteed in (0, 1]
      final bucketIndex = max(0, min(bucketCount - 1, (t * (bucketCount - 1)).round()));
      buckets[bucketIndex]
        ..add(posX[i])
        ..add(posY[i])
        ..add(posX[j])
        ..add(posY[j]);
    }

    // Pairs within the same cell (index-guarded so each pair is found once).
    for (final cellParticles in grid) {
      for (int a = 0; a < cellParticles.length; a++) {
        for (int b = a + 1; b < cellParticles.length; b++) {
          considerPair(cellParticles[a], cellParticles[b]);
        }
      }
    }

    // Pairs across neighboring cells. Only checking this "forward" half of
    // the 8 neighbor directions guarantees every cross-cell pair is found
    // exactly once (no duplicate lines, unlike the original code).
    const dirs = [
      [1, 0],
      [0, 1],
      [1, 1],
      [1, -1],
    ];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cellParticles = grid[r * cols + c];
        if (cellParticles.isEmpty) continue;
        for (final dir in dirs) {
          final nc = c + dir[0];
          final nr = r + dir[1];
          if (nc < 0 || nc >= cols || nr < 0 || nr >= rows) continue;
          final neighborParticles = grid[nr * cols + nc];
          if (neighborParticles.isEmpty) continue;
          for (final i in cellParticles) {
            for (final j in neighborParticles) {
              considerPair(i, j);
            }
          }
        }
      }
    }

    for (int b = 0; b < bucketCount; b++) {
      final points = buckets[b];
      if (points.isEmpty) continue;
      final alpha = (b + 1) / bucketCount * 0.7;
      final linePaint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..strokeWidth = 0.5;
      canvas.drawRawPoints(
        ui.PointMode.lines,
        Float32List.fromList(points),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.enableConnections != enableConnections ||
        oldDelegate.connectionDistance != connectionDistance;
  }
}

/*

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MovablePinsBackground extends StatefulWidget {
  const MovablePinsBackground({
    this.pinColor = ThemeEnum.whiteD5Color,
    required this.child,
    super.key,
  });

  final ThemeEnum pinColor;
  final Widget child;

  @override
  State<MovablePinsBackground> createState() => _MovablePinsBackgroundState();
}

class _MovablePinsBackgroundState extends State<MovablePinsBackground> {
  @override
  Widget build(BuildContext context) {
    final color = context.getColor(widget.pinColor);
    return Stack(
      fit: StackFit.expand,
      alignment: AlignmentDirectional.center,
      children: [
        AnimatedBackground(),
        RepaintBoundary(child: CustomPaint(size: Size.infinite, painter: _ParticlePainter(pinColor: color))),
        // widget.child,
      ],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final Color pinColor;

  _ParticlePainter({required this.pinColor});

  @override
  void paint(Canvas canvas, Size size) {
    final int maxPin = 50;

    final points = List.generate(
      maxPin,
          (_) {
        final randomizedWidth = Random().nextDouble() * size.width;
        final randomizedHeight = Random().nextDouble() * size.height;

        return Offset(randomizedWidth, randomizedHeight);
      },
    );

    final sortedPoints = <Offset>[];

    if (points.isNotEmpty) {
      final remaining = [...points];

      var current = remaining.removeAt(0);
      sortedPoints.add(current);

      while (remaining.isNotEmpty) {
        var nearestIndex = 0;
        var nearestDistance = double.infinity;

        for (var i = 0; i < remaining.length; i++) {
          final distance = (remaining[i] - current).distanceSquared;

          if (distance < nearestDistance) {
            nearestDistance = distance;
            nearestIndex = i;
          }
        }

        current = remaining.removeAt(nearestIndex);
        sortedPoints.add(current);
      }
    }

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final path = Path();
      final paint = Paint()
        ..color = pinColor
        ..style = PaintingStyle.fill;

      path.addOval(Rect.fromCircle(center: point, radius: 2.5));

      canvas.drawPath(path, paint);

      canvas.save();

      int start = i;
      while (start<i+3 && start<points.length) {
        path.moveTo(points[i].dx, points[i].dy);

        path.lineTo(points[start].dx, points[start].dy);
        final paint = Paint()
          ..color = pinColor.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, paint);

        start++;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


* */