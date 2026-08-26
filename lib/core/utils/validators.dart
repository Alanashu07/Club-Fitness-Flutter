import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Validators {
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phoneRegex = RegExp(r'^(\+?[1-9]\d{1,14}|\d{6,15})$');

  static final RegExp urlRegex = RegExp(
    r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?(\/[^\s]*)?$',
  );

  static final RegExp zeroRegex = RegExp(r'^0*\.?0*$');

  static final RegExp digitsWithOptionsRegex = RegExp(r'^\d+\.?\d{0,2}$');

  //Number with +
  static final RegExp numberWithPlusRegex = RegExp(r'^\+?\d+$');

  static final FilteringTextInputFormatter digitsFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'));

  static String? validateEmail(String? email) {
    if (email == null) return null;
    if (email.isEmpty) return 'Enter Email';
    if (!emailRegex.hasMatch(email)) return 'Enter a valid Email';
    return null;
  }

  static bool isValidEmail(String email) => emailRegex.hasMatch(email);

  static bool isValidPhone(String phone) => phoneRegex.hasMatch(phone);

  static String? validateUrl(String? url) {
    if (url == null) return null;
    if (url.isEmpty) return 'Enter URL';
    if (!urlRegex.hasMatch(url)) return 'Enter a valid URL';
    return null;
  }

  static String? validateUsername(String? email) {
    if (email == null) return null;
    if (email.isEmpty) return 'Enter Username';
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null) return null;
    if (phone.isEmpty) return 'Enter Phone number';
    if (!phoneRegex.hasMatch(phone)) return 'Enter valid phone number';
    return null;
  }

  static String? validateEmpty(String? value) {
    if (value == null) return null;
    if (value.isEmpty) return 'Field is required';
    return null;
  }

  static String? validateWithValue(String? value, String field) {
    if (value == null) return null;
    if (value.isEmpty) return '$field is required';
    return null;
  }

  static String? validatePassword(String? value, String password) {
    if (value == null) return null;
    if (value.isEmpty) return 'Confirm Password is required';
    if (value != password) return 'Passwords does not match';
    return null;
  }

  static String? validateDateOfBirth(String value, {bool isRequired = false}) {
  if (value.trim().isEmpty) {
    if (!isRequired) return null;
    return 'Date of Birth is required';
  }

  final parts = value.split('/').map((e) => e.trim()).toList();

  if (parts.length != 3 ||
      parts[0].length != 2 ||
      parts[1].length != 2 ||
      parts[2].length != 4) {
    return 'Enter date as DD / MM / YYYY';
  }

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);

  if (day == null || month == null || year == null) {
    return 'Enter a valid date';
  }

  try {
    final date = DateTime(year, month, day);

    // DateTime automatically rolls invalid dates over.
    // Example: 31/02/2020 → 02/03/2020.
    if (date.year != year ||
        date.month != month ||
        date.day != day) {
      return 'Enter a valid date';
    }

    // Don't allow a future DOB
    if (date.isAfter(DateTime.now())) {
      return 'Date of Birth cannot be in the future';
    }

    return null;
  } catch (_) {
    return 'Enter a valid date';
  }
}
}

class RegisterValidator {
  final ValueNotifier<Map<String, String>> errors = ValueNotifier({});

  void setErrors(Map<String, String> value) => errors.value = value;

  void clearErrors() => errors.value = {};

  void removeKey(String key) => errors.value.remove(key);

  String? takeError(String key) => errors.value[key];
}

class DateOfBirthFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Digits only
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Maximum: DDMMYYYY
    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }

    // Validate day while typing
    if (digits.length >= 2) {
      final day = int.tryParse(digits.substring(0, 2));

      if (day == null || day < 1 || day > 31) {
        return oldValue;
      }
    }

    // Validate month while typing
    if (digits.length >= 4) {
      final month = int.tryParse(digits.substring(2, 4));

      if (month == null || month < 1 || month > 12) {
        return oldValue;
      }
    }

    String formatted = '';

    if (digits.isNotEmpty) {
      formatted = digits.substring(0, digits.length.clamp(0, 2));
    }

    if (digits.length > 2) {
      formatted += ' / ';
      formatted += digits.substring(
        2,
        digits.length.clamp(2, 4),
      );
    }

    if (digits.length > 4) {
      formatted += ' / ';
      formatted += digits.substring(4);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}