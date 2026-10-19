/// 通用 API 响应模型
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? code;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.code,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromData) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? fromData(json['data']) : null,
      code: json['code'],
    );
  }
}

/// 分页响应
class PageResult<T> {
  final int total;
  final List<T> items;

  PageResult({
    required this.total,
    required this.items,
  });

  factory PageResult.fromJson(Map<String, dynamic> json, T Function(dynamic) fromData) {
    return PageResult<T>(
      total: json['total'] ?? 0,
      items: (json['data'] as List?)
              ?.map((e) => fromData(e))
              .toList() ??
          [],
    );
  }
}

/// 基础状态信息
class BaseStatus {
  final String status;
  final String message;

  BaseStatus({
    required this.status,
    required this.message,
  });

  factory BaseStatus.fromJson(Map<String, dynamic> json) {
    return BaseStatus(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

/// 错误响应
class ApiError {
  final int code;
  final String message;
  final String? details;

  ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? 0,
      message: json['message'] ?? 'Unknown error',
      details: json['details'],
    );
  }
}
