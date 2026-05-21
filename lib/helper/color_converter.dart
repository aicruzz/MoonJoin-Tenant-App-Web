import 'package:flutter/material.dart';

Color colorFromHex(String hex) {
  var clean = hex.replaceFirst('#', '');
  if (clean.length == 6) clean = 'FF$clean';
  return Color(int.parse(clean, radix: 16));
}
