/// 仪表盘概览
class DashboardOverview {
  final int totalWebsites;
  final int totalDatabases;
  final int totalContainers;
  final int totalApps;
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final int uptime;
  final int loadAverage;
  final int networkIn;
  final int networkOut;

  DashboardOverview({
    required this.totalWebsites,
    required this.totalDatabases,
    required this.totalContainers,
    required this.totalApps,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.uptime,
    required this.loadAverage,
    required this.networkIn,
    required this.networkOut,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalWebsites: json['totalWebsites'] ?? 0,
      totalDatabases: json['totalDatabases'] ?? 0,
      totalContainers: json['totalContainers'] ?? 0,
      totalApps: json['totalApps'] ?? 0,
      cpuUsage: (json['cpuUsage'] ?? 0).toDouble(),
      memoryUsage: (json['memoryUsage'] ?? 0).toDouble(),
      diskUsage: (json['diskUsage'] ?? 0).toDouble(),
      uptime: json['uptime'] ?? 0,
      loadAverage: json['loadAverage'] ?? 0,
      networkIn: json['networkIn'] ?? 0,
      networkOut: json['networkOut'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalWebsites': totalWebsites,
    'totalDatabases': totalDatabases,
    'totalContainers': totalContainers,
    'totalApps': totalApps,
    'cpuUsage': cpuUsage,
    'memoryUsage': memoryUsage,
    'diskUsage': diskUsage,
    'uptime': uptime,
    'loadAverage': loadAverage,
    'networkIn': networkIn,
    'networkOut': networkOut,
  };
}

/// 基础信息
class BaseInfo {
  final String os;
  final String platform;
  final String kernel;
  final String arch;
  final String cpuModel;
  final int cpuCores;
  final double memoryTotal;
  final double memoryUsed;
  final double diskTotal;
  final double diskUsed;
  final String panelVersion;
  final String apiVersion;
  final String serverTime;

  BaseInfo({
    required this.os,
    required this.platform,
    required this.kernel,
    required this.arch,
    required this.cpuModel,
    required this.cpuCores,
    required this.memoryTotal,
    required this.memoryUsed,
    required this.diskTotal,
    required this.diskUsed,
    required this.panelVersion,
    required this.apiVersion,
    required this.serverTime,
  });

  factory BaseInfo.fromJson(Map<String, dynamic> json) {
    return BaseInfo(
      os: json['os'] ?? '',
      platform: json['platform'] ?? '',
      kernel: json['kernel'] ?? '',
      arch: json['arch'] ?? '',
      cpuModel: json['cpuModel'] ?? '',
      cpuCores: json['cpuCores'] ?? 0,
      memoryTotal: (json['memoryTotal'] ?? 0).toDouble(),
      memoryUsed: (json['memoryUsed'] ?? 0).toDouble(),
      diskTotal: (json['diskTotal'] ?? 0).toDouble(),
      diskUsed: (json['diskUsed'] ?? 0).toDouble(),
      panelVersion: json['panelVersion'] ?? '',
      apiVersion: json['apiVersion'] ?? '',
      serverTime: json['serverTime'] ?? '',
    );
  }
}

/// 资源监控
class ResourceMonitor {
  final List<double> cpuUsage;
  final List<double> memoryUsage;
  final List<double> diskUsage;
  final List<int> networkIn;
  final List<int> networkOut;
  final List<int> loadAverage;
  final DateTime? lastUpdated;

  ResourceMonitor({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.networkIn,
    required this.networkOut,
    required this.loadAverage,
    this.lastUpdated,
  });

  factory ResourceMonitor.fromJson(Map<String, dynamic> json) {
    return ResourceMonitor(
      cpuUsage: (json['cpuUsage'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      memoryUsage: (json['memoryUsage'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      diskUsage: (json['diskUsage'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      networkIn: (json['networkIn'] as List?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      networkOut: (json['networkOut'] as List?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      loadAverage: (json['loadAverage'] as List?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }
}
