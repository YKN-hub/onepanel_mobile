/// 操作日志
class OperationLog {
  final int id;
  final String? user;
  final String? action;
  final String? module;
  final String? message;
  final String? status;
  final String? ip;
  final DateTime? createdAt;

  OperationLog({
    required this.id,
    this.user,
    this.action,
    this.module,
    this.message,
    this.status,
    this.ip,
    this.createdAt,
  });

  factory OperationLog.fromJson(Map<String, dynamic> json) {
    return OperationLog(
      id: json['id'] ?? 0,
      user: json['user'],
      action: json['action'],
      module: json['module'],
      message: json['message'],
      status: json['status'],
      ip: json['ip'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'Success':
        return '成功';
      case 'Failed':
        return '失败';
      default:
        return status ?? '';
    }
  }
}

/// 登录日志
class LoginLog {
  final int id;
  final String? user;
  final String? ip;
  final String? status;
  final String? message;
  final DateTime? createdAt;

  LoginLog({
    required this.id,
    this.user,
    this.ip,
    this.status,
    this.message,
    this.createdAt,
  });

  factory LoginLog.fromJson(Map<String, dynamic> json) {
    return LoginLog(
      id: json['id'] ?? 0,
      user: json['user'],
      ip: json['ip'],
      status: json['status'],
      message: json['message'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'Success':
        return '成功';
      case 'Failed':
        return '失败';
      default:
        return status ?? '';
    }
  }
}
