import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primaryBrown = Color(0xFF8B4513);
  static const secondaryBrown = Color(0xFFD2691E);
  static const lightBrown = Color(0xFFDEB887);

  // Accent Colors
  static const accentGreen = Color(0xFF10b981);
  static const accentYellow = Color(0xFFfbbf24);
  static const accentRed = Color(0xFFef4444);

  // Neutral Colors
  static const background = Color(0xFFf5f5f5);
  static const cardBackground = Colors.white;
  static const textPrimary = Color(0xFF1f2937);
  static const textSecondary = Color(0xFF6b7280);
  static const divider = Color(0xFFe5e7eb);

  // Dark Mode Colors
  static const darkBackground = Color(0xFF111827);
  static const darkCard = Color(0xFF1f2937);
  static const darkTextPrimary = Color(0xFFf9fafb);
  static const darkTextSecondary = Color(0xFF9ca3af);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primaryBrown, secondaryBrown],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}