import 'package:algorithm_visualizer/core/helpers/current_device.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCircularProgress extends StatelessWidget {
  final ThemeEnum? color;
  const CustomCircularProgress({this.color, super.key});

  @override
  Widget build(BuildContext context) {
    bool isThatAndroid = defaultTargetPlatform == TargetPlatform.android;
    final color = this.color;
    final tColor =
        color == null ? Theme.of(context).focusColor : context.getColor(color);

    return isThatAndroid
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.75,
                child: SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                      strokeWidth: 3.r, color: tColor),
                ),
              ),
            ],
          )
        : CupertinoActivityIndicator(
            color: tColor, radius: 9.r, animating: true);
  }
}

class SmallCircularProgress extends StatelessWidget {
  final ThemeEnum? color;
  const SmallCircularProgress({this.color, super.key});

  @override
  Widget build(BuildContext context) {
    bool isThatAndroid = defaultTargetPlatform == TargetPlatform.android;
    final color = this.color;
    final tColor =
        color == null ? Theme.of(context).focusColor : context.getColor(color);

    return isThatAndroid
        ? SizedBox(
            width: 15.r,
            height: 15.r,
            child: ClipOval(
              child:
                  CircularProgressIndicator(strokeWidth: 3.5.r, color: tColor),
            ),
          )
        : CupertinoActivityIndicator(
            color: tColor, radius: 9.r, animating: true);
  }
}

class ThineCircularProgress extends StatelessWidget {
  final ThemeEnum? color;
  final ThemeEnum? backgroundColor;
  final double strokeWidth;
  const ThineCircularProgress(
      {super.key, this.color, this.backgroundColor, this.strokeWidth = 2});

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    final tColor =
        color == null ? Theme.of(context).focusColor : context.getColor(color);
    final backgroundColor = this.backgroundColor;

    return Center(
      child: CircularProgressIndicator.adaptive(
        strokeWidth: strokeWidth.r,
        valueColor: AlwaysStoppedAnimation<Color>(tColor),
        backgroundColor:
            backgroundColor != null ? context.getColor(backgroundColor) : null,
      ),
    );
  }
}

class ThineCircularProgressWithValue extends StatelessWidget {
  final ThemeEnum? color;
  final ThemeEnum? backgroundColor;
  final double strokeWidth;
  final double value;
  const ThineCircularProgressWithValue({
    super.key,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 2,
    this.value = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    final tColor =
        color == null ? Theme.of(context).focusColor : context.getColor(color);
    final backgroundColor = this.backgroundColor;

    return Center(
      child: CircularProgressIndicator.adaptive(
        strokeWidth: strokeWidth.r,
        valueColor: AlwaysStoppedAnimation<Color>(tColor),
        backgroundColor:
            backgroundColor != null ? context.getColor(backgroundColor) : null,
        value: value,
      ),
    );
  }
}

class CustomLinearProgress extends StatelessWidget {
  final ThemeEnum color;
  final ThemeEnum backgroundColor;
  final double strokeWidth;
  const CustomLinearProgress({
    super.key,
    this.color = ThemeEnum.focusColor,
    this.backgroundColor = ThemeEnum.whiteD2Color,
    this.strokeWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LinearProgressIndicator(
        minHeight: strokeWidth.r,
        color: context.getColor(color),
        backgroundColor: context.getColor(backgroundColor),
      ),
    );
  }
}

class CustomThineCircularProgress extends StatelessWidget {
  final ThemeEnum? color;
  final ThemeEnum? backgroundColor;
  final double strokeWidth;
  const CustomThineCircularProgress(
      {super.key, this.color, this.backgroundColor, this.strokeWidth = 2});

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    final tColor =
        color == null ? Theme.of(context).focusColor : context.getColor(color);
    final backgroundColor = this.backgroundColor;

    return Center(
      child: context.isAndroid
          ? CircularProgressIndicator(
              strokeWidth: strokeWidth.r,
              valueColor: AlwaysStoppedAnimation<Color>(tColor),
              backgroundColor: backgroundColor != null
                  ? context.getColor(backgroundColor)
                  : null,
            )
          : CupertinoActivityIndicator(
              color: tColor, radius: strokeWidth.r, animating: true),
    );
  }
}

class CustomThineCircularProgressWithValue extends StatelessWidget {
  final ThemeEnum? color;
  final ThemeEnum? backgroundColor;
  final double strokeWidth;
  final double value;
  const CustomThineCircularProgressWithValue({
    super.key,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 2,
    this.value = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    final tColor =
        color == null ? Theme.of(context).focusColor : context.getColor(color);
    final backgroundColor = this.backgroundColor;

    return Center(
      child: context.isAndroid
          ? CircularProgressIndicator(
              strokeWidth: strokeWidth.r,
              valueColor: AlwaysStoppedAnimation<Color>(tColor),
              backgroundColor: backgroundColor != null
                  ? context.getColor(backgroundColor)
                  : null,
              value: value,
            )
          : CupertinoActivityIndicator(
              color: tColor, radius: strokeWidth.r, animating: false),
    );
  }
}

class BaseCircularProgress extends StatelessWidget {
  final ThemeEnum? color;
  final ThemeEnum? backgroundColor;
  final double strokeWidth;
  const BaseCircularProgress({
    super.key,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    final tColor =
        color == null ? Theme.of(context).focusColor : context.getColor(color);
    final backgroundColor = this.backgroundColor;

    return Center(
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth.r,
        valueColor: AlwaysStoppedAnimation<Color>(tColor),
        backgroundColor:
            backgroundColor != null ? context.getColor(backgroundColor) : null,
      ),
    );
  }
}
