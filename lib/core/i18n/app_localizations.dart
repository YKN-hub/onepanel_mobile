import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// 应用本地化
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final List<Locale> supportedLocales = [
    const Locale('zh', 'CN'),
    const Locale('en', 'US'),
  ];

  late Map<String, String> _localizedValues;

  Future<bool> load() async {
    final localeName = locale.languageCode;
    _localizedValues = _getLocalizedValues(localeName);
    return true;
  }

  Map<String, String> _getLocalizedValues(String locale) {
    switch (locale) {
      case 'zh':
        return {
          'appName': '1Panel Client',
          'dashboard': '仪表盘',
          'containers': '容器',
          'websites': '网站',
          'databases': '数据库',
          'files': '文件',
          'monitor': '监控',
          'settings': '设置',
          'servers': '服务器',
          'addServer': '添加服务器',
          'editServer': '编辑服务器',
          'serverName': '服务器名称',
          'baseUrl': '基础URL',
          'apiKey': 'API密钥',
          'username': '用户名',
          'password': '密码',
          'notes': '备注',
          'useSSL': '使用SSL',
          'skipSSLVerify': '跳过SSL验证',
          'testConnection': '测试连接',
          'save': '保存',
          'cancel': '取消',
          'delete': '删除',
          'edit': '编辑',
          'search': '搜索',
          'refresh': '刷新',
          'running': '运行中',
          'stopped': '已停止',
          'paused': '已暂停',
          'exited': '已退出',
          'start': '启动',
          'stop': '停止',
          'restart': '重启',
          'pause': '暂停',
          'resume': '恢复',
          'deleteConfirm': '确定要删除吗？',
          'connectionSuccess': '连接成功',
          'connectionFailed': '连接失败',
          'error': '错误',
          'noData': '暂无数据',
          'loading': '加载中...',
          'cpuUsage': 'CPU使用率',
          'memoryUsage': '内存使用率',
          'diskUsage': '磁盘使用率',
          'network': '网络',
          'systemInfo': '系统信息',
          'version': '版本',
          'os': '操作系统',
          'arch': '架构',
          'uptime': '运行时间',
          'totalWebsites': '网站总数',
          'totalDatabases': '数据库总数',
          'totalContainers': '容器总数',
          'totalApps': '应用总数',
          'createFolder': '新建文件夹',
          'createFile': '新建文件',
          'rename': '重命名',
          'view': '查看',
          'open': '打开',
          'newFolder': '新建文件夹',
          'newFile': '新建文件',
          'fileSize': '文件大小',
          'lastModified': '最后修改',
          'restartSystem': '重启系统',
          'shutdownSystem': '关机',
          'confirm': '确认',
        };
      default:
        return {
          'appName': '1Panel Client',
          'dashboard': 'Dashboard',
          'containers': 'Containers',
          'websites': 'Websites',
          'databases': 'Databases',
          'files': 'Files',
          'monitor': 'Monitor',
          'settings': 'Settings',
          'servers': 'Servers',
          'addServer': 'Add Server',
          'editServer': 'Edit Server',
          'serverName': 'Server Name',
          'baseUrl': 'Base URL',
          'apiKey': 'API Key',
          'username': 'Username',
          'password': 'Password',
          'notes': 'Notes',
          'useSSL': 'Use SSL',
          'skipSSLVerify': 'Skip SSL Verify',
          'testConnection': 'Test Connection',
          'save': 'Save',
          'cancel': 'Cancel',
          'delete': 'Delete',
          'edit': 'Edit',
          'search': 'Search',
          'refresh': 'Refresh',
          'running': 'Running',
          'stopped': 'Stopped',
          'paused': 'Paused',
          'exited': 'Exited',
          'start': 'Start',
          'stop': 'Stop',
          'restart': 'Restart',
          'pause': 'Pause',
          'resume': 'Resume',
          'deleteConfirm': 'Are you sure?',
          'connectionSuccess': 'Connection successful',
          'connectionFailed': 'Connection failed',
          'error': 'Error',
          'noData': 'No data',
          'loading': 'Loading...',
          'cpuUsage': 'CPU Usage',
          'memoryUsage': 'Memory Usage',
          'diskUsage': 'Disk Usage',
          'network': 'Network',
          'systemInfo': 'System Info',
          'version': 'Version',
          'os': 'OS',
          'arch': 'Architecture',
          'uptime': 'Uptime',
          'totalWebsites': 'Total Websites',
          'totalDatabases': 'Total Databases',
          'totalContainers': 'Total Containers',
          'totalApps': 'Total Apps',
          'createFolder': 'New Folder',
          'createFile': 'New File',
          'rename': 'Rename',
          'view': 'View',
          'open': 'Open',
          'newFolder': 'New Folder',
          'newFile': 'New File',
          'fileSize': 'File Size',
          'lastModified': 'Last Modified',
          'restartSystem': 'Restart System',
          'shutdownSystem': 'Shutdown System',
          'confirm': 'Confirm',
        };
    }
  }

  String tr(String key) {
    return _localizedValues[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
