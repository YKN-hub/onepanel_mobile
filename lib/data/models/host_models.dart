/// 主机信息
class HostInfo {
  final String hostname;
  final String os;
  final String platform;
  final String platformFamily;
  final String platformVersion;
  final String kernelVersion;
  final String kernelArch;
  final String virtualizationSystem;
  final String virtualizationRole;
  final String? hostId;
  final String? bootTime;
  final int? uptime;
  final int? procs;
  final double? load1;
  final double? load5;
  final double? load15;
  final int? memTotal;
  final int? memUsed;
  final int? memFree;
  final int? swapTotal;
  final int? swapUsed;
  final int? swapFree;

  HostInfo({
    required this.hostname,
    required this.os,
    required this.platform,
    required this.platformFamily,
    required this.platformVersion,
    required this.kernelVersion,
    required this.kernelArch,
    required this.virtualizationSystem,
    required this.virtualizationRole,
    this.hostId,
    this.bootTime,
    this.uptime,
    this.procs,
    this.load1,
    this.load5,
    this.load15,
    this.memTotal,
    this.memUsed,
    this.memFree,
    this.swapTotal,
    this.swapUsed,
    this.swapFree,
  });

  factory HostInfo.fromJson(Map<String, dynamic> json) {
    return HostInfo(
      hostname: json['hostname'] ?? '',
      os: json['os'] ?? '',
      platform: json['platform'] ?? '',
      platformFamily: json['platformFamily'] ?? '',
      platformVersion: json['platformVersion'] ?? '',
      kernelVersion: json['kernelVersion'] ?? '',
      kernelArch: json['kernelArch'] ?? '',
      virtualizationSystem: json['virtualizationSystem'] ?? '',
      virtualizationRole: json['virtualizationRole'] ?? '',
      hostId: json['hostId'],
      bootTime: json['bootTime'],
      uptime: json['uptime'],
      procs: json['procs'],
      load1: (json['load1'] as num?)?.toDouble(),
      load5: (json['load5'] as num?)?.toDouble(),
      load15: (json['load15'] as num?)?.toDouble(),
      memTotal: json['memTotal'],
      memUsed: json['memUsed'],
      memFree: json['memFree'],
      swapTotal: json['swapTotal'],
      swapUsed: json['swapUsed'],
      swapFree: json['swapFree'],
    );
  }

  /// 获取内存使用率
  double get memoryUsage {
    if (memTotal == null || memTotal == 0) return 0;
    return (memUsed! / memTotal! * 100);
  }

  /// 获取交换分区使用率
  double get swapUsage {
    if (swapTotal == null || swapTotal == 0) return 0;
    return (swapUsed! / swapTotal! * 100);
  }

  /// 获取运行时间显示
  String get uptimeDisplay {
    if (uptime == null) return '';
    final days = uptime! ~/ 86400;
    final hours = (uptime! % 86400) ~/ 3600;
    final minutes = (uptime! % 3600) ~/ 60;
    if (days > 0) return '$days 天 $hours 小时';
    if (hours > 0) return '$hours 小时 $minutes 分钟';
    return '$minutes 分钟';
  }
}

/// 磁盘信息
class DiskInfo {
  final String path;
  final String fstype;
  final int total;
  final int free;
  final int used;
  final double inodesTotal;
  final double inodesUsed;
  final double inodesFree;
  final double inodesUsagePercent;
  final String? device;

  DiskInfo({
    required this.path,
    required this.fstype,
    required this.total,
    required this.free,
    required this.used,
    required this.inodesTotal,
    required this.inodesUsed,
    required this.inodesFree,
    required this.inodesUsagePercent,
    this.device,
  });

  factory DiskInfo.fromJson(Map<String, dynamic> json) {
    return DiskInfo(
      path: json['path'] ?? '',
      fstype: json['fstype'] ?? '',
      total: json['total'] ?? 0,
      free: json['free'] ?? 0,
      used: json['used'] ?? 0,
      inodesTotal: (json['inodesTotal'] as num?)?.toDouble() ?? 0,
      inodesUsed: (json['inodesUsed'] as num?)?.toDouble() ?? 0,
      inodesFree: (json['inodesFree'] as num?)?.toDouble() ?? 0,
      inodesUsagePercent: (json['inodesUsagePercent'] as num?)?.toDouble() ?? 0,
      device: json['device'],
    );
  }

  /// 获取使用率
  double get usagePercent {
    if (total == 0) return 0;
    return (used / total * 100);
  }

  /// 获取总大小显示
  String get totalDisplay => _formatSize(total);
  String get freeDisplay => _formatSize(free);
  String get usedDisplay => _formatSize(used);

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} GB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} TB';
  }
}

/// 进程信息
class ProcessInfo {
  final int pid;
  final String name;
  final String? command;
  final int? cpuPercent;
  final int? memory;
  final double? memoryPercent;
  final String? status;
  final String? user;
  final int? threads;
  final DateTime? startTime;

  ProcessInfo({
    required this.pid,
    required this.name,
    this.command,
    this.cpuPercent,
    this.memory,
    this.memoryPercent,
    this.status,
    this.user,
    this.threads,
    this.startTime,
  });

  factory ProcessInfo.fromJson(Map<String, dynamic> json) {
    return ProcessInfo(
      pid: json['pid'] ?? 0,
      name: json['name'] ?? '',
      command: json['command'],
      cpuPercent: json['cpuPercent'],
      memory: json['memory'],
      memoryPercent: (json['memoryPercent'] as num?)?.toDouble(),
      status: json['status'],
      user: json['user'],
      threads: json['threads'],
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
    );
  }
}
