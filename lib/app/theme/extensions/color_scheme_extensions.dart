import 'package:flutter/material.dart';
import 'brightness_extensions.dart';

extension ColorSchemeExt on ColorScheme {
  Color get vipColor =>
      brightness.isLight ? const Color(0xFFFF6699) : const Color(0xFFD44E7D);

  Color get freeColor =>
      brightness.isLight ? const Color(0xFFFF7F24) : const Color(0xFFD66011);

  bool get isLight => brightness.isLight;

  bool get isDark => brightness.isDark;
}
