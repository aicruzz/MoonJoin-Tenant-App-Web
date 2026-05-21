import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';

class ApiChecker {
  static void checkApi(Response response, {bool getXSnackBar = false}) {
    if (response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData();
      Get.offAllNamed(RouteHelper.getSignInRoute());
    } else {
      showCustomSnackBar(response.statusText, getXSnackBar: getXSnackBar);
    }
  }
}
