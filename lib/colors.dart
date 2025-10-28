import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Based on YeekTV website
  static const Color primaryRed = Color(0xFFE50914);
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  
  // Background Colors
  static const Color backgroundDark = Color(0xFF141414);
  static const Color backgroundCard = Color(0xFF1F1F1F);
  static const Color backgroundGradient = Color(0xFF0F0F0F);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textMuted = Color(0xFF808080);
  
  // Accent Colors
  static const Color accentBlue = Color(0xFF0071EB);
  static const Color accentGreen = Color(0xFF46D369);
  static const Color accentYellow = Color(0xFFFFD700);
  
  // Border Colors
  static const Color borderLight = Color(0xFF333333);
  static const Color borderDark = Color(0xFF1A1A1A);
  
  // Button Colors
  static const Color buttonPrimary = Color(0xFFE50914);
  static const Color buttonSecondary = Color(0xFF333333);
  static const Color buttonDisabled = Color(0xFF666666);
  
  // Overlay Colors
  static const Color overlayDark = Color(0x80000000);
  static const Color overlayLight = Color(0x40FFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF46D369);
  static const Color error = Color(0xFFE50914);
  static const Color warning = Color(0xFFFFD700);
  static const Color info = Color(0xFF0071EB);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE50914),
      Color(0xFFB81D13),
    ],
  );
  
  static const LinearGradient BackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000000),
      Color(0xFF141414),
      Color(0xFF1F1F1F),
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1F1F1F),
      Color(0xFF2A2A2A),
    ],
  );
}
