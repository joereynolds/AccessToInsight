import '../theme/app_theme.dart';

class ReadingSettings {
  final double fontSize;
  final String fontFamily;
  final AppThemeStyle themeStyle;
  final double lineHeight;

  const ReadingSettings({
    this.fontSize = 14.0,
    this.fontFamily = 'Georgia',
    this.themeStyle = AppThemeStyle.warmParchment,
    this.lineHeight = 1.65,
  });

  ReadingSettings copyWith({
    double? fontSize,
    String? fontFamily,
    AppThemeStyle? themeStyle,
    double? lineHeight,
  }) {
    return ReadingSettings(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      themeStyle: themeStyle ?? this.themeStyle,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }
}
