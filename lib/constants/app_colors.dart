import 'package:flutter/material.dart';

/// App Color Palette - Tailored for Dweep Diary with Sky Blue & White Theme
class AppColors {
  // Primary Brand Colors (Sky Blue & White)
  static const Color primary = Color(0xFF0099E6);       // Vibrant Sky Blue
  static const Color primaryDark = Color(0xFF0077B6);   // Deep Ocean Blue
  static const Color primaryLight = Color(0xFFE1F5FE);  // Soft Sky Tint
  static const Color accent = Color(0xFF00B4D8);        // Tropical Cyan

  // Neutral Colors (Light Theme)
  static const Color background = Color(0xFFF8FAFC);    // Crisp light background
  static const Color surface = Colors.white;            // Card and container surface
  static const Color textPrimary = Color(0xFF1E293B);   // Slate Dark for Malayalam readability
  static const Color textSecondary = Color(0xFF64748B); // Muted subtext
  static const Color divider = Color(0xFFE2E8F0);       // Subtle borders

  // News Category Tag Colors
  static const Color tagRed = Color(0xFFEF4444);        // Breaking / Politics / Alerts
  static const Color tagGreen = Color(0xFF10B981);      // Sports / Health
  static const Color tagOrange = Color(0xFFF59E0B);     // Feature / Stories
  static const Color tagBlue = Color(0xFF3B82F6);       // Regional / News

  // Dark Theme Support
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
}
