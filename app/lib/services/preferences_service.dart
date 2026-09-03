import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_settings.dart';
import '../theme/app_theme.dart';

class PreferencesService {
  static final PreferencesService instance = PreferencesService._internal();
  PreferencesService._internal();

  static const _keyFontSize = 'ati_font_size';
  static const _keyFontFamily = 'ati_font_family';
  static const _keyThemeStyle = 'ati_theme_style';
  static const _keyLineHeight = 'ati_line_height';

  Future<ReadingSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble(_keyFontSize) ?? 17.0;
    final fontFamily = prefs.getString(_keyFontFamily) ?? 'Georgia';
    final themeIndex = prefs.getInt(_keyThemeStyle) ?? 0;
    final lineHeight = prefs.getDouble(_keyLineHeight) ?? 1.65;

    final themeStyle = (themeIndex >= 0 && themeIndex < AppThemeStyle.values.length)
        ? AppThemeStyle.values[themeIndex]
        : AppThemeStyle.warmParchment;

    return ReadingSettings(
      fontSize: fontSize,
      fontFamily: fontFamily,
      themeStyle: themeStyle,
      lineHeight: lineHeight,
    );
  }

  Future<void> saveSettings(ReadingSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, settings.fontSize);
    await prefs.setString(_keyFontFamily, settings.fontFamily);
    await prefs.setInt(_keyThemeStyle, settings.themeStyle.index);
    await prefs.setDouble(_keyLineHeight, settings.lineHeight);
  }
}
