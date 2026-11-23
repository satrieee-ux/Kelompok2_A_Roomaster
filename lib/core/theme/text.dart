import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Hierarki teks final (lihat roomaster-keputusan-desain.md). Font: Plus Jakarta Sans.
class T {
  T._();

  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semibold = FontWeight.w600;
  static const extrabold = FontWeight.w800;

  /// size / lineHeight (px) / weight
  static TextStyle x(double size, double lh, FontWeight w, [Color c = C.grey800]) =>
      GoogleFonts.plusJakartaSans(fontSize: size, height: lh / size, fontWeight: w, color: c);

  static TextStyle h5([Color c = C.grey800]) => x(24, 28, extrabold, c);
  static TextStyle s1([Color c = C.grey800]) => x(18, 28, semibold, c); // judul section besar
  static TextStyle s2([Color c = C.grey800]) => x(16, 24, semibold, c); // judul card / topbar
  static TextStyle b1([Color c = C.grey800]) => x(16, 24, regular, c);
  static TextStyle b2([Color c = C.grey800]) => x(16, 24, semibold, c);
  static TextStyle b3([Color c = C.grey800]) => x(14, 20, regular, c);
  static TextStyle b3m([Color c = C.grey800]) => x(14, 20, medium, c);
  static TextStyle b4([Color c = C.grey800]) => x(14, 20, semibold, c);
  static TextStyle c1([Color c = C.grey800]) => x(12, 16, regular, c);
  static TextStyle c2([Color c = C.grey800]) => x(12, 16, medium, c);
  static TextStyle c2s([Color c = C.grey800]) => x(12, 16, semibold, c);
  static TextStyle c3([Color c = C.grey800]) => x(10, 14, medium, c);
}
