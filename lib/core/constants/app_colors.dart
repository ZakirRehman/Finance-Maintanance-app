import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color luxuryGold = Color(0xFFC8A44D);
  static const Color softGold = Color(0xFFD6B86A);
  
  // Background & Surfaces
  static const Color background = Color(0xFFF8F6F1); // Cream White
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color lightBeigeAccent = Color(0xFFEFE7DA);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2C2C2C); // Very dark gray for readability
  static const Color textSecondary = Color(0xFF757575); // Medium gray
  static const Color textLight = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF2196F3);

  // Transparent / Glassmorphism
  static const Color glassmorphismBackground = Color(0x80FFFFFF); // 50% opacity white
  static const Color divider = Color(0xFFE0E0E0);
}
