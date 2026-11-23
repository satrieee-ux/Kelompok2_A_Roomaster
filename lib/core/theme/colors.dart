import 'package:flutter/material.dart';

/// Token warna Roomaster (sama dengan tailwind.config.js di Laravel).
class C {
  C._();

  // Primary
  static const primary50 = Color(0xFFB5D7FF);
  static const primary100 = Color(0xFF9AC8FF);
  static const primary200 = Color(0xFF74B1F2);
  static const primary300 = Color(0xFF569FE2);
  static const primary400 = Color(0xFF4895C2);
  static const primary500 = Color(0xFF3B7BA0);
  static const primary600 = Color(0xFF2E6280);
  static const primary700 = Color(0xFF254F67);
  static const primary800 = Color(0xFF153343);
  static const primary900 = Color(0xFF112A35);

  // Secondary
  static const secondary50 = Color(0xFFFFE1C1);
  static const secondary100 = Color(0xFFFFD2A3);
  static const secondary200 = Color(0xFFFFC385);
  static const secondary300 = Color(0xFFFEB161);
  static const secondary400 = Color(0xFFEE914E);
  static const secondary500 = Color(0xFFD97A47);
  static const secondary600 = Color(0xFFC66531);
  static const secondary700 = Color(0xFFA35139);
  static const secondary800 = Color(0xFF85422E);
  static const secondary900 = Color(0xFF773825);

  // Grey
  static const grey50 = Color(0xFFF9FAFB);
  static const grey100 = Color(0xFFF3F4F6);
  static const grey200 = Color(0xFFE5E7EA);
  static const grey300 = Color(0xFFD2D5DB);
  static const grey400 = Color(0xFF9EA2AE);
  static const grey500 = Color(0xFF6D717F);
  static const grey600 = Color(0xFF4D5461);
  static const grey700 = Color(0xFF394050);
  static const grey800 = Color(0xFF212936);
  static const grey900 = Color(0xFF131927);

  // Success
  static const success50 = Color(0xFFE0F8E6);
  static const success100 = Color(0xFFC2F0CC);
  static const success400 = Color(0xFF6DCB84);
  static const success500 = Color(0xFF43B75D);
  static const success800 = Color(0xFF256533);

  // Danger
  static const danger50 = Color(0xFFFCE5E5);
  static const danger100 = Color(0xFFFAC5C3);
  static const danger300 = Color(0xFFF58380);
  static const danger500 = Color(0xFFEE443F);
  static const danger800 = Color(0xFF832424);

  // Warning
  static const warning50 = Color(0xFFFFF7E6);
  static const warning100 = Color(0xFFFFE9B8);
  static const warning300 = Color(0xFFFFC84D);
  static const warning500 = Color(0xFFFFAA00);
  static const warning800 = Color(0xFF8C5E00);

  static const myitsBlue = Color(0xFF00589F);
  static const myitsLink = Color(0xFF3B9BEB);
  static const myitsButton = Color(0xFF0A91FF);

  /// shadow-card
  static const List<BoxShadow> shadowCard = [
    BoxShadow(color: Color(0x14141A28), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0F141A28), blurRadius: 2, offset: Offset(0, 1)),
  ];
}
