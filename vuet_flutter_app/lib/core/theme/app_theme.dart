// lib/core/theme/app_theme.dart
// Theme configuration that mirrors the React Native app's design system

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Defines the app's theme configuration, including colors, typography, and component styles
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  // Color constants from React Native app
  static const Color _primaryColor = Color(0xFF6200EE); // Main purple
  static const Color _primaryVariantColor = Color(0xFF3700B3); // Darker purple
  static const Color _secondaryColor = Color(0xFF03DAC6); // Teal
  static const Color _secondaryVariantColor = Color(0xFF018786); // Darker teal
  static const Color _errorColor = Color(0xFFB00020); // Error red
  
  // Neutral colors
  static const Color _blackColor = Color(0xFF000000);
  static const Color _almostBlackColor = Color(0xFF121212);
  static const Color _darkGreyColor = Color(0xFF333333);
  static const Color _greyColor = Color(0xFFAAAAAA);
  static const Color _lightGreyColor = Color(0xFFE5E5E5);
  static const Color _whiteColor = Color(0xFFFFFFFF);
  
  // Functional colors
  static const Color _successColor = Color(0xFF4CAF50); // Green
  static const Color _warningColor = Color(0xFFFFC107); // Amber
  static const Color _infoColor = Color(0xFF2196F3); // Blue
  
  // Category colors (matching React Native category colors)
  static const Map<String, Color> categoryColors = {
    'PETS': Color(0xFF8BC34A),
    'SOCIAL_INTERESTS': Color(0xFFFF9800),
    'EDUCATION': Color(0xFF2196F3),
    'CAREER': Color(0xFF9C27B0),
    'TRAVEL': Color(0xFF009688),
    'HEALTH_BEAUTY': Color(0xFFE91E63),
    'HOME': Color(0xFF795548),
    'GARDEN': Color(0xFF4CAF50),
    'FOOD': Color(0xFFFF5722),
    'LAUNDRY': Color(0xFF607D8B),
    'FINANCE': Color(0xFF673AB7),
    'TRANSPORT': Color(0xFF3F51B5),
    'FAMILY': Color(0xFFE91E63),
  };

  // Typography - Using Poppins as the main font to match React Native app
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.poppins(
        textStyle: base.displayLarge,
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.poppins(
        textStyle: base.displayMedium,
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.poppins(
        textStyle: base.displaySmall,
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.poppins(
        textStyle: base.headlineLarge,
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: base.headlineMedium,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.poppins(
        textStyle: base.headlineSmall,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: base.titleLarge,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.poppins(
        textStyle: base.titleMedium,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: GoogleFonts.poppins(
        textStyle: base.titleSmall,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.poppins(
        textStyle: base.bodyLarge,
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: GoogleFonts.poppins(
        textStyle: base.bodyMedium,
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: GoogleFonts.poppins(
        textStyle: base.bodySmall,
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: GoogleFonts.poppins(
        textStyle: base.labelLarge,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: GoogleFonts.poppins(
        textStyle: base.labelMedium,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.poppins(
        textStyle: base.labelSmall,
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Spacing constants
  static final double spacing_2xs = 2.w;
  static final double spacing_xs = 4.w;
  static final double spacing_sm = 8.w;
  static final double spacing_md = 16.w;
  static final double spacing_lg = 24.w;
  static final double spacing_xl = 32.w;
  static final double spacing_2xl = 48.w;
  static final double spacing_3xl = 64.w;

  // Border radius constants
  static final double radius_xs = 4.r;
  static final double radius_sm = 8.r;
  static final double radius_md = 12.r;
  static final double radius_lg = 16.r;
  static final double radius_xl = 24.r;
  static final double radius_2xl = 32.r;

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: _primaryColor,
      onPrimary: _whiteColor,
      primaryContainer: _primaryColor.withOpacity(0.1),
      onPrimaryContainer: _primaryColor,
      secondary: _secondaryColor,
      onSecondary: _blackColor,
      secondaryContainer: _secondaryColor.withOpacity(0.1),
      onSecondaryContainer: _secondaryColor,
      error: _errorColor,
      onError: _whiteColor,
      errorContainer: _errorColor.withOpacity(0.1),
      onErrorContainer: _errorColor,
      background: _whiteColor,
      onBackground: _blackColor,
      surface: _whiteColor,
      onSurface: _blackColor,
      surfaceVariant: _lightGreyColor,
      onSurfaceVariant: _darkGreyColor,
      outline: _greyColor,
      shadow: _blackColor.withOpacity(0.1),
      inverseSurface: _almostBlackColor,
      onInverseSurface: _whiteColor,
      inversePrimary: _secondaryColor,
      surfaceTint: _primaryColor,
    ),
    textTheme: _buildTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: _whiteColor,
      foregroundColor: _blackColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: _blackColor,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _whiteColor,
      selectedItemColor: _primaryColor,
      unselectedItemColor: _greyColor,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: _whiteColor,
        textStyle: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing_lg,
          vertical: spacing_md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius_md),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryColor,
        side: BorderSide(color: _primaryColor, width: 1.5),
        textStyle: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing_lg,
          vertical: spacing_md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius_md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        textStyle: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing_md,
          vertical: spacing_sm,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightGreyColor.withOpacity(0.3),
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing_md,
        vertical: spacing_md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide(color: _errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide(color: _errorColor, width: 1.5),
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: _darkGreyColor,
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: _greyColor,
      ),
      errorStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: _errorColor,
      ),
    ),
    cardTheme: CardTheme(
      color: _whiteColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_md),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: spacing_md,
        vertical: spacing_sm,
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _whiteColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_lg),
      ),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: _blackColor,
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: _blackColor,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _almostBlackColor,
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: _whiteColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_md),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: DividerThemeData(
      color: _lightGreyColor,
      thickness: 1,
      space: spacing_md,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryColor;
        }
        return _lightGreyColor;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_xs),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryColor;
        }
        return _greyColor;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryColor;
        }
        return _whiteColor;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryColor.withOpacity(0.5);
        }
        return _greyColor.withOpacity(0.5);
      }),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: _primaryColor,
      unselectedLabelColor: _greyColor,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
      ),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: _whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_xl),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _lightGreyColor,
      disabledColor: _lightGreyColor.withOpacity(0.5),
      selectedColor: _primaryColor,
      secondarySelectedColor: _secondaryColor,
      padding: EdgeInsets.symmetric(
        horizontal: spacing_md,
        vertical: spacing_xs,
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: _blackColor,
      ),
      secondaryLabelStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: _blackColor,
      ),
      brightness: Brightness.light,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing_md,
        vertical: spacing_sm,
      ),
      dense: false,
      horizontalTitleGap: spacing_md,
      minLeadingWidth: 32.w,
      minVerticalPadding: spacing_sm,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryColor,
      onPrimary: _whiteColor,
      primaryContainer: _primaryColor.withOpacity(0.2),
      onPrimaryContainer: _primaryColor.withOpacity(0.8),
      secondary: _secondaryColor,
      onSecondary: _blackColor,
      secondaryContainer: _secondaryColor.withOpacity(0.2),
      onSecondaryContainer: _secondaryColor.withOpacity(0.8),
      error: _errorColor,
      onError: _whiteColor,
      errorContainer: _errorColor.withOpacity(0.2),
      onErrorContainer: _errorColor.withOpacity(0.8),
      background: _almostBlackColor,
      onBackground: _whiteColor,
      surface: _almostBlackColor,
      onSurface: _whiteColor,
      surfaceVariant: _darkGreyColor,
      onSurfaceVariant: _lightGreyColor,
      outline: _greyColor,
      shadow: _blackColor.withOpacity(0.3),
      inverseSurface: _whiteColor,
      onInverseSurface: _blackColor,
      inversePrimary: _primaryColor,
      surfaceTint: _primaryColor,
    ),
    textTheme: _buildTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: _almostBlackColor,
      foregroundColor: _whiteColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: _whiteColor,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _almostBlackColor,
      selectedItemColor: _secondaryColor,
      unselectedItemColor: _greyColor,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: _whiteColor,
        textStyle: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing_lg,
          vertical: spacing_md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius_md),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryColor,
        side: BorderSide(color: _primaryColor, width: 1.5),
        textStyle: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing_lg,
          vertical: spacing_md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius_md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _secondaryColor,
        textStyle: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing_md,
          vertical: spacing_sm,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkGreyColor.withOpacity(0.3),
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing_md,
        vertical: spacing_md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide(color: _errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide(color: _errorColor, width: 1.5),
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: _lightGreyColor,
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: _greyColor,
      ),
      errorStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: _errorColor,
      ),
    ),
    cardTheme: CardTheme(
      color: _darkGreyColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_md),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: spacing_md,
        vertical: spacing_sm,
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _darkGreyColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_lg),
      ),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: _whiteColor,
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: _whiteColor,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkGreyColor,
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: _whiteColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_md),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: DividerThemeData(
      color: _darkGreyColor,
      thickness: 1,
      space: spacing_md,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryColor;
        }
        return _darkGreyColor;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_xs),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryColor;
        }
        return _greyColor;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryColor;
        }
        return _lightGreyColor;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return _primaryColor.withOpacity(0.5);
        }
        return _greyColor.withOpacity(0.5);
      }),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: _secondaryColor,
      unselectedLabelColor: _greyColor,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
      ),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: _secondaryColor, width: 2),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: _whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_xl),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _darkGreyColor,
      disabledColor: _darkGreyColor.withOpacity(0.5),
      selectedColor: _primaryColor,
      secondarySelectedColor: _secondaryColor,
      padding: EdgeInsets.symmetric(
        horizontal: spacing_md,
        vertical: spacing_xs,
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: _whiteColor,
      ),
      secondaryLabelStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: _whiteColor,
      ),
      brightness: Brightness.dark,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing_md,
        vertical: spacing_sm,
      ),
      dense: false,
      horizontalTitleGap: spacing_md,
      minLeadingWidth: 32.w,
      minVerticalPadding: spacing_sm,
    ),
  );

  // Extension method to get colors by name
  static Color getColor(String colorName, {bool isDark = false}) {
    switch (colorName) {
      case 'primary':
        return _primaryColor;
      case 'secondary':
        return _secondaryColor;
      case 'error':
        return _errorColor;
      case 'success':
        return _successColor;
      case 'warning':
        return _warningColor;
      case 'info':
        return _infoColor;
      case 'black':
        return _blackColor;
      case 'almostBlack':
        return _almostBlackColor;
      case 'darkGrey':
        return _darkGreyColor;
      case 'grey':
        return _greyColor;
      case 'lightGrey':
        return _lightGreyColor;
      case 'white':
        return _whiteColor;
      default:
        if (categoryColors.containsKey(colorName)) {
          return categoryColors[colorName]!;
        }
        return isDark ? _whiteColor : _blackColor;
    }
  }
}
