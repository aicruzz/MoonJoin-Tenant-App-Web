import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/controllers/localization_controller.dart';
import 'package:moonjoin_cloud/common/controllers/theme_controller.dart';
import 'package:moonjoin_cloud/helper/responsive_helper.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/theme/dark_theme.dart';
import 'package:moonjoin_cloud/theme/light_theme.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';
import 'package:moonjoin_cloud/util/messages.dart';
import 'package:url_strategy/url_strategy.dart';

import 'helper/get_di.dart' as di;

Future<void> main() async {
  if (ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = _PermissiveHttpOverrides();
  }
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is intentionally NOT wired here in Phase 0. The new dedicated
  // MoonJoin Cloud Firebase project will be added once `google-services.json`
  // and `GoogleService-Info.plist` are dropped under `firebase/<env>/`.
  // See Phase 5 of the plan.

  final languages = await di.init();
  runApp(MoonJoinCloudApp(languages: languages));
}

class MoonJoinCloudApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  const MoonJoinCloudApp({super.key, required this.languages});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localeController) {
        return GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: Get.key,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
          ),
          theme: themeController.darkTheme ? dark() : light(),
          locale: localeController.locale,
          translations: Messages(languages: languages),
          fallbackLocale: const Locale('en', 'US'),
          initialRoute: RouteHelper.getSplashRoute(),
          getPages: RouteHelper.routes,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 350),
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1)),
              child: widget ?? const SizedBox.shrink(),
            );
          },
        );
      });
    });
  }
}

class _PermissiveHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    if (kDebugMode) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    }
    return client;
  }
}
