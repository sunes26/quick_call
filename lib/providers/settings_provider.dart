import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_call/utils/sort_options.dart';

/// 앱 설정 프로바이더
class SettingsProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keySortOption = 'sort_option';
  static const String _keyAutoBackup = 'auto_backup';
  static const String _keyShowLastCalled = 'show_last_called';

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // 설정 값들
  ThemeMode _themeMode = ThemeMode.light; // 🆕 항상 라이트 모드로 고정 (ThemeMode.system → ThemeMode.light)
  SortOption _sortOption = SortOption.custom;
  bool _autoBackupEnabled = true;
  bool _showLastCalled = true;

  // Getters
  ThemeMode get themeMode => _themeMode;
  SortOption get sortOption => _sortOption;
  bool get autoBackupEnabled => _autoBackupEnabled;
  bool get showLastCalled => _showLastCalled;
  bool get isInitialized => _isInitialized;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// 초기화
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('설정 초기화 오류: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// 설정 불러오기
  Future<void> _loadSettings() async {
    try {
      // 테마 모드
      final themeModeIndex = _prefs.getInt(_keyThemeMode);
      if (themeModeIndex != null) {
        _themeMode = ThemeMode.values[themeModeIndex];
      }

      // 정렬 옵션
      final sortOptionIndex = _prefs.getInt(_keySortOption);
      if (sortOptionIndex != null) {
        _sortOption = SortOption.values[sortOptionIndex];
      }

      // 자동 백업
      _autoBackupEnabled = _prefs.getBool(_keyAutoBackup) ?? true;

      // 최근 통화 표시
      _showLastCalled = _prefs.getBool(_keyShowLastCalled) ?? true;

      debugPrint('설정 불러오기 완료');
    } catch (e) {
      debugPrint('설정 불러오기 오류: $e');
    }
  }

  /// 테마 모드 변경
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      await _prefs.setInt(_keyThemeMode, mode.index);
      notifyListeners();
      debugPrint('테마 모드 변경: $mode');
    } catch (e) {
      debugPrint('테마 모드 변경 오류: $e');
    }
  }

  /// 다크 모드 토글
  Future<void> toggleDarkMode() async {
    final newMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// 정렬 옵션 변경
  Future<void> setSortOption(SortOption option) async {
    try {
      _sortOption = option;
      await _prefs.setInt(_keySortOption, option.index);
      notifyListeners();
      debugPrint('정렬 옵션 변경: ${option.displayName}');
    } catch (e) {
      debugPrint('정렬 옵션 변경 오류: $e');
    }
  }

  /// 자동 백업 설정 변경
  Future<void> setAutoBackup(bool enabled) async {
    try {
      _autoBackupEnabled = enabled;
      await _prefs.setBool(_keyAutoBackup, enabled);
      notifyListeners();
      debugPrint('자동 백업 설정: $enabled');
    } catch (e) {
      debugPrint('자동 백업 설정 오류: $e');
    }
  }

  /// 최근 통화 표시 설정 변경
  Future<void> setShowLastCalled(bool show) async {
    try {
      _showLastCalled = show;
      await _prefs.setBool(_keyShowLastCalled, show);
      notifyListeners();
      debugPrint('최근 통화 표시 설정: $show');
    } catch (e) {
      debugPrint('최근 통화 표시 설정 오류: $e');
    }
  }

  /// 모든 설정 초기화
  Future<void> resetAllSettings() async {
    try {
      await _prefs.clear();
      _themeMode = ThemeMode.light; // 🆕 초기화 시에도 라이트 모드로 (ThemeMode.system → ThemeMode.light)
      _sortOption = SortOption.custom;
      _autoBackupEnabled = true;
      _showLastCalled = true;
      notifyListeners();
      debugPrint('모든 설정 초기화 완료');
    } catch (e) {
      debugPrint('설정 초기화 오류: $e');
    }
  }

  /// 설정 내보내기 (백업용)
  Map<String, dynamic> exportSettings() {
    return {
      'theme_mode': _themeMode.index,
      'sort_option': _sortOption.index,
      'auto_backup': _autoBackupEnabled,
      'show_last_called': _showLastCalled,
    };
  }

  /// 설정 가져오기 (복원용)
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      if (settings.containsKey('theme_mode')) {
        final index = settings['theme_mode'] as int;
        await setThemeMode(ThemeMode.values[index]);
      }

      if (settings.containsKey('sort_option')) {
        final index = settings['sort_option'] as int;
        await setSortOption(SortOption.values[index]);
      }

      if (settings.containsKey('auto_backup')) {
        await setAutoBackup(settings['auto_backup'] as bool);
      }

      if (settings.containsKey('show_last_called')) {
        await setShowLastCalled(settings['show_last_called'] as bool);
      }

      debugPrint('설정 가져오기 완료');
    } catch (e) {
      debugPrint('설정 가져오기 오류: $e');
    }
  }
}