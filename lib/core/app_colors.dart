
import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF080D1B);
  static const surface = Color(0xFF111A2E);
  static const surfaceLight = Color(0xFF1A2740);

  static const navy = Color(0xFF071B49);
  static const primary = Color(0xFF3978FF);
  static const secondary = Color(0xFF8B5CF6);
  static const sky = Color(0xFF42B6FF);

  static const income = Color(0xFF25D6A2);
  static const expense = Color(0xFFFF647C);
  static const warning = Color(0xFFFFB84D);
  static const purple = Color(0xFF9B7BFF);
  static const pink = Color(0xFFFF72B6);

  static const white = Color(0xFFFFFFFF);
  static const textDark = Color(0xFFF4F7FF);
  static const textGrey = Color(0xFF9AA9C2);
  static const grey = textGrey;

  static const gradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [
      Color(0xFF142D65),
      Color(0xFF2459C7),
      Color(0xFF713FE5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardGradient = LinearGradient(
    colors: [
      Color(0xFF2459C7),
      Color(0xFF633FE0),
      Color(0xFF9B55D9),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
