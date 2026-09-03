import 'package:flutter/material.dart';
import 'app_colors.dart';

enum AppThemeStyle {
  warmParchment,
  lightIvory,
  darkTemple,
}

class AppTheme {
  static ThemeData getTheme(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.darkTemple:
        return _buildDarkTempleTheme();
      case AppThemeStyle.lightIvory:
        return _buildLightIvoryTheme();
      case AppThemeStyle.warmParchment:
        return _buildWarmParchmentTheme();
    }
  }

  static ThemeData _buildWarmParchmentTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.parchmentBg,
      colorScheme: ColorScheme.light(
        primary: AppColors.saffron,
        secondary: AppColors.terracotta,
        surface: AppColors.parchmentSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.parchmentText,
        outline: AppColors.parchmentBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.parchmentBg,
        foregroundColor: AppColors.parchmentText,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.parchmentText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.parchmentCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.parchmentBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.parchmentSurface,
        indicatorColor: AppColors.saffronLight.withValues(alpha: 0.5),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.terracotta,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.parchmentTextMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.terracotta);
          }
          return const IconThemeData(color: AppColors.parchmentTextMuted);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.parchmentBorder,
        thickness: 1,
      ),
    );
  }

  static ThemeData _buildLightIvoryTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: ColorScheme.light(
        primary: AppColors.saffron,
        secondary: AppColors.terracotta,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightText,
        outline: AppColors.lightBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBg,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
    );
  }

  static ThemeData _buildDarkTempleTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: ColorScheme.dark(
        primary: AppColors.saffronMuted,
        secondary: AppColors.terracotta,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.darkBg,
        onSecondary: Colors.white,
        onSurface: AppColors.darkText,
        outline: AppColors.darkBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.saffronDark.withValues(alpha: 0.4),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.saffronMuted,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.saffronMuted);
          }
          return const IconThemeData(color: AppColors.darkTextMuted);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
    );
  }
}
