import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class CountryCodeHelper {
  static String? getCountryCode(String? number) {
    if (number == null || number.trim().isEmpty) {
      return null;
    }

    String? countryCode;
    try {
      countryCode = codes.firstWhere(
          (item) => number.contains('${item['dial_code']}'))['dial_code'];
    } catch (error) {
      debugPrint('country error: $error');
    }
    return countryCode;
  }

  static String extractPhoneNumber(String countryCode, String phoneNumber) {
    return phoneNumber.replaceFirst(countryCode, '');
  }
}
