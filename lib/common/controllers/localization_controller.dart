import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  LocalizationController({required this.sharedPreferences}) {
    _loadCurrentLanguage();
  }

  Locale _locale = const Locale('en', 'US');
  Locale get locale => _locale;

  void _loadCurrentLanguage() {
    final lang = sharedPreferences.getString(AppConstants.languageCode) ?? 'en';
    final country = sharedPreferences.getString(AppConstants.countryCode) ?? 'US';
    _locale = Locale(lang, country);
    update();
  }

  void setLanguage(Locale locale) {
    _locale = locale;
    Get.updateLocale(locale);
    sharedPreferences.setString(
        AppConstants.languageCode, locale.languageCode);
    sharedPreferences.setString(
        AppConstants.countryCode, locale.countryCode ?? '');
    update();
  }
}
