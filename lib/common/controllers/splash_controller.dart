import 'package:get/get.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  SplashController({required this.sharedPreferences});

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  bool get hasSeenIntro =>
      sharedPreferences.getBool(AppConstants.intro) ?? false;

  Future<void> markIntroSeen() async {
    await sharedPreferences.setBool(AppConstants.intro, true);
    update();
  }

  void setFirstTimeConnectionCheck(bool value) {
    _firstTimeConnectionCheck = value;
  }
}
