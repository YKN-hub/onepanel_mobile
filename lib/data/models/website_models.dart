/// 网站信息
class WebsiteInfo {
  final int id;
  final String name;
  final String domain;
  final String? primaryDomain;
  final String? remark;
  final String? status;
  final String? type;
  final String? appType;
  final String? runtimeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? days;
  final String? expirationDate;
  final bool? https;
  final bool? proxy;
  final String? waf;

  WebsiteInfo({
    required this.id,
    required this.name,
    required this.domain,
    this.primaryDomain,
    this.remark,
    this.status,
    this.type,
    this.appType,
    this.runtimeId,
    this.createdAt,
    this.updatedAt,
    this.days,
    this.expirationDate,
    this.https,
    this.proxy,
    this.waf,
  });

  factory WebsiteInfo.fromJson(Map<String, dynamic> json) {
    return WebsiteInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      domain: json['domain'] ?? '',
      primaryDomain: json['primaryDomain'],
      remark: json['remark'],
      status: json['status'],
      type: json['type'],
      appType: json['appType'],
      runtimeId: json['runtimeId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      days: json['days'],
      expirationDate: json['expirationDate'],
      https: json['https'],
      proxy: json['proxy'],
      waf: json['waf'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'domain': domain,
    'primaryDomain': primaryDomain,
    'remark': remark,
    'status': status,
    'type': type,
    'appType': appType,
    'runtimeId': runtimeId,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'days': days,
    'expirationDate': expirationDate,
    'https': https,
    'proxy': proxy,
    'waf': waf,
  };

  bool get isRunning => status == 'Running';
  bool get isStopped => status == 'Stopped';
}

/// 网站详情
class WebsiteDetail extends WebsiteInfo {
  final String? docDir;
  final String? appDir;
  final String? runScript;
  final String? runCommand;
  final String? port;
  final List<WebsiteDomain>? domains;
  final List<WebsiteSSL>? ssl;
  final WebsiteConfig? config;
  final WebsiteProxy? proxyConfig;

  WebsiteDetail({
    required super.id,
    required super.name,
    required super.domain,
    super.primaryDomain,
    super.remark,
    super.status,
    super.type,
    super.appType,
    super.runtimeId,
    super.createdAt,
    super.updatedAt,
    super.days,
    super.expirationDate,
    super.https,
    super.proxy,
    super.waf,
    this.docDir,
    this.appDir,
    this.runScript,
    this.runCommand,
    this.port,
    this.domains,
    this.ssl,
    this.config,
    this.proxyConfig,
  });

  factory WebsiteDetail.fromJson(Map<String, dynamic> json) {
    final base = WebsiteInfo.fromJson(json);
    return WebsiteDetail(
      id: base.id,
      name: base.name,
      domain: base.domain,
      primaryDomain: base.primaryDomain,
      remark: base.remark,
      status: base.status,
      type: base.type,
      appType: base.appType,
      runtimeId: base.runtimeId,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      days: base.days,
      expirationDate: base.expirationDate,
      https: base.https,
      proxy: base.proxy,
      waf: base.waf,
      docDir: json['docDir'],
      appDir: json['appDir'],
      runScript: json['runScript'],
      runCommand: json['runCommand'],
      port: json['port'],
      domains: (json['domains'] as List?)
          ?.map((e) => WebsiteDomain.fromJson(e))
          .toList(),
      ssl: (json['ssl'] as List?)
          ?.map((e) => WebsiteSSL.fromJson(e))
          .toList(),
      config: json['config'] != null
          ? WebsiteConfig.fromJson(json['config'])
          : null,
      proxyConfig: json['proxyConfig'] != null
          ? WebsiteProxy.fromJson(json['proxyConfig'])
          : null,
    );
  }
}

/// 网站域名
class WebsiteDomain {
  final String domain;
  final String? primary;
  final DateTime? createdAt;

  WebsiteDomain({
    required this.domain,
    this.primary,
    this.createdAt,
  });

  factory WebsiteDomain.fromJson(Map<String, dynamic> json) {
    return WebsiteDomain(
      domain: json['domain'] ?? '',
      primary: json['primary'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}

/// 网站 SSL
class WebsiteSSL {
  final int id;
  final String? provider;
  final String? type;
  final String? cert;
  final String? key;
  final String? startDate;
  final String? endDate;
  final bool? autoRenew;

  WebsiteSSL({
    required this.id,
    this.provider,
    this.type,
    this.cert,
    this.key,
    this.startDate,
    this.endDate,
    this.autoRenew,
  });

  factory WebsiteSSL.fromJson(Map<String, dynamic> json) {
    return WebsiteSSL(
      id: json['id'] ?? 0,
      provider: json['provider'],
      type: json['type'],
      cert: json['cert'],
      key: json['key'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      autoRenew: json['autoRenew'],
    );
  }
}

/// 网站配置
class WebsiteConfig {
  final String? runPath;
  final String? runCommand;
  final String? runScript;
  final int? runTimeout;
  final bool? runAsDaemon;
  final Map<String, String>? env;

  WebsiteConfig({
    this.runPath,
    this.runCommand,
    this.runScript,
    this.runTimeout,
    this.runAsDaemon,
    this.env,
  });

  factory WebsiteConfig.fromJson(Map<String, dynamic> json) {
    return WebsiteConfig(
      runPath: json['runPath'],
      runCommand: json['runCommand'],
      runScript: json['runScript'],
      runTimeout: json['runTimeout'],
      runAsDaemon: json['runAsDaemon'],
      env: (json['env'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v.toString())),
    );
  }
}

/// 网站代理配置
class WebsiteProxy {
  final String? proxyType;
  final String? upstreamUrl;
  final String? hostName;
  final bool? disableCache;
  final int? cacheTime;
  final String? rewrite;

  WebsiteProxy({
    this.proxyType,
    this.upstreamUrl,
    this.hostName,
    this.disableCache,
    this.cacheTime,
    this.rewrite,
  });

  factory WebsiteProxy.fromJson(Map<String, dynamic> json) {
    return WebsiteProxy(
      proxyType: json['proxyType'],
      upstreamUrl: json['upstreamUrl'],
      hostName: json['hostName'],
      disableCache: json['disableCache'],
      cacheTime: json['cacheTime'],
      rewrite: json['rewrite'],
    );
  }
}
