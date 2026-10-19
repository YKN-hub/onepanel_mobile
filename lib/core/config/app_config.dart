/// 应用全局配置
class AppConfig {
  static const String appName = '1Panel Client';
  static const String version = '0.1.0';
  static const int buildNumber = 1;

  /// API 基础路径
  static const String apiPrefix = '/api/v1';
  static const String apiV2Prefix = '/api/v2';

  /// 请求超时（秒）
  static const int connectTimeout = 15;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 15;

  /// 自动重试次数
  static const int retryCount = 2;

  /// 监控刷新间隔（秒）
  static const int monitorRefreshInterval = 5;

  /// 页面分页大小
  static const int pageSize = 20;

  /// 文件列表分页大小
  static const int filePageSize = 50;

  /// 日志最大条数
  static const int maxLogEntries = 1000;

  /// 终端最大行数
  static const int terminalMaxLines = 10000;

  /// 是否调试模式
  static bool get isDebug {
    // 在 Flutter 中通过 const bool.fromEnvironment 判断
    return const bool.fromEnvironment('dart.vm.product') == false;
  }
}
