import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

ThemeData dark({Color color = const Color(0xFF54b46b)}) => ThemeData(
      fontFamily: AppConstants.fontFamily,
      primaryColor: color,
      secondaryHeaderColor: const Color(0xFF009f67),
      disabledColor: const Color(0xffa2a7ad),
      brightness: Brightness.dark,
      hintColor: const Color(0xFFbebebe),
      cardColor: const Color(0xFF30313C),
      scaffoldBackgroundColor: const Color(0xFF14151D),
      shadowColor: Colors.white.withValues(alpha: 0.04),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: color)),
      colorScheme: ColorScheme.dark(primary: color, secondary: color)
          .copyWith(surface: const Color(0xFF191A26))
          .copyWith(error: const Color(0xFFdd3135)),
      popupMenuTheme: const PopupMenuThemeData(
        color: Color(0xFF29292D),
        surfaceTintColor: Color(0xFF29292D),
      ),
      dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white10),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        surfaceTintColor: Colors.black,
        height: 60,
        padding: EdgeInsets.symmetric(vertical: 5),
      ),
      dividerTheme: const DividerThemeData(
          thickness: 0.5, color: Color(0xFFA0A4A8)),
      tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
    );
