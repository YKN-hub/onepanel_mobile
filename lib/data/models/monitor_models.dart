/// 监控数据
class MonitorData {
  final List<double> cpu;
  final List<double> memory;
  final List<double> swap;
  final List<double> disk;
  final List<int> networkIn;
  final List<int> networkOut;
  final List<double> load;
  final List<int> time;

  MonitorData({
    required this.cpu,
    required this.memory,
    required this.swap,
    required this.disk,
    required this.networkIn,
    required this.networkOut,
    required this.load,
    required this.time,
  });

  factory MonitorData.fromJson(Map<String, dynamic> json) {
    return MonitorData(
      cpu: (json['cpu'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
          [],
      memory: (json['memory'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
          [],
      swap: (json['swap'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
          [],
      disk: (json['disk'] as List?)
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
      load: (json['load'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
          [],
      time: (json['time'] as List?)
          ?.map((e) => e as int)
          .toList() ??
          [],
    );
  }
}

/// 监控配置
class MonitorConfig {
  final int? interval;
  final int? retention;
  final bool? enable;
  final List<String>? metrics;

  MonitorConfig({
    this.interval,
    this.retention,
    this.enable,
    this.metrics,
  });

  factory MonitorConfig.fromJson(Map<String, dynamic> json) {
    return MonitorConfig(
      interval: json['interval'],
      retention: json['retention'],
      enable: json['enable'],
      metrics: (json['metrics'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'interval': interval,
    'retention': retention,
    'enable': enable,
    'metrics': metrics,
  };
}
