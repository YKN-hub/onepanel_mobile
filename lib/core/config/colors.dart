import 'package:flutter/material.dart';

/// 应用颜色
class AppColors {
  static const Color primary = Color(0xFF007AFF);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color danger = Color(0xFFFF3B30);
  static const Color info = Color(0xFF5AC8FA);
  
  /// 状态颜色
  static Color get running => success;
  static Color get stopped => danger;
  static Color get paused => warning;
  static Color get exited => Colors.grey;
}

/// 应用图标
class AppIcons {
  static const String _prefix = 'assets/icons/';
  
  static String get app => '$_prefix/app.png';
  static String get server => '$_prefix/server.png';
  static String get dashboard => '$_prefix/dashboard.png';
}
