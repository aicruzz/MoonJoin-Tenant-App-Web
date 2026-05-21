import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobilePhone() => !kIsWeb;
  static bool isWeb() => kIsWeb;

  static bool isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return size < 650 || !kIsWeb;
  }

  static bool isTab(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return size < 1300 && size >= 650;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1300;
  }
}
