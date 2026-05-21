import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/controllers/splash_controller.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/images.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), _route);
  }

  void _route() {
    final splash = Get.find<SplashController>();
    final auth = Get.find<AuthController>();
    if (!splash.hasSeenIntro) {
      Get.offAllNamed(RouteHelper.onBoarding);
    } else if (auth.isLoggedIn()) {
      Get.offAllNamed(RouteHelper.getMainRoute('dashboard'));
    } else {
      Get.offAllNamed(RouteHelper.getSignInRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Images.logo, height: 96),
            const SizedBox(height: 24),
            Text('MoonJoin Cloud',
                style: robotoBold.copyWith(
                    fontSize: 22, color: Theme.of(context).primaryColor)),
          ],
        ),
      ),
    );
  }
}
