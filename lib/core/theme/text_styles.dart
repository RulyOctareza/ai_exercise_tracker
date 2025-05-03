import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'app_colors.dart';

class TextStyles {
  // League Spartan
  static TextStyle heading1 = GoogleFonts.leagueSpartan(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static TextStyle heading2 = GoogleFonts.leagueSpartan(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static TextStyle heading3 = GoogleFonts.leagueSpartan(
    fontSize: 20.0,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.white,
  );

  // Poppins
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
  );

  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16.0,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.white,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
    color: AppColors.lightPurple,
  );

  // Exercise counter
  static TextStyle exerciseCounter = GoogleFonts.leagueSpartan(
    fontSize: 48.0,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
}
