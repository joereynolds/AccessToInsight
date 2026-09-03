import 'package:flutter/material.dart';
import 'app_colors.dart';

enum AppThemeStyle {
  warmParchment,
  insight,
  monochrome,
  darkTemple,
}

class AppTheme {
  static ThemeData getTheme(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.darkTemple:
        return _buildDarkTempleTheme();
      case AppThemeStyle.insight:
        return _buildInsightTheme();
      case AppThemeStyle.monochrome:
        return _buildMonochromeTheme();
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
        primary: AppColors.terracotta,
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

  static ThemeData _buildInsightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.insightBg,
      colorScheme: ColorScheme.light(
        primary: AppColors.insightLink,
        secondary: AppColors.insightLink,
        surface: AppColors.insightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.insightText,
        outline: AppColors.insightBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.insightBg,
        foregroundColor: AppColors.insightText,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.insightText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.insightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.insightBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.insightSurface,
        indicatorColor: AppColors.insightLink.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.insightLink,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.insightTextMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.insightLink);
          }
          return const IconThemeData(color: AppColors.insightTextMuted);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.insightBorder,
        thickness: 1,
      ),
    );
  }

  static ThemeData _buildMonochromeTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.monoBg,
      colorScheme: ColorScheme.light(
        primary: AppColors.monoAccent,
        secondary: AppColors.monoAccent,
        surface: AppColors.monoSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.monoText,
        outline: AppColors.monoBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.monoBg,
        foregroundColor: AppColors.monoText,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.monoText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.monoCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.monoBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.monoSurface,
        indicatorColor: AppColors.monoBorder,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.monoText,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.monoTextMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.monoText);
          }
          return const IconThemeData(color: AppColors.monoTextMuted);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.monoBorder,
        thickness: 1,
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
