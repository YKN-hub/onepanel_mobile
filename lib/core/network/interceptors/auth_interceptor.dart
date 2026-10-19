import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:onepanel_mobile/core/config/app_config.dart';
import 'package:onepanel_mobile/core/network/api_url.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';

/// 1Panel 认证拦截器
/// 使用 API Key + Timestamp 生成 MD5 Token
class AuthInterceptor extends Interceptor {
  final ServerService serverService;

  AuthInterceptor(this.serverService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final server = serverService.currentServer;
    final base = resolveApiBaseUrl(server);
    if (base != null) {
      options.baseUrl = base;
    }
    if (server != null && server.apiKey.isNotEmpty) {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final token = _generateToken(server.apiKey, timestamp);

      options.headers['1Panel-Token'] = token;
      options.headers['1Panel-Timestamp'] = timestamp.toString();

      LoggerService.debug('Auth', 'Token generated for ${server.name}');
    }

    handler.next(options);
  }

  /// 生成 1Panel Token
  /// MD5("1panel" + apiKey + timestamp)
  String _generateToken(String apiKey, int timestamp) {
    final content = '1panel$apiKey$timestamp';
    final bytes = utf8.encode(content);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}

/// 日志拦截器
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    LoggerService.debug(
      'Request',
      '${options.method} ${options.uri}\n'
      'Headers: ${options.headers}\n'
      'Data: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LoggerService.debug(
      'Response',
      'Status: ${response.statusCode}\n'
      'Data: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerService.error(
      'Error',
      '${err.type}: ${err.message}\n'
      '${err.response?.data}',
    );
    handler.next(err);
  }
}

/// 业务响应拦截器
class BusinessResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 1Panel 的 API 响应格式: { success: true, message: "", data: {} }
    if (response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      if (json.containsKey('success') && json['success'] == false) {
        final message = (json['message'] ?? 'Unknown error').toString();
        LoggerService.warning('BusinessError', message);
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            message: message,
          ),
          false,
        );
        return;
      }
    }
    handler.next(response);
  }
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int retryCount;
  final Duration retryDelay;

  RetryInterceptor(
    this._dio, {
    this.retryCount = AppConfig.retryCount,
    this.retryDelay = const Duration(milliseconds: 500),
  });

  final Map<String, int> _retryMap = {};

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final key = '${err.requestOptions.method}:${err.requestOptions.path}';
    final currentRetry = _retryMap[key] ?? 0;

    if (currentRetry < retryCount && _shouldRetry(err)) {
      _retryMap[key] = currentRetry + 1;
      LoggerService.info('Retry', 'Retrying $key (${currentRetry + 1}/$retryCount)');
      await Future<void>.delayed(retryDelay);

      try {
        final response = await _dio.fetch<dynamic>(err.requestOptions);
        _retryMap.remove(key);
        handler.resolve(response);
      } on DioException catch (retryError) {
        handler.next(retryError);
      }
      return;
    }

    _retryMap.remove(key);
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}
