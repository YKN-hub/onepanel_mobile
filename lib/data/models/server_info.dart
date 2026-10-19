/// 服务器信息模型
class ServerInfo {
  final String id;
  final String name;
  final String baseUrl;
  final String apiKey;
  final String? username;
  final String? password;
  final bool useSSL;
  final bool skipSSLVerify;
  final DateTime createdAt;
  final DateTime? lastConnectedAt;
  final String? notes;

  ServerInfo({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    this.username,
    this.password,
    this.useSSL = false,
    this.skipSSLVerify = false,
    required this.createdAt,
    this.lastConnectedAt,
    this.notes,
  });

  factory ServerInfo.fromMap(Map<String, dynamic> map) {
    return ServerInfo(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      baseUrl: map['baseUrl'] ?? '',
      apiKey: map['apiKey'] ?? '',
      username: map['username'],
      password: map['password'],
      useSSL: map['useSSL'] ?? false,
      skipSSLVerify: map['skipSSLVerify'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      lastConnectedAt: map['lastConnectedAt'] != null
          ? DateTime.parse(map['lastConnectedAt'])
          : null,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'baseUrl': baseUrl,
      'apiKey': apiKey,
      'username': username,
      'password': password,
      'useSSL': useSSL,
      'skipSSLVerify': skipSSLVerify,
      'createdAt': createdAt.toIso8601String(),
      'lastConnectedAt': lastConnectedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  /// 获取完整的 API 基础 URL
  String get apiBaseUrl {
    var url = baseUrl.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }
}
