import 'dart:math';

class CustomRandom {
  static List<int> generateList(int maxNum, int length) {
    if (length > maxNum + 1) length = maxNum;

    List<int> numbers = List<int>.generate(maxNum + 1, (index) => index);

    numbers.shuffle(Random());

    return numbers.sublist(0, length);
  }
}