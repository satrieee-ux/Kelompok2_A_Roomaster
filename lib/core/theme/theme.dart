import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.primary800,
      primary: C.primary800,
      secondary: C.secondary500,
      surface: C.grey50,
      error: C.danger500,
    ),
    scaffoldBackgroundColor: C.grey100,
    splashFactory: InkRipple.splashFactory,
  );
  return base.copyWith(
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: C.grey800,
      displayColor: C.grey800,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.grey800,
      contentTextStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(color: C.grey300, thickness: 1, space: 1),
  );
}
