/// 应用信息
class AppInfo {
  final int id;
  final String key;
  final String name;
  final String? version;
  final String? status;
  final String? type;
  final String? category;
  final String? author;
  final String? description;
  final String? logo;
  final String? homepage;
  final String? repoUrl;
  final String? params;
  final String? ports;
  final String? env;
  final String? volumes;
  final String? networks;
  final String? command;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppInfo({
    required this.id,
    required this.key,
    required this.name,
    this.version,
    this.status,
    this.type,
    this.category,
    this.author,
    this.description,
    this.logo,
    this.homepage,
    this.repoUrl,
    this.params,
    this.ports,
    this.env,
    this.volumes,
    this.networks,
    this.command,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      version: json['version'],
      status: json['status'],
      type: json['type'],
      category: json['category'],
      author: json['author'],
      description: json['description'],
      logo: json['logo'],
      homepage: json['homepage'],
      repoUrl: json['repoUrl'],
      params: json['params'],
      ports: json['ports'],
      env: json['env'],
      volumes: json['volumes'],
      networks: json['networks'],
      command: json['command'],
      image: json['image'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'name': name,
    'version': version,
    'status': status,
    'type': type,
    'category': category,
    'author': author,
    'description': description,
    'logo': logo,
    'homepage': homepage,
    'repoUrl': repoUrl,
    'params': params,
    'ports': ports,
    'env': env,
    'volumes': volumes,
    'networks': networks,
    'command': command,
    'image': image,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  bool get isRunning => status == 'Running';
  bool get isStopped => status == 'Stopped';
}
