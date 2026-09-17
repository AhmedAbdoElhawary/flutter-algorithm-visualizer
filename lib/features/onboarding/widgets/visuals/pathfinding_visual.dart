import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_card.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_text.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/search_role.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/pf_legend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Screen 2 · Explore it — a ghost finger draws a wall, then a breadth-first
/// search floods the grid and draws the route back.
///
/// The grid is 12 x 9 with cells sized from the available width (an
/// [AspectRatio], never a fixed pitch), so it holds its shape down to 360 px.
class PathfindingVisual extends StatefulWidget {
  const PathfindingVisual({required this.isActive, super.key});

  final bool isActive;

  @override
  State<PathfindingVisual> createState() => _PathfindingVisualState();
}

class _PathfindingVisualState extends State<PathfindingVisual> with SingleTickerProviderStateMixin {
  static const int _columns = 12;
  static const int _rows = 9;

  static const _start = (x: 2, y: 6);
  static const _end = (x: 11, y: 3);

  /// The vertical barrier that is already on the board.
  static const List<({int x, int y})> _fixedWalls = [
    (x: 7, y: 0),
    (x: 7, y: 1),
    (x: 7, y: 2),
    (x: 7, y: 3),
  ];

  /// The four cells the ghost finger drags across, in drag order.
  static const List<({int x, int y})> _drawnWalls = [
    (x: 7, y: 4),
    (x: 6, y: 4),
    (x: 5, y: 4),
    (x: 4, y: 4),
  ];

  // Timings, straight from the spec.
  static const int _wallStepMs = 90;
  static const int _ringMs = 60;
  static const int _pathCellMs = 40;
  static const int _pulseMs = 400;
  static const int _holdMs = 600;
  static const int _visitedFadeMs = 200;

  late final List<int> _distance;
  late final List<int> _parent;
  late final List<({int x, int y})> _path;
  late final int _endRing;
  late final List<int> _ringSizes;

  late final AnimationController _controller;

  late final int _wallPhaseMs = _drawnWalls.length * _wallStepMs;
  late final int _searchPhaseMs = (_endRing + 1) * _ringMs;
  late final int _pathPhaseMs = _path.length * _pathCellMs;

  int _index(int x, int y) => y * _columns + x;

  @override
  void initState() {
    super.initState();
    _runSearch();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: _wallPhaseMs + _searchPhaseMs + _pathPhaseMs + _pulseMs + _holdMs,
      ),
    );
  }

  /// Plain BFS over the finished board — every wall is already in place, since
  /// the drag is only a replay of walls the search then has to route around.
  void _runSearch() {
    final walls = <int>{
      for (final wall in _fixedWalls) _index(wall.x, wall.y),
      for (final wall in _drawnWalls) _index(wall.x, wall.y),
    };

    _distance = List<int>.filled(_columns * _rows, -1);
    _parent = List<int>.filled(_columns * _rows, -1);

    final queue = <int>[_index(_start.x, _start.y)];
    _distance[queue.first] = 0;

    for (var head = 0; head < queue.length; head++) {
      final cell = queue[head];
      final x = cell % _columns;
      final y = cell ~/ _columns;
      for (final step in const [(dx: 1, dy: 0), (dx: -1, dy: 0), (dx: 0, dy: 1), (dx: 0, dy: -1)]) {
        final nx = x + step.dx;
        final ny = y + step.dy;
        if (nx < 0 || ny < 0 || nx >= _columns || ny >= _rows) continue;
        final next = _index(nx, ny);
        if (walls.contains(next) || _distance[next] != -1) continue;
        _distance[next] = _distance[cell] + 1;
        _parent[next] = cell;
        queue.add(next);
      }
    }

    _endRing = _distance[_index(_end.x, _end.y)];

    // Route back from the end marker, skipping the end and start cells — the
    // marker and the origin carry their own styling. Reversed so the reveal
    // in `_frameAt` draws start -> end, not end -> start.
    final path = <({int x, int y})>[];
    var cursor = _parent[_index(_end.x, _end.y)];
    while (cursor != -1 && cursor != _index(_start.x, _start.y)) {
      path.add((x: cursor % _columns, y: cursor ~/ _columns));
      cursor = _parent[cursor];
    }
    _path = path.reversed.toList();

    _ringSizes = List<int>.filled(_endRing + 1, 0);
    for (final distance in _distance) {
      if (distance >= 0 && distance <= _endRing) _ringSizes[distance]++;
    }
  }

  @override
  void didUpdateWidget(PathfindingVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  void _sync() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
      return;
    }
    if (widget.isActive) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const linesColor = ThemeEnum.hairline;
    final wallColor = searchRoleColor(SearchRole.wall);
    final frontierColor = searchRoleColor(SearchRole.frontier);
    final visitedColor = searchRoleColor(SearchRole.visited);
    final pathColor = searchRoleColor(SearchRole.path);
    final markerColor = searchRoleColor(SearchRole.end);
    final starterColor = searchRoleColor(SearchRole.start);

    final lines = context.getColor(linesColor);
    final wall = context.getColor(wallColor);
    final frontier = context.getColor(frontierColor);
    final visited = context.getColor(visitedColor);
    final path = context.getColor(pathColor);
    final marker = context.getColor(markerColor);
    final starter = context.getColor(starterColor);

    return OnboardingCard(
      child: AllPadding(
        padding: 18,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final elapsed = _controller.value * _controller.duration!.inMilliseconds;
            final frame = _frameAt(elapsed, frontier: frontier, visited: visited, path: path);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: _columns / _rows,
                  child: CustomPaint(
                    painter: _GridPainter(
                      columns: _columns,
                      rows: _rows,
                      lineColor: lines,
                      wallColor: wall,
                      markerColor: marker,
                      starterColor: starter,
                      cells: frame.cells,
                      walls: frame.walls,
                      start: _start,
                      end: _end,
                      pulse: frame.pulse,
                      finger: frame.finger,
                    ),
                  ),
                ),
                const RSizedBox(height: 16),
                const PFLegend(horizontalPadding: 0,spacing: 6),
                const RSizedBox(height: 16),
                OnboardingCaptionBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Flexible so a wide font or a long count ellipsizes
                      // instead of pushing the row past the card.
                      Flexible(
                        child: MonoText(
                          StringsManager.onboardingQueueCaption(context, frame.waiting),
                          color: ThemeEnum.inkTitle,
                        ),
                      ),
                      Flexible(
                        child: MonoText(StringsManager.onboardingStepCaption(context, frame.step)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Resolves the whole grid for one moment in the loop.
  _Frame _frameAt(
    double elapsed, {
    required Color frontier,
    required Color visited,
    required Color path,
  }) {
    final cells = List<Color?>.filled(_columns * _rows, null);

    // Phase 1 — the drag.
    final drawnCount = (elapsed / _wallStepMs).floor().clamp(0, _drawnWalls.length);
    final walls = <int>{
      for (final wall in _fixedWalls) _index(wall.x, wall.y),
      for (var i = 0; i < drawnCount; i++) _index(_drawnWalls[i].x, _drawnWalls[i].y),
    };

    ({double x, double y})? finger;
    if (elapsed < _wallPhaseMs) {
      // Slide the finger continuously between the cells it is drawing.
      final t = (elapsed / _wallStepMs).clamp(0.0, _drawnWalls.length - 1.0);
      final from = _drawnWalls[t.floor()];
      final to = _drawnWalls[t.ceil().clamp(0, _drawnWalls.length - 1)];
      final f = t - t.floor();
      finger = (x: from.x + (to.x - from.x) * f, y: from.y + (to.y - from.y) * f);
    }

    // Phase 2 — the flood.
    final searchMs = (elapsed - _wallPhaseMs).clamp(0.0, _searchPhaseMs.toDouble());
    final currentRing = (searchMs / _ringMs).floor().clamp(0, _endRing);
    var step = 0;
    if (elapsed >= _wallPhaseMs) {
      for (var cell = 0; cell < cells.length; cell++) {
        final distance = _distance[cell];
        if (distance < 0 || distance > currentRing) continue;
        step++;
        if (distance == currentRing) {
          cells[cell] = frontier;
          continue;
        }
        // White leads, blue fills in behind it over 200 ms, then settles
        // deeper as the wave moves on.
        final ageMs = (currentRing - distance) * _ringMs;
        final fade = (ageMs / _visitedFadeMs).clamp(0.0, 1.0);
        final alpha = 0.85 - 0.35 * ((ageMs / 800).clamp(0.0, 1.0));
        cells[cell] = Color.lerp(frontier, visited.withValues(alpha: alpha), fade);
      }
    }

    // Phase 3 — the route home.
    final pathMs = elapsed - _wallPhaseMs - _searchPhaseMs;
    if (pathMs > 0) {
      final revealed = (pathMs / _pathCellMs).floor().clamp(0, _path.length);
      for (var i = 0; i < revealed; i++) {
        cells[_index(_path[i].x, _path[i].y)] = path;
      }
    }

    // Phase 4 — one pulse on the end marker, and nothing after it.
    final pulseMs = elapsed - _wallPhaseMs - _searchPhaseMs - _pathPhaseMs;
    final pulse = pulseMs <= 0 || pulseMs > _pulseMs ? 0.0 : 1 - (pulseMs / _pulseMs);

    return _Frame(
      cells: cells,
      walls: walls,
      finger: finger,
      pulse: pulse,
      step: step,
      waiting: elapsed < _wallPhaseMs ? 0 : _ringSizes[currentRing],
    );
  }
}

class _Frame {
  const _Frame({
    required this.cells,
    required this.walls,
    required this.finger,
    required this.pulse,
    required this.step,
    required this.waiting,
  });

  final List<Color?> cells;
  final Set<int> walls;
  final ({double x, double y})? finger;
  final double pulse;
  final int step;
  final int waiting;
}

class _GridPainter extends CustomPainter {
  const _GridPainter({
    required this.columns,
    required this.rows,
    required this.lineColor,
    required this.wallColor,
    required this.markerColor,
    required this.starterColor,
    required this.cells,
    required this.walls,
    required this.start,
    required this.end,
    required this.pulse,
    required this.finger,
  });

  final int columns;
  final int rows;
  final Color lineColor;
  final Color wallColor;
  final Color markerColor;
  final Color starterColor;
  final List<Color?> cells;
  final Set<int> walls;
  final ({int x, int y}) start;
  final ({int x, int y}) end;
  final double pulse;
  final ({double x, double y})? finger;

  @override
  void paint(Canvas canvas, Size size) {
    // Cell size is derived from the box we were given — never a fixed pitch.
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    Rect rectFor(double x, double y) => Rect.fromLTWH(x * cellWidth, y * cellHeight, cellWidth, cellHeight);

    for (var i = 0; i < cells.length; i++) {
      final color = walls.contains(i) ? wallColor : cells[i];
      if (color == null) continue;
      canvas.drawRect(
        rectFor((i % columns).toDouble(), (i ~/ columns).toDouble()),
        Paint()..color = color,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (var column = 1; column < columns; column++) {
      final x = column * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (var row = 1; row < rows; row++) {
      final y = row * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final startCenter = rectFor(start.x.toDouble(), start.y.toDouble()).center;
    canvas.drawCircle(
      startCenter,
      cellWidth * 0.26,
      Paint()..color = starterColor,
    );

    final endCenter = rectFor(end.x.toDouble(), end.y.toDouble()).center;
    final ringRadius = cellWidth * 0.26;
    canvas.drawCircle(
      endCenter,
      ringRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = markerColor,
    );
    if (pulse > 0) {
      canvas.drawCircle(
        endCenter,
        ringRadius + cellWidth * 0.5 * (1 - pulse),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = markerColor.withValues(alpha: pulse),
      );
    }

    final fingerPosition = finger;
    if (fingerPosition != null) {
      final center = rectFor(fingerPosition.x, fingerPosition.y).center;
      canvas.drawCircle(
        center,
        cellWidth * 0.55,
        Paint()..color = wallColor.withValues(alpha: 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => true;
}
