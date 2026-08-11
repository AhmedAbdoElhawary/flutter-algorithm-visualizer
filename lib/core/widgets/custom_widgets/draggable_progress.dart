import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';

class DraggableProgressBar extends StatefulWidget {
  const DraggableProgressBar({
    this.runOnChangedInitially = false,
    required this.onChanged,
    this.sliderValue = 0.3,
    this.isActive = true,
    super.key,
  });
  final void Function(double persent) onChanged;
  final bool runOnChangedInitially;
  final double sliderValue;
  final bool isActive;
  @override
  LinearSliderState createState() => LinearSliderState();
}

class LinearSliderState extends State<DraggableProgressBar> {
  late double sliderValue = widget.sliderValue;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.runOnChangedInitially) widget.onChanged(sliderValue);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      activeColor:
          widget.isActive ? context.getColor(ThemeEnum.mediumBlueColor) : context.getColor(ThemeEnum.whiteD7Color),
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
