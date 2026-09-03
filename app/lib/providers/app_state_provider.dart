import 'package:flutter/material.dart';
import '../models/reading_settings.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';

class AppStateProvider extends ChangeNotifier {
  ReadingSettings _settings = const ReadingSettings();
  bool _isDbReady = false;
  String _dbStatusMessage = 'Loading...';
  double _dbProgress = 0.0;

  ReadingSettings get settings => _settings;
  bool get isDbReady => _isDbReady;
  String get dbStatusMessage => _dbStatusMessage;
  double get dbProgress => _dbProgress;

  AppStateProvider() {
    _init();
  }

  Future<void> _init() async {
    _settings = await PreferencesService.instance.loadSettings();
    notifyListeners();

    DatabaseService.instance.initStatusNotifier.addListener(() {
      _dbStatusMessage = DatabaseService.instance.initStatusNotifier.value;
      notifyListeners();
    });

    DatabaseService.instance.initProgressNotifier.addListener(() {
      _dbProgress = DatabaseService.instance.initProgressNotifier.value;
      notifyListeners();
    });

    try {
      await DatabaseService.instance.database;
      _isDbReady = true;
      _dbStatusMessage = 'Ready';
      _dbProgress = 1.0;
    } catch (e) {
      _dbStatusMessage = 'Database Error: $e';
    }
    notifyListeners();
  }

  Future<void> updateFontSize(double size) async {
    _settings = _settings.copyWith(fontSize: size.clamp(12.0, 32.0));
    notifyListeners();
    await PreferencesService.instance.saveSettings(_settings);
  }

  Future<void> updateFontFamily(String family) async {
    _settings = _settings.copyWith(fontFamily: family);
    notifyListeners();
    await PreferencesService.instance.saveSettings(_settings);
  }

  Future<void> updateThemeStyle(AppThemeStyle style) async {
    _settings = _settings.copyWith(themeStyle: style);
    notifyListeners();
    await PreferencesService.instance.saveSettings(_settings);
  }

  Future<void> updateLineHeight(double height) async {
    _settings = _settings.copyWith(lineHeight: height.clamp(1.2, 2.5));
    notifyListeners();
    await PreferencesService.instance.saveSettings(_settings);
  }
}
