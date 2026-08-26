import 'package:club_fitness/core/utils/utils.dart';

class CommonCalculations {
  static num getAverage(num a, num b) {
    return (a + b) / 2;
  }

  //get Average Price per sq. ft.
  static num getAveragePricePerSqFt(num price, num sqFt) {
    if (price == 0 || sqFt == 0) return 0;
    return price / sqFt;
  }

  static String getAveragePricePerSqFtString(num price, num sqft) {
    if (price == 0 || sqft == 0) return 0.formatInINRShort;
    return (price / sqft).formatInINRShort;
  }

  static String getRatingComment(num? rating) {
    if (rating == null || rating <= 0) return 'Not available';

    final comments = ['Bad', 'Average', 'Good', 'Very Good', 'Excellent'];

    final clampedIndex = rating.clamp(1, 5).round() - 1;
    return comments[clampedIndex];
  }
}

extension LeastAndBestAmongExtension on num {
  /// Returns the smaller of two numbers
  num leastOf(num other) {
    return this < other ? this : other;
  }

  /// Returns the larger of two numbers
  num bestOf(num other) {
    return this > other ? this : other;
  }

  /// Returns the smallest number in a list
  num leastAmong(List<num> numbers) {
    return numbers.reduce((a, b) => a.leastOf(b));
  }

  /// Returns the largest number in a list
  num bestAmong(List<num> numbers) {
    return numbers.reduce((a, b) => a.bestOf(b));
  }
}

extension PluralExtension on num {
  String pluralize(String word, {String? plural}) {
    if (this == 1) return word;
    return plural ?? '${word}s';
  }

  String pluralizeWithCount(String word, {String? plural}) {
    return '$this ${pluralize(word, plural: plural)}';
  }
}

extension RoundExtension on num {
  num get roundIfWhole {
    if (toInt() == this) {
      return toInt();
    }
    return this;
  }

  String roundAsFixedString(int fixed) {
    if (toInt() == this) {
      return toInt().toString();
    }
    return toStringAsFixed(fixed);
  }

  String get roundWithFixed {
    if (toInt() == this) {
      return toInt().toString();
    }
    return toStringAsFixed(2);
  }

  num roundToClosestWithRemainder(num remainder) {
    final lastDigit = this % remainder;
    if (lastDigit < 5) {
      // round down
      return this - lastDigit;
    } else {
      // round up
      return this + (remainder - lastDigit);
    }
  }

  num get roundToClosestZero {
    final lastDigit = this % 10; // get remainder (last digit in decimal base)
    if (lastDigit < 5) {
      // round down
      return this - lastDigit;
    } else {
      // round up
      return this + (10 - lastDigit);
    }
  }

  num get roundToLowestZero {
    final lastDigit = this % 10;
    return this - lastDigit;
  }
}

extension KmConversionExtension on num {
  num get mToKm => this / 1000;
  num get kmToM => this * 1000;

  ///Use this with meter to get correct km or meter
  String get kmOrM {
    if (this > 1000) return '$mToKm km';
    return '$this m';
  }

  ///Use this with km to get correct km or meter
  String get mOrKm {
    if (this > 1) return '$kmToM m';
    return '$this km';
  }
}
