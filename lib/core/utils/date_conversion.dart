import 'package:flutter/material.dart';
import 'package:club_fitness/core/utils/utils.dart';

extension DateTimeExtension on DateTime {
  DateTime get closestZeroYear {
    int year = this.year;
    int newYear = (year ~/ 10) * 10; // Round down to the nearest decade
    return copyWith(year: newYear);
  }

  String get fullDateWithShortMonth =>
      '${day.toString().padLeft(2, '0')} $_getShortMonth $year';

  String get fullDateWithFullMonth =>
      '${day.toString().padLeft(2, '0')} $_getFullMonth $year';

  String get fullTimeWithShortMonth {
    return '$fullDateWithShortMonth, ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  String get formatDateRegular {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  String get formatTimeRegular {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  String formatTimeWithPeriod({bool includeSeconds = true}) {
    int convertedHour = hour % 12 == 0
        ? 12
        : hour % 12; // Convert to 12-hour format
    String formattedHour = convertedHour.toString().padLeft(2, '0'); // Ens
    return '$formattedHour:${minute.toString().padLeft(2, '0')}${includeSeconds ? ":${second.toString().padLeft(2, '0')}" : ""} ${hour >= 12 ? 'PM' : 'AM'}';
  }

  String get formatDateTimeRegular {
    return '$formatDateRegular $formatTimeRegular';
  }

  String hourFormattedWithShortMonth({bool includeSeconds = true}) {
    String year = this.year.toString();
    String month = _getShortMonth;
    String day = this.day.toString().padLeft(2, '0');

    int hour = this.hour % 12 == 0
        ? 12
        : this.hour % 12; // Convert to 12-hour format
    String formattedHour = hour.toString().padLeft(
      2,
      '0',
    ); // Ensure two-digit format
    String minute = this.minute.toString().padLeft(2, '0');
    String second = this.second.toString().padLeft(2, '0');
    String period = this.hour >= 12 ? 'PM' : 'AM';

    return '$day $month $year, $formattedHour:$minute${includeSeconds ? ":$second" : ""} $period';
  }

  String get hourFormattedWithFullMonth {
    String year = this.year.toString();
    String month = _getFullMonth;
    String day = this.day.toString().padLeft(2, '0');

    int hour = this.hour % 12 == 0
        ? 12
        : this.hour % 12; // Convert to 12-hour format
    String formattedHour = hour.toString().padLeft(
      2,
      '0',
    ); // Ensure two-digit format
    String minute = this.minute.toString().padLeft(2, '0');
    String second = this.second.toString().padLeft(2, '0');
    String period = this.hour >= 12 ? 'PM' : 'AM';

    return '$day $month $year, $formattedHour:$minute:$second $period';
  }

  String get fullTimeWithFullMonth {
    return '$fullDateWithFullMonth, ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  String get convertToServerDate {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  String get dateAndShortMonthOnly {
    return '${day.toString().padLeft(2, '0')} $_getShortMonth';
  }

  String get dateAndFullMonthOnly {
    return '${day.toString().padLeft(2, '0')} $_getFullMonth';
  }

  String get weekDayStr {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return 'N/A';
    }
  }

  String get _getShortMonth {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return 'N/A';
    }
  }

  String get _getFullMonth {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'N/A';
    }
  }

  String get getSinceDate {
    final now = DateTime.now();

    if (now.year == year && now.month == month) {
      // Same month and year
      return 'Since $day $_getShortMonth $year';
    } else if (now.year == year) {
      // Same year but earlier month
      return 'Since $_getShortMonth $year';
    } else {
      // Previous year
      return 'Since $year';
    }
  }

  String get formattedDifference {
    final difference = DateTime.now().difference(this);
    final days = difference.inDays;
    final hours = difference.inHours;
    final minutes = difference.inMinutes;
    if (days > 365) {
      return '${days ~/ 365} years';
    } else if (days > 30) {
      return '${days ~/ 30} months';
    } else if (days > 7) {
      return '${days ~/ 7} weeks';
    } else if (days > 0) {
      return '$days days';
    } else if (hours > 0) {
      return '$hours hours';
    } else {
      return '$minutes minutes';
    }
  }

  String get fullDateAtTime {
    return '$fullDateWithFullMonth at $formatTime';
  }

  String get shortDateAtTime {
    return '$fullDateWithShortMonth at $formatTime';
  }

  /// Format time 24-hour
  String get formatTime24Hour {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  /// Convert to 12-hour format
  String get formatTime {
    return '${hour % 12}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';
  }

  String get formatTimeWithoutSecond {
    return '${hour % 12}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';
  }

  ///Get ago time
  ///3 minutes ago, 3 seconds ago, 3 hours ago, 3 days ago, 3 months ago, 3 years ago etc.
  String get getAgoTime {
    final difference = DateTime.now().difference(this);
    final days = difference.inDays;
    final hours = difference.inHours;
    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds;
    final months = difference.inDays ~/ 30;
    final years = difference.inDays ~/ 365;
    if (years > 0) {
      return '$years ${years > 1 ? 'years' : 'year'} ago';
    } else if (months > 0) {
      return '$months ${months > 1 ? 'months' : 'month'} ago';
    } else if (days > 0) {
      return '$days ${days > 1 ? 'days' : 'day'} ago';
    } else if (hours > 0) {
      return '$hours ${hours > 1 ? 'hours' : 'hour'} ago';
    } else if (minutes > 0) {
      return '$minutes ${minutes > 1 ? 'minutes' : 'minute'} ago';
    } else if (seconds > 0) {
      return '$seconds ${seconds > 1 ? 'seconds' : 'second'} ago';
    } else {
      return 'just now';
    }
  }

  String get timeAgoShort {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get timeLeft {
    final difference = this.difference(DateTime.now());
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;
    final months = difference.inDays ~/ 30;
    final years = difference.inDays ~/ 365;
    if (years > 0) {
      return '$years ${years > 1 ? 'years' : 'year'} left';
    } else if (months > 0) {
      return '$months ${months > 1 ? 'months' : 'month'} left';
    } else if (days > 0) {
      return '$days ${days > 1 ? 'days' : 'day'} left';
    } else if (hours > 0) {
      return '$hours ${hours > 1 ? 'hours' : 'hour'} left';
    } else if (minutes > 0) {
      return '$minutes ${minutes > 1 ? 'minutes' : 'minute'} left';
    }
    return 'Ending Soon';
  }

  bool get isToday {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.year == year &&
        tomorrow.month == month &&
        tomorrow.day == day;
  }
}

extension DurationConvertorExtension on num {
  Duration get milliseconds => Duration(milliseconds: toInt());

  Duration get sec => Duration(seconds: toInt());

  Duration get min => Duration(minutes: toInt());

  Duration get hr => Duration(hours: toInt());

  Duration get day => Duration(days: toInt());

  Duration get wk => Duration(days: toInt() * 7);

  Duration get yr => Duration(days: toInt() * 365);

  Duration get mo => Duration(days: toInt() * 30);
}

extension DateTimeStringExtension on String {
  TimeOfDay get fromTimeStringToDateTime {
    List<String> parts = split(':');
    if (parts.isEmpty) return TimeOfDay.now();
    int hour = int.parse(parts[0].or('0'));
    if (parts.length < 2) return TimeOfDay(hour: hour, minute: 0);
    int minute = int.parse(parts[1].or('0'));
    return TimeOfDay(hour: hour, minute: minute);
  }

  String get formatTime {
    // Split the time string
    List<String> parts = split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    // Determine AM or PM
    String period = hour >= 12 ? 'PM' : 'AM';

    // Convert to 12-hour format
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;

    // Return formatted string
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  ///Convert date from format YYYY-MM-DD to DateTime
  DateTime get fromYYYYMMDD {
    try {
      final year = int.parse(substring(0, 4));
      final month = int.parse(substring(5, 7));
      final day = int.parse(substring(8, 10));
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime(0);
    }
  }
}

extension FormatServerTime on DateTime {
  String get toYYYYMMDD {
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  String get toHHMMSS {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  String get toHHMM {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

extension ConvertToDateTimeExtension on String {
  DateTime get toFutureDateTime {
    String date = this;

    // If server didn't send timezone info
    if (!date.contains(RegExp(r'[+-]'))) {
      // Parse as if it's a naive UTC datetime
      final parsed = DateTime.tryParse(date);

      if (parsed != null) {
        // Apply local timezone offset
        final offset = DateTime.now().timeZoneOffset;
        return parsed.subtract(offset);
      }
    }
    return DateTime.tryParse(date) ?? DateTime.now().add(1.day);
  }

  DateTime get toDateTime {
    final date = trim();

    // If string has no timezone info, assume it's UTC
    if (!date.contains(RegExp(r'[+-Z]'))) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) {
        // Treat parsed as UTC and convert to local
        return DateTime.utc(
          parsed.year,
          parsed.month,
          parsed.day,
          parsed.hour,
          parsed.minute,
          parsed.second,
          parsed.millisecond,
          parsed.microsecond,
        ).toLocal();
      }
    }

    // Otherwise parse normally (includes timezone)
    return DateTime.tryParse(date)?.toLocal() ?? DateTime.now();
  }

  DateTime? get yearToDate {
    int? year = int.tryParse(this);
    if (year == null) return null;
    return DateTime(year);
  }
}

extension TimeConversion on String {
  ///Convert iso time to a readable time without intl, example: 11:00:00 - 11:00 AM and 18:00:00 to 6:00 PM
  String toReadableTime() {
    final parts = split(':');
    if (parts.isEmpty) return '';
    if (parts.length < 2) return '';
    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];

    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;

    return '$hour:$minute $period';
  }
}
