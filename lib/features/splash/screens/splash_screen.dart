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
    // Allow a brief brand moment, then route. The async call is deliberately
    // not awaited inside the delayed callback to keep the initial paint snappy.
    Future.delayed(const Duration(milliseconds: 600), _route);
  }

  Future<void> _route() async {
    final splash = Get.find<SplashController>();
    final auth = Get.find<AuthController>();

    if (!splash.hasSeenIntro) {
      Get.offAllNamed(RouteHelper.onBoarding);
      return;
    }

    if (!auth.isLoggedIn()) {
      Get.offAllNamed(RouteHelper.getSignInRoute());
      return;
    }

    // Warm-up: prefetch /api/v1/merchant/profile so the dashboard header has
    // the merchant name on first paint. Capped at 4 s so a slow backend
    // doesn't strand the splash — we route either way.
    try {
      await auth.fetchProfile().timeout(const Duration(seconds: 4));
    } catch (_) {
      // Swallow — profile data is non-blocking for routing.
    }

    Get.offAllNamed(RouteHelper.getMainRoute('dashboard'));
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
