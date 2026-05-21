import 'package:get/get.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static bool isLoggedIn() {
    return Get.find<SharedPreferences>().containsKey(AppConstants.token) &&
        (Get.find<SharedPreferences>().getString(AppConstants.token) ?? '')
            .isNotEmpty;
  }

  static String? getMerchantToken() {
    return Get.find<SharedPreferences>().getString(AppConstants.token);
  }
}
