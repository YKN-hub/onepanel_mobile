/// SSL 信息
class SSLInfo {
  final int id;
  final int? websiteId;
  final String? provider;
  final String? type;
  final String? cert;
  final String? key;
  final String? startDate;
  final String? endDate;
  final bool? autoRenew;
  final String? domain;
  final String? remark;
  final DateTime? createdAt;

  SSLInfo({
    required this.id,
    this.websiteId,
    this.provider,
    this.type,
    this.cert,
    this.key,
    this.startDate,
    this.endDate,
    this.autoRenew,
    this.domain,
    this.remark,
    this.createdAt,
  });

  factory SSLInfo.fromJson(Map<String, dynamic> json) {
    return SSLInfo(
      id: json['id'] ?? 0,
      websiteId: json['websiteId'],
      provider: json['provider'],
      type: json['type'],
      cert: json['cert'],
      key: json['key'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      autoRenew: json['autoRenew'],
      domain: json['domain'],
      remark: json['remark'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  /// 获取剩余天数
  int? get daysRemaining {
    if (endDate == null) return null;
    final end = DateTime.parse(endDate!);
    final now = DateTime.now();
    return end.difference(now).inDays;
  }

  /// 获取状态
  String get status {
    if (autoRenew == true) return '自动续期';
    return '手动';
  }
}
