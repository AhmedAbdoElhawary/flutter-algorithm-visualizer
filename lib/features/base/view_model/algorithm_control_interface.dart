import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';

abstract class AlgorithmControlInterface {
  void reset();
  void stepBackward();
  void stepForward();
  Future<void> togglePlay();
  void changeSpeed(PlaybackSpeed speed);
  bool get backwardValidation;
  bool get forwardValidation;
  bool get isPlaying;
  PlaybackSpeed get getSpeed;
}
