import 'dart:math';

class Randomizer {
  static int randomNumber(int max) => Random().nextInt(max);

  static int secureRandomNumber(int max) => Random.secure().nextInt(max);

  static int secureOtp({int digits = 4}) {
    final min = pow(10, digits - 1).toInt();
    final max = pow(10, digits).toInt();
    return Random.secure().nextInt(max - min) + min;
  }

  static String secureOtpString({int digits = 4}) {
    final rand = Random.secure();
    return List.generate(digits, (_) => rand.nextInt(10)).join();
  }

  static int clampInt(int index, int total) => index % total;

  static String getRandomImage(double height, double width) {
    int roundedHeight = height.round();
    int roundedWidth = width.round();
    return 'https://picsum.photos/$roundedWidth/$roundedHeight';
  }
}

extension AlphabetIndexExtension on String {
  int get alphabetIndex {
    if (isEmpty) return 0;
    String word = toLowerCase();
    String letter = word[0];
    return letter.codeUnitAt(0) - 'a'.codeUnitAt(0);
  }
}

extension RandomItemFromList<T> on List<T> {
  T get randomItem => this[Randomizer.randomNumber(length)];
}
