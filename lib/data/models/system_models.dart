/// 系统信息
class SystemInfo {
  final String? version;
  final String? goVersion;
  final String? buildTime;
  final String? commitId;
  final String? os;
  final String? arch;
  final String? database;
  final String? databaseVersion;
  final String? serverTime;
  final String? timezone;
  final int? uptime;

  SystemInfo({
    this.version,
    this.goVersion,
    this.buildTime,
    this.commitId,
    this.os,
    this.arch,
    this.database,
    this.databaseVersion,
    this.serverTime,
    this.timezone,
    this.uptime,
  });

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      version: json['version'],
      goVersion: json['goVersion'],
      buildTime: json['buildTime'],
      commitId: json['commitId'],
      os: json['os'],
      arch: json['arch'],
      database: json['database'],
      databaseVersion: json['databaseVersion'],
      serverTime: json['serverTime'],
      timezone: json['timezone'],
      uptime: json['uptime'],
    );
  }
}

/// 面板设置
class PanelSettings {
  final String? title;
  final int? port;
  final String? language;
  final String? timezone;
  final bool? allowRegister;
  final bool? autoLogin;
  final int? sessionTimeout;
  final bool? mfa;
  final String? appSecret;
  final String? appStoreUrl;
  final bool? apiEnable;
  final String? apiKey;
  final String? backupAccount;
  final String? logLevel;
  final String? theme;

  PanelSettings({
    this.title,
    this.port,
    this.language,
    this.timezone,
    this.allowRegister,
    this.autoLogin,
    this.sessionTimeout,
    this.mfa,
    this.appSecret,
    this.appStoreUrl,
    this.apiEnable,
    this.apiKey,
    this.backupAccount,
    this.logLevel,
    this.theme,
  });

  factory PanelSettings.fromJson(Map<String, dynamic> json) {
    return PanelSettings(
      title: json['title'],
      port: json['port'],
      language: json['language'],
      timezone: json['timezone'],
      allowRegister: json['allowRegister'],
      autoLogin: json['autoLogin'],
      sessionTimeout: json['sessionTimeout'],
      mfa: json['mfa'],
      appSecret: json['appSecret'],
      appStoreUrl: json['appStoreUrl'],
      apiEnable: json['apiEnable'],
      apiKey: json['apiKey'],
      backupAccount: json['backupAccount'],
      logLevel: json['logLevel'],
      theme: json['theme'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'port': port,
    'language': language,
    'timezone': timezone,
    'allowRegister': allowRegister,
    'autoLogin': autoLogin,
    'sessionTimeout': sessionTimeout,
    'mfa': mfa,
    'appSecret': appSecret,
    'appStoreUrl': appStoreUrl,
    'apiEnable': apiEnable,
    'apiKey': apiKey,
    'backupAccount': backupAccount,
    'logLevel': logLevel,
    'theme': theme,
  };
}
