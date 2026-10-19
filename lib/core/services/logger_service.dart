import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepanel_mobile/core/config/app_config.dart';
import 'package:onepanel_mobile/data/models/server_info.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

/// 统一日志服务
class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 3,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static final _logKey = 'onepanel_logs';

  static Future<void> init() async {
    // 初始化日志存储
  }

  static void debug(String tag, String message) {
    if (AppConfig.isDebug) {
      _logger.d('[$tag] $message');
    }
    _saveLog('DEBUG', tag, message);
  }

  static void info(String tag, String message) {
    _logger.i('[$tag] $message');
    _saveLog('INFO', tag, message);
  }

  static void warning(String tag, String message) {
    _logger.w('[$tag] $message');
    _saveLog('WARN', tag, message);
  }

  static void error(String tag, String message) {
    _logger.e('[$tag] $message');
    _saveLog('ERROR', tag, message);
  }

  static void _saveLog(String level, String tag, String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logs = prefs.getStringList(_logKey) ?? [];
      final logEntry = {
        'time': DateTime.now().toIso8601String(),
        'level': level,
        'tag': tag,
        'message': message,
      };
      logs.add(jsonEncode(logEntry));
      if (logs.length > AppConfig.maxLogEntries) {
        logs.removeAt(0);
      }
      await prefs.setStringList(_logKey, logs);
    } catch (e) {
      // 日志保存失败不影响主流程
    }
  }

  static Future<List<Map<String, dynamic>>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList(_logKey) ?? [];
    return logs.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logKey);
  }
}
