/// 数据库信息
class DatabaseInfo {
  final int id;
  final String name;
  final String type;
  final String? version;
  final String? status;
  final String? username;
  final String? password;
  final String? host;
  final int? port;
  final String? remark;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? days;
  final String? expirationDate;
  final String? from;
  final String? containerName;
  final int? databaseId;

  DatabaseInfo({
    required this.id,
    required this.name,
    required this.type,
    this.version,
    this.status,
    this.username,
    this.password,
    this.host,
    this.port,
    this.remark,
    this.createdAt,
    this.updatedAt,
    this.days,
    this.expirationDate,
    this.from,
    this.containerName,
    this.databaseId,
  });

  factory DatabaseInfo.fromJson(Map<String, dynamic> json) {
    return DatabaseInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      version: json['version'],
      status: json['status'],
      username: json['username'],
      password: json['password'],
      host: json['host'],
      port: json['port'],
      remark: json['remark'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      days: json['days'],
      expirationDate: json['expirationDate'],
      from: json['from'],
      containerName: json['containerName'],
      databaseId: json['databaseId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'version': version,
    'status': status,
    'username': username,
    'password': password,
    'host': host,
    'port': port,
    'remark': remark,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'days': days,
    'expirationDate': expirationDate,
    'from': from,
    'containerName': containerName,
    'databaseId': databaseId,
  };

  bool get isRunning => status == 'Running';
  bool get isStopped => status == 'Stopped';
  String get typeLabel {
    switch (type) {
      case 'mysql':
        return 'MySQL';
      case 'mariadb':
        return 'MariaDB';
      case 'postgresql':
        return 'PostgreSQL';
      case 'redis':
        return 'Redis';
      case 'mongodb':
        return 'MongoDB';
      default:
        return type;
    }
  }
}

/// 数据库访问信息
class DatabaseAccess {
  final String? connectionString;
  final String? url;
  final String? host;
  final int? port;
  final String? username;
  final String? password;
  final String? database;
  final String? driver;

  DatabaseAccess({
    this.connectionString,
    this.url,
    this.host,
    this.port,
    this.username,
    this.password,
    this.database,
    this.driver,
  });

  factory DatabaseAccess.fromJson(Map<String, dynamic> json) {
    return DatabaseAccess(
      connectionString: json['connectionString'],
      url: json['url'],
      host: json['host'],
      port: json['port'],
      username: json['username'],
      password: json['password'],
      database: json['database'],
      driver: json['driver'],
    );
  }
}
