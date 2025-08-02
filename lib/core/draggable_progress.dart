import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';

class DraggableProgressBar extends StatefulWidget {
  const DraggableProgressBar({required this.onChanged, super.key});
  final void Function(double persent) onChanged;
  @override
  LinearSliderState createState() => LinearSliderState();
}

class LinearSliderState extends State<DraggableProgressBar> {
  double sliderValue = 0.3;

  @override
  Widget build(BuildContext context) {
    return Slider(
      activeColor: context.getColor(ThemeEnum.blueColor),
      value: sliderValue,
      onChanged: (v) {
        setState(() {
          sliderValue = v;
        });
        widget.onChanged(v);
      },
    );
  }
}
