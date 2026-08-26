import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

class FontConstant {
  static TextStyle get oxygen =>
      GoogleFonts.oxygen(fontWeight: FontWeight.w400, fontSize: 14.0.sp);

  static TextStyle get highlight => GoogleFonts.oxygen(
        fontWeight: FontWeight.w900,
        fontSize: 50.0.sp,
        fontStyle: FontStyle.italic,
        color: Colors.white,
      );

  static TextTheme get oxygenTheme => GoogleFonts.oxygenTextTheme();

  static TextStyle get oxygenXXLBold =>
      oxygen.copyWith(fontSize: 32.0.sp, fontWeight: FontWeight.bold);

  static TextStyle get oxygenXLBold =>
      oxygen.copyWith(fontSize: 24.0.sp, fontWeight: FontWeight.bold);

  static TextStyle get oxygenLargeBold =>
      oxygen.copyWith(fontWeight: FontWeight.bold, fontSize: 18.0.sp);

  static TextStyle get oxygenMediumBold =>
      oxygen.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0.sp);

  static TextStyle get oxygenSmallBold =>
      oxygen.copyWith(fontWeight: FontWeight.bold, fontSize: 12.0.sp);

  static TextStyle get oxygenXXL => oxygen.copyWith(fontSize: 48.0.sp);

  static TextStyle get oxygenXL => oxygen.copyWith(fontSize: 24.0.sp);

  static TextStyle get oxygenSmall =>
      oxygen.copyWith(fontWeight: FontWeight.normal, fontSize: 12.0.sp);

  static TextStyle get oxygenMedium =>
      oxygen.copyWith(fontWeight: FontWeight.normal, fontSize: 16.0.sp);

  static TextStyle get oxygenLarge =>
      oxygen.copyWith(fontWeight: FontWeight.normal, fontSize: 18.0.sp);

  static TextStyle get headerTheme =>
      GoogleFonts.dancingScript(fontSize: 40.0.sp);
}
