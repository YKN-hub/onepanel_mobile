import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用级设置（目前只有界面语言），用 SharedPreferences 持久化。
class AppSettings extends ChangeNotifier {
  AppSettings._(this._localeCode);

  static const String _key = 'app_locale_code';

  String _localeCode;
  /// 'system' | 'zh' | 'en'
  String get localeCode => _localeCode;

  /// null 表示跟随系统语言。
  Locale? get locale =>
      (_localeCode == 'system' || _localeCode.isEmpty) ? null : Locale(_localeCode);

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings._(prefs.getString(_key) ?? 'system');
  }

  Future<void> setLocale(String code) async {
    if (code == _localeCode) return;
    _localeCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
    notifyListeners();
  }
}
