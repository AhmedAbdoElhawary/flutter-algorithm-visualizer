import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:flutter/material.dart';

abstract class AlgorithmControlInterface {
  void reset();
  void stepBackward();
  void stepForward();
  Future<void> togglePlay(BuildContext context);
  void changeSpeed(PlaybackSpeed speed);
  bool get backwardValidation;
  bool get forwardValidation;
  bool get isPlaying;
  PlaybackSpeed get getSpeed;
}
