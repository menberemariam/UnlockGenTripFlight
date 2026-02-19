import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color darker(double factor) {
    return Color.fromARGB(
      alpha,
      (red * (1 - factor)).round(),
      (green * (1 - factor)).round(),
      (blue * (1 - factor)).round(),
    );
  }
}