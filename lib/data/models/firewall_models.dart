/// 防火墙规则
class FirewallRule {
  final int id;
  final String? name;
  final String? protocol;
  final int? port;
  final String? target;
  final String? source;
  final String? inFace;
  final String? outFace;
  final bool? enable;
  final String? remark;
  final DateTime? createdAt;

  FirewallRule({
    required this.id,
    this.name,
    this.protocol,
    this.port,
    this.target,
    this.source,
    this.inFace,
    this.outFace,
    this.enable,
    this.remark,
    this.createdAt,
  });

  factory FirewallRule.fromJson(Map<String, dynamic> json) {
    return FirewallRule(
      id: json['id'] ?? 0,
      name: json['name'],
      protocol: json['protocol'],
      port: json['port'],
      target: json['target'],
      source: json['source'],
      inFace: json['inFace'],
      outFace: json['outFace'],
      enable: json['enable'],
      remark: json['remark'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  bool get isEnable => enable == true;
  String get targetLabel {
    switch (target) {
      case 'ACCEPT':
        return '允许';
      case 'DROP':
        return '丢弃';
      case 'REJECT':
        return '拒绝';
      default:
        return target ?? '';
    }
  }
}
