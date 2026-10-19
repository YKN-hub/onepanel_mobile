/// 计划任务信息
class CronjobInfo {
  final int id;
  final String name;
  final String type;
  final String? spec;
  final String? content;
  final String? command;
  final String? script;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastTime;
  final DateTime? nextTime;
  final String? remark;

  CronjobInfo({
    required this.id,
    required this.name,
    required this.type,
    this.spec,
    this.content,
    this.command,
    this.script,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.lastTime,
    this.nextTime,
    this.remark,
  });

  factory CronjobInfo.fromJson(Map<String, dynamic> json) {
    return CronjobInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      spec: json['spec'],
      content: json['content'],
      command: json['command'],
      script: json['script'],
      status: json['status'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      lastTime: json['lastTime'] != null
          ? DateTime.parse(json['lastTime'])
          : null,
      nextTime: json['nextTime'] != null
          ? DateTime.parse(json['nextTime'])
          : null,
      remark: json['remark'],
    );
  }

  bool get isEnable => status == 'Enable';
  String get typeLabel {
    switch (type) {
      case 'shell':
        return 'Shell 脚本';
      case 'curl':
        return 'Curl 请求';
      case 'backup':
        return '备份';
      case 'log':
        return '日志切割';
      default:
        return type;
    }
  }
}
