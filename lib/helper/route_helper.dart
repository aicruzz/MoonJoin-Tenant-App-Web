import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/not_found.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/features/auth/screens/forgot_password_screen.dart';
import 'package:moonjoin_cloud/features/auth/screens/otp_verification_screen.dart';
import 'package:moonjoin_cloud/features/auth/screens/reset_password_screen.dart';
import 'package:moonjoin_cloud/features/auth/screens/sign_in_screen.dart';
import 'package:moonjoin_cloud/features/auth/screens/sign_up_screen.dart';
import 'package:moonjoin_cloud/features/menu/screens/main_screen.dart';
import 'package:moonjoin_cloud/features/notifications/screens/notifications_screen.dart';
import 'package:moonjoin_cloud/features/onboarding/screens/onboarding_screen.dart';
import 'package:moonjoin_cloud/features/settings/screens/settings_screen.dart';
import 'package:moonjoin_cloud/features/splash/screens/splash_screen.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String onBoarding = '/on-boarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String main = '/main';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static String getInitialRoute() => initial;
  static String getSplashRoute() => splash;
  static String getOnBoardingRoute() => onBoarding;
  static String getSignInRoute() => signIn;
  static String getSignUpRoute() => signUp;
  static String getOtpRoute() => otp;
  static String getForgotPasswordRoute() => forgotPassword;
  static String getResetPasswordRoute() => resetPassword;
  static String getMainRoute(String page) => '$main?page=$page';

  static Widget _guard(Widget child) {
    if (Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn()) {
      return child;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(signIn);
    });
    return const Scaffold(body: SizedBox.shrink());
  }

  static final List<GetPage> routes = [
    GetPage(name: initial, page: () => const SplashScreen()),
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: onBoarding, page: () => const OnboardingScreen()),
    GetPage(
      name: signIn,
      page: () => const SignInScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: signUp,
      page: () => const SignUpScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: otp,
      page: () => const OtpVerificationScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: resetPassword,
      page: () => const ResetPasswordScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: main,
      page: () =>
          _guard(MainScreen(page: Get.parameters['page'] ?? 'dashboard')),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: notifications,
      page: () => _guard(const NotificationsScreen()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: settings,
      page: () => _guard(const SettingsScreen()),
      transition: Transition.fadeIn,
    ),
    GetPage(name: '/not-found', page: () => const NotFound()),
  ];
}
