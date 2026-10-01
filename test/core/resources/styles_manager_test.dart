import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each style has its own weight and the base size', () {
    for (final (style, weight) in [
      (const GetRegularStyle(), FontWeightManager.regular),
      (const GetMediumStyle(), FontWeightManager.medium),
      (const GetSemiBoldStyle(), FontWeightManager.semiBold),
    ]) {
      expect(style.fontWeight, weight);
      expect(style.fontSize, 16);
    }
  });

  test('no colour by default, so text follows the theme', () {
    expect(const GetRegularStyle().color, isNull);
    expect(const GetMediumStyle().color, isNull);
    expect(const GetSemiBoldStyle().color, isNull);
  });

  test('what a caller passes is kept', () {
    const style = GetMediumStyle(fontSize: 12, color: Colors.red, letterSpacing: 1.2, height: 1.4);

    expect(style.fontSize, 12);
    expect(style.color, Colors.red);
    expect(style.letterSpacing, 1.2);
    expect(style.height, 1.4);
    expect(style.decoration, TextDecoration.none);
  });
}
