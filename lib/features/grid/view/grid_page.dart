import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/grid/view_model/grid_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gridNotifierProvider =
    StateNotifierProvider<GridNotifierCubit, GridNotifierState>(
  (ref) => GridNotifierCubit(),
);

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
            return _BuildLayout(constraints);
          },
        ),
      ),
    );
  }
}

class _BuildLayout extends ConsumerStatefulWidget {
  const _BuildLayout(this.constraints);
  final BoxConstraints constraints;

  @override
  ConsumerState<_BuildLayout> createState() => _BuildLayoutState();
}

class _BuildLayoutState extends ConsumerState<_BuildLayout> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _updateLayout());
  }

  @override
  void didUpdateWidget(covariant _BuildLayout oldWidget) {
    if (oldWidget.constraints != widget.constraints) {
      Future.microtask(() => _updateLayout());
    }
    super.didUpdateWidget(oldWidget);
  }

  void _updateLayout() {
    ref
        .read(gridNotifierProvider.notifier)
        .updateGridLayout(widget.constraints);
  }

  @override
  Widget build(BuildContext context) {
    return const _BuildGridItems();
  }
}

class _BuildGridItems extends ConsumerWidget {
  const _BuildGridItems();

  @override
  Widget build(BuildContext context, ref) {
    final gridCount = ref.watchGridCount;
    final watchColumnCrossAxisCount = ref.watchColumnCrossAxisCount;

    if (gridCount == 0) {
      return const Center(
          child: MediumText(StringsManager.notInitializeGridYet));
    }
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
          crossAxisCount: watchColumnCrossAxisCount,
          childAspectRatio: 1.0, // Ensures squares
        ),
        itemBuilder: (context, index) {
          return const _Square();
        },
        itemCount: gridCount,
      ),
    );
  }
}

class _Square extends StatefulWidget {
  const _Square();

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
          child: Consumer(builder: (context, ref, _) {
            return Container(
              width: ref.watchGridSize,
              height: ref.watchGridSize,
              color: isBlack ? Colors.black : Colors.transparent,
            );
          }),
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
