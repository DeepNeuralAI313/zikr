// Core theme configuration
import 'package:flutter/material.dart';

// Dark theme color palette (exact match from design)
const Color darkBackground = Color(0xFF1A1A1A);
const Color darkSurface = Color(0xFF2A2A2A);

// Light theme color palette
const Color lightBackground = Color(0xFFF5F5F5);
const Color lightSurface = Color(0xFFFFFFFF);
const Color lightText = Color(0xFF1A1A1A);

// Vibrant accent colors (exact from design spec)
const Color accentYellow = Color(0xFFFFD43B);
const Color accentPink = Color(0xFFFF4F8B);
const Color accentGreen = Color(0xFF00D27F);
const Color accentCyan = Color(0xFF00CFFF);
const Color accentPurple = Color(0xFFA16EFF);
const Color accentGrey = Color(0xFFCFCFCF);
const Color accentGreyDark = Color(0xFF666666);

// Color arrays for rotation
const List<Color> rotatingColors = [
  accentYellow,
  accentPink,
  accentGreen,
  accentCyan,
  accentPurple,
];

// Gradient colors
class AppGradients {
  static const quranGradient = LinearGradient(
    colors: [accentGreen, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const zikrGradient = LinearGradient(
    colors: [accentPink, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const logoGradient = LinearGradient(
    colors: [accentYellow, accentPink, accentCyan, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final bgColor = isDark ? darkBackground : lightBackground;
  final surfaceColor = isDark ? darkSurface : lightSurface;
  final textColor = isDark ? Colors.white : lightText;
  final secondaryTextColor = isDark ? accentGrey : accentGreyDark;
  
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: bgColor,
    primaryColor: accentYellow,
    colorScheme: isDark
        ? ColorScheme.dark(
            primary: accentYellow,
            secondary: accentCyan,
            surface: surfaceColor,
            background: bgColor,
            onPrimary: Colors.black,
            onSecondary: Colors.white,
            onSurface: textColor,
            onBackground: textColor,
          )
        : ColorScheme.light(
            primary: accentYellow,
            secondary: accentCyan,
            surface: surfaceColor,
            background: bgColor,
            onPrimary: Colors.black,
            onSecondary: Colors.white,
            onSurface: textColor,
            onBackground: textColor,
          ),
    
    // AppBar theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: textColor,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: 0.5,
      ),
    ),
    
    // Card theme
    cardTheme: CardThemeData(
      elevation: 8,
      color: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        backgroundColor: accentYellow,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    
    // Text theme
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: 0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.3,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white70 : lightText.withOpacity(0.7),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: secondaryTextColor,
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: secondaryTextColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: accentCyan, width: 2),
      ),
      filled: true,
      fillColor: surfaceColor,
      labelStyle: TextStyle(color: secondaryTextColor),
      hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.7)),
    ),
    
    // Bottom navigation bar theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: accentYellow,
      unselectedItemColor: secondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}