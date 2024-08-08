import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appSettingsProvider = Provider<List<int>>((ref) => []);

class GridPage extends StatelessWidget {
  const GridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid Page'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            const int numSquares = 20;

            // it's square, so the height is the same of width. Size(value,value) => value
            final double gridSize =
                (constraints.maxWidth < constraints.maxHeight)
                    ? constraints.maxWidth / numSquares
                    : constraints.maxHeight / numSquares;

            final columnCrossAxisCount =
                (constraints.maxWidth / gridSize).floor();
            final rowMainAxisCount = (constraints.maxHeight / gridSize).floor();

            final count = columnCrossAxisCount * rowMainAxisCount;

            return _BuildGridItems(
              crossAxisCount: columnCrossAxisCount,
              gridSize: gridSize,
              count: count,
            );
          },
        ),
      ),
    );
  }
}

class _BuildGridItems extends ConsumerWidget {
  const _BuildGridItems({
    required this.crossAxisCount,
    required this.gridSize,
    required this.count,
  });

  final int crossAxisCount;
  final double gridSize;
  final int count;

  @override
  Widget build(BuildContext context, ref) {
    // ref.read(appSettingsProvider)..clear()..addAll(iterable);
    return Listener(
      onPointerDown: (event) {
        // _toggleColor(!isBlack);
      },
      onPointerMove: (event) {
        // print(
        //     "LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL ${event.localPosition},,,,$gridSize,,, ${crossAxisCount},,$mainAxisCount,,$count");
        // _toggleColor(!isBlack);
      },
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.0, // Ensures squares
        ),
        itemBuilder: (context, index) {
          return _Square(size: gridSize);
        },
        itemCount: count,
      ),
    );
  }
}

class _Square extends StatefulWidget {
  final double size;

  const _Square({required this.size});

  @override
  _SquareState createState() => _SquareState();
}

class _SquareState extends State<_Square> {
  bool isBlack = false;

  void _toggleColor(bool value) {
    setState(() {
      isBlack = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _toggleColor(!isBlack);
      },
      // onPointerMove: (event) {
      //   _toggleColor(!isBlack);
      // },
      child: Container(
        decoration: BoxDecoration(
          border: isBlack
              ? null
              : Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
        ),
        child: AnimatedScale(
          scale: isBlack ? 1.0 : 0.1,
          duration: const Duration(milliseconds: 700),
          curve: Curves.elasticOut,
          child: Container(
            width: widget.size,
            height: widget.size,
            color: isBlack ? Colors.black : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

// class _GridPage extends StatelessWidget {
//   const _GridPage();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Grid Page'),
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (BuildContext context, BoxConstraints constraints) {
//             const int numSquares = 25;
//
//             // Calculate grid size based on the smaller dimension
//             final gridSize = Size(constraints.maxWidth / numSquares,
//                 constraints.maxHeight / numSquares*0.5);
//
//             return CustomPaint(
//               size: Size.infinite, // Takes up all available space
//               painter: GridPainter(
//                 gridSize: gridSize, // Use the calculated grid size
//                 gridColor:
//                 Colors.grey.withOpacity(0.3), // Adjust grid color and opacity
//               ),
//               child: Container(),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class GridPainter extends CustomPainter {
//   final Size gridSize;
//   final Color gridColor;
//
//   GridPainter({required this.gridSize, this.gridColor = Colors.grey});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = gridColor
//       ..strokeWidth = 1;
//     final squarePanting=  Paint()..color=Colors.purple.withOpacity(0.6);
//     // Draw vertical lines
//     for (double x = 0; x <= size.width; x += gridSize.width) {
//       canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
//     }
//
//     // Draw horizontal lines
//     for (double y = 0; y <= size.height; y += gridSize.height) {
//       canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
//     }    canvas.drawPaint(squarePanting);
//
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
