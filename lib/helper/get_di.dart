import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/common/controllers/localization_controller.dart';
import 'package:moonjoin_cloud/common/controllers/splash_controller.dart';
import 'package:moonjoin_cloud/common/controllers/theme_controller.dart';
import 'package:moonjoin_cloud/config/environment.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/features/auth/domain/repositories/auth_repository.dart';
import 'package:moonjoin_cloud/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:moonjoin_cloud/features/auth/domain/services/auth_service.dart';
import 'package:moonjoin_cloud/features/auth/domain/services/auth_service_interface.dart';
import 'package:moonjoin_cloud/helper/network_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, Map<String, String>>> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // Core platform services
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => Connectivity());
  Get.lazyPut(() => NetworkInfo(Get.find()));
  Get.lazyPut(() => ApiClient(
        appBaseUrl: Environment.baseUrl,
        sharedPreferences: Get.find(),
      ));

  // App-wide controllers
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(sharedPreferences: Get.find()));

  // Auth feature
  Get.lazyPut<AuthRepositoryInterface>(
      () => AuthRepository(apiClient: Get.find()));
  Get.lazyPut<AuthServiceInterface>(() => AuthService(
        authRepo: Get.find<AuthRepositoryInterface>(),
        sharedPreferences: Get.find(),
      ));
  Get.lazyPut(() => AuthController(authService: Get.find()));

  // Languages — load JSON from assets (currently English only).
  final Map<String, Map<String, String>> languages = {};
  try {
    final raw = await rootBundle.loadString('assets/language/en.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    languages['en_US'] = decoded.map((k, v) => MapEntry(k, v.toString()));
  } catch (_) {
    languages['en_US'] = {};
  }
  return languages;
}
