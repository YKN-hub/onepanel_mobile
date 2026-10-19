/// 容器信息
class ContainerInfo {
  final String id;
  final String name;
  final String state;
  final String status;
  final String image;
  final String? ports;
  final DateTime? created;
  final int? cpuUsage;
  final int? memoryUsage;
  final int? networkRx;
  final int? networkTx;
  final int? diskRead;
  final int? diskWrite;

  ContainerInfo({
    required this.id,
    required this.name,
    required this.state,
    required this.status,
    required this.image,
    this.ports,
    this.created,
    this.cpuUsage,
    this.memoryUsage,
    this.networkRx,
    this.networkTx,
    this.diskRead,
    this.diskWrite,
  });

  factory ContainerInfo.fromJson(Map<String, dynamic> json) {
    return ContainerInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      state: json['state'] ?? '',
      status: json['status'] ?? '',
      image: json['image'] ?? '',
      ports: json['ports'],
      created: json['created'] != null
          ? DateTime.parse(json['created'])
          : null,
      cpuUsage: json['cpuUsage'],
      memoryUsage: json['memoryUsage'],
      networkRx: json['networkRx'],
      networkTx: json['networkTx'],
      diskRead: json['diskRead'],
      diskWrite: json['diskWrite'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'state': state,
    'status': status,
    'image': image,
    'ports': ports,
    'created': created?.toIso8601String(),
    'cpuUsage': cpuUsage,
    'memoryUsage': memoryUsage,
    'networkRx': networkRx,
    'networkTx': networkTx,
    'diskRead': diskRead,
    'diskWrite': diskWrite,
  };

  bool get isRunning => state == 'running';
  bool get isPaused => state == 'paused';
  bool get isExited => state == 'exited';
  bool get isCreated => state == 'created';
}

/// 容器详情
class ContainerDetail extends ContainerInfo {
  final String? command;
  final int? pid;
  final int? restartCount;
  final bool? autoRemove;
  final List<ContainerMount>? mounts;
  final List<ContainerPort>? exposedPorts;
  final Map<String, String>? env;
  final String? logPath;
  final String? networkMode;
  final String? ipAddress;
  final String? macAddress;

  ContainerDetail({
    required super.id,
    required super.name,
    required super.state,
    required super.status,
    required super.image,
    super.ports,
    super.created,
    super.cpuUsage,
    super.memoryUsage,
    super.networkRx,
    super.networkTx,
    super.diskRead,
    super.diskWrite,
    this.command,
    this.pid,
    this.restartCount,
    this.autoRemove,
    this.mounts,
    this.exposedPorts,
    this.env,
    this.logPath,
    this.networkMode,
    this.ipAddress,
    this.macAddress,
  });

  factory ContainerDetail.fromJson(Map<String, dynamic> json) {
    final base = ContainerInfo.fromJson(json);
    return ContainerDetail(
      id: base.id,
      name: base.name,
      state: base.state,
      status: base.status,
      image: base.image,
      ports: base.ports,
      created: base.created,
      cpuUsage: base.cpuUsage,
      memoryUsage: base.memoryUsage,
      networkRx: base.networkRx,
      networkTx: base.networkTx,
      diskRead: base.diskRead,
      diskWrite: base.diskWrite,
      command: json['command'],
      pid: json['pid'],
      restartCount: json['restartCount'],
      autoRemove: json['autoRemove'],
      mounts: (json['mounts'] as List?)
          ?.map((e) => ContainerMount.fromJson(e))
          .toList(),
      exposedPorts: (json['exposedPorts'] as List?)
          ?.map((e) => ContainerPort.fromJson(e))
          .toList(),
      env: (json['env'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v.toString())),
      logPath: json['logPath'],
      networkMode: json['networkMode'],
      ipAddress: json['ipAddress'],
      macAddress: json['macAddress'],
    );
  }
}

/// 容器挂载
class ContainerMount {
  final String type;
  final String source;
  final String destination;
  final bool? readOnly;

  ContainerMount({
    required this.type,
    required this.source,
    required this.destination,
    this.readOnly,
  });

  factory ContainerMount.fromJson(Map<String, dynamic> json) {
    return ContainerMount(
      type: json['type'] ?? '',
      source: json['source'] ?? '',
      destination: json['destination'] ?? '',
      readOnly: json['readOnly'],
    );
  }
}

/// 容器端口
class ContainerPort {
  final int? privatePort;
  final int? publicPort;
  final String? type;
  final String? ip;

  ContainerPort({
    this.privatePort,
    this.publicPort,
    this.type,
    this.ip,
  });

  factory ContainerPort.fromJson(Map<String, dynamic> json) {
    return ContainerPort(
      privatePort: json['privatePort'],
      publicPort: json['publicPort'],
      type: json['type'],
      ip: json['ip'],
    );
  }
}
