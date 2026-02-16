import 'package:flutter/material.dart';

final ThemeData unguLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  // Seed color lebih soft & spiritual (lavender-purple mix)
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF7C5ABF), // Primary ungu vibrant tapi calming
    brightness: Brightness.light,
    primary: const Color(0xFF7C5ABF), // Untuk icon, button utama, selected nav
    onPrimary: Colors.white,
    primaryContainer: const Color(
      0xFFE8DEFF,
    ), // Variant lebih soft untuk card bg
    onPrimaryContainer: const Color(0xFF2A0E5A),

    secondary: const Color(
      0xFF9F7EE6,
    ), // Aksen lavender untuk secondary elements
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFF0E5FF),

    tertiary: const Color(
      0xFFB8975A,
    ), // Gold soft untuk highlight (ayat, tanggal, icon spesial)
    onTertiary: Colors.black87,

    surface: const Color(0xFFF8F5FC), // Background sangat lembut
    onSurface: const Color(0xFF1E0F3A), // Text utama deep purple
    surfaceVariant: const Color(0xFFEDE7F6), // Untuk card atau variant surface
    onSurfaceVariant: const Color(0xFF4A3A6A),

    outline: const Color(0xFF7C5ABF).withOpacity(0.4),
    shadow: const Color(0xFF7C5ABF).withOpacity(0.12),
  ),

  scaffoldBackgroundColor: const Color(0xFFF8F5FC), // Super soft lavender-white
  // Card lebih modern: elevation rendah, border radius besar, shadow subtle ungu
  cardTheme: CardThemeData(
    elevation: 1, // Halus, bukan flat total
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    color: Colors.white.withOpacity(0.98),
    surfaceTintColor: Colors.transparent,
    shadowColor: const Color(0xFF7C5ABF).withOpacity(0.15),
    clipBehavior: Clip.antiAlias,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: Color(0xFF2A0E5A),
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    iconTheme: IconThemeData(color: Color(0xFF7C5ABF)),
  ),

  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2A0E5A),
      letterSpacing: -0.5,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFF2A0E5A),
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF2A0E5A)),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    labelLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF7C5ABF),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  ),

  iconTheme: const IconThemeData(color: Color(0xFF7C5ABF), size: 28),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFF7C5ABF),
    unselectedItemColor: const Color(0xFF9F7EE6).withOpacity(0.7),
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);
