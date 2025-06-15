// lib/core/theme/app_theme.dart
// Material Design 3 theme that matches the React Native app's visual design

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color constants
  static const Color _primaryLight = Color(0xFF2196F3); // Blue
  static const Color _primaryContainerLight = Color(0xFFD1E4FF);
  static const Color _secondaryLight = Color(0xFF4CAF50); // Green
  static const Color _secondaryContainerLight = Color(0xFFDCF3DD);
  static const Color _tertiaryLight = Color(0xFFFF9800); // Orange
  static const Color _tertiaryContainerLight = Color(0xFFFFE0B2);
  static const Color _errorLight = Color(0xFFF44336); // Red
  static const Color _backgroundLight = Color(0xFFFAFAFA);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _onPrimaryLight = Color(0xFFFFFFFF);
  static const Color _onSecondaryLight = Color(0xFFFFFFFF);
  static const Color _onTertiaryLight = Color(0xFF000000);
  static const Color _onBackgroundLight = Color(0xFF000000);
  static const Color _onSurfaceLight = Color(0xFF000000);
  static const Color _onErrorLight = Color(0xFFFFFFFF);

  static const Color _primaryDark = Color(0xFF90CAF9); // Light Blue
  static const Color _primaryContainerDark = Color(0xFF0D47A1);
  static const Color _secondaryDark = Color(0xFF81C784); // Light Green
  static const Color _secondaryContainerDark = Color(0xFF1B5E20);
  static const Color _tertiaryDark = Color(0xFFFFB74D); // Light Orange
  static const Color _tertiaryContainerDark = Color(0xFFE65100);
  static const Color _errorDark = Color(0xFFE57373); // Light Red
  static const Color _backgroundDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _onPrimaryDark = Color(0xFF000000);
  static const Color _onSecondaryDark = Color(0xFF000000);
  static const Color _onTertiaryDark = Color(0xFF000000);
  static const Color _onBackgroundDark = Color(0xFFFFFFFF);
  static const Color _onSurfaceDark = Color(0xFFFFFFFF);
  static const Color _onErrorDark = Color(0xFF000000);

  // Category colors - matching React Native app
  static const Map<int, Color> categoryColors = {
    1: Color(0xFF4CAF50), // Family - Green
    2: Color(0xFFFF9800), // Pets - Orange
    3: Color(0xFF2196F3), // Social - Blue
    4: Color(0xFF9C27B0), // Education - Purple
    5: Color(0xFF607D8B), // Career - Blue Grey
    6: Color(0xFF00BCD4), // Travel - Cyan
    7: Color(0xFFE91E63), // Health - Pink
    8: Color(0xFF795548), // Home - Brown
    9: Color(0xFF8BC34A), // Garden - Light Green
    10: Color(0xFFFFC107), // Food - Amber
    11: Color(0xFF3F51B5), // Laundry - Indigo
    12: Color(0xFF009688), // Finance - Teal
    13: Color(0xFFF44336), // Transport - Red
  };

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _primaryLight,
      onPrimary: _onPrimaryLight,
      primaryContainer: _primaryContainerLight,
      onPrimaryContainer: _primaryLight,
      secondary: _secondaryLight,
      onSecondary: _onSecondaryLight,
      secondaryContainer: _secondaryContainerLight,
      onSecondaryContainer: _secondaryLight,
      tertiary: _tertiaryLight,
      onTertiary: _onTertiaryLight,
      tertiaryContainer: _tertiaryContainerLight,
      onTertiaryContainer: _tertiaryLight,
      error: _errorLight,
      onError: _onErrorLight,
      background: _backgroundLight,
      onBackground: _onBackgroundLight,
      surface: _surfaceLight,
      onSurface: _onSurfaceLight,
      surfaceVariant: Color(0xFFE0E0E0),
      onSurfaceVariant: Color(0xFF757575),
      outline: Color(0xFFBDBDBD),
      shadow: Color(0x40000000),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryLight,
      foregroundColor: _onPrimaryLight,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surfaceLight,
      selectedItemColor: _primaryLight,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _onPrimaryLight,
        backgroundColor: _primaryLight,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryLight,
        side: const BorderSide(color: _primaryLight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: _surfaceLight,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _errorLight, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _errorLight, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
      hintStyle: TextStyle(color: Colors.grey[400]),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryLight,
      foregroundColor: _onPrimaryLight,
      elevation: 4,
    ),
    dividerTheme: const DividerThemeData(
      thickness: 1,
      color: Color(0xFFE0E0E0),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryLight;
        }
        return Colors.grey[300]!;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryLight;
        }
        return Colors.grey[300]!;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryLight;
        }
        return Colors.grey[300]!;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryLight.withOpacity(0.5);
        }
        return Colors.grey[300]!;
      }),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _surfaceLight,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey[900],
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: _primaryLight,
      unselectedLabelColor: Colors.grey,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: _primaryLight,
          width: 2,
        ),
      ),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryDark,
      onPrimary: _onPrimaryDark,
      primaryContainer: _primaryContainerDark,
      onPrimaryContainer: _primaryDark,
      secondary: _secondaryDark,
      onSecondary: _onSecondaryDark,
      secondaryContainer: _secondaryContainerDark,
      onSecondaryContainer: _secondaryDark,
      tertiary: _tertiaryDark,
      onTertiary: _onTertiaryDark,
      tertiaryContainer: _tertiaryContainerDark,
      onTertiaryContainer: _tertiaryDark,
      error: _errorDark,
      onError: _onErrorDark,
      background: _backgroundDark,
      onBackground: _onBackgroundDark,
      surface: _surfaceDark,
      onSurface: _onSurfaceDark,
      surfaceVariant: Color(0xFF424242),
      onSurfaceVariant: Color(0xFFBDBDBD),
      outline: Color(0xFF757575),
      shadow: Color(0x40000000),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: _surfaceDark,
      foregroundColor: _onSurfaceDark,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surfaceDark,
      selectedItemColor: _primaryDark,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _onPrimaryDark,
        backgroundColor: _primaryDark,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryDark,
        side: const BorderSide(color: _primaryDark),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: _surfaceDark,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _errorDark, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _errorDark, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
      hintStyle: TextStyle(color: Colors.grey[600]),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryDark,
      foregroundColor: _onPrimaryDark,
      elevation: 4,
    ),
    dividerTheme: const DividerThemeData(
      thickness: 1,
      color: Color(0xFF424242),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryDark;
        }
        return Colors.grey[700]!;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryDark;
        }
        return Colors.grey[700]!;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryDark;
        }
        return Colors.grey[700]!;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryDark.withOpacity(0.5);
        }
        return Colors.grey[700]!;
      }),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _surfaceDark,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF424242),
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: _primaryDark,
      unselectedLabelColor: Colors.grey,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: _primaryDark,
          width: 2,
        ),
      ),
    ),
  );

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1800;

  // Helper methods for responsive design
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static double getResponsiveFontSize(BuildContext context, double size) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    if (deviceWidth < mobileBreakpoint) {
      return size;
    } else if (deviceWidth < tabletBreakpoint) {
      return size * 1.1;
    } else if (deviceWidth < desktopBreakpoint) {
      return size * 1.2;
    } else {
      return size * 1.3;
    }
  }

  // Helper method to get category color
  static Color getCategoryColor(int categoryId) {
    return categoryColors[categoryId] ?? _primaryLight;
  }

  // Helper method to get category color for dark theme
  static Color getCategoryColorDark(int categoryId) {
    // Return a lighter version of the category color for dark theme
    final color = categoryColors[categoryId] ?? _primaryDark;
    return Color.lerp(color, Colors.white, 0.2)!;
  }
}
