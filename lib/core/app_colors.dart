import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primaryGreen = Color(0xFF2A9C2A);
  static const secondaryGreen = Color(0xFF1F7A1F);
  static const lightGreen = Color(0xFF8FD98F);

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
    colors: [primaryGreen, secondaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const deepGreen    = Color(0xFF244A19);         // gradient end

  static const greenGradient = LinearGradient(
    colors: [primaryGreen, deepGreen],                   // 0% → 100%
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
// ─────────────────────────────────────────────────────────────────────
}