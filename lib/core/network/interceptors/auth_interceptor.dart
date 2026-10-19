import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:onepanel_mobile/core/config/app_config.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/data/models/server_info.dart';

/// 1Panel 认证拦截器
/// 使用 API Key + Timestamp 生成 MD5 Token
class AuthInterceptor extends Interceptor {
  final ServerService serverService;

  AuthInterceptor(this.serverService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final server = serverService.currentServer;
    if (server != null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final token = _generateToken(server.apiKey, timestamp);

      options.headers['1Panel-Token'] = token;
      options.headers['1Panel-Timestamp'] = timestamp.toString();

      LoggerService.info('Auth', 'Token generated for ${server.name}');
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
    LoggerService.debug('Request', '
${options.method} ${options.uri}
Headers: ${options.headers}
Data: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LoggerService.debug('Response', '
Status: ${response.statusCode}
Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerService.error('Error', '
${err.type}: ${err.message}
${err.response?.data}');
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
        final message = json['message'] ?? 'Unknown error';
        handler.next(
          response,
        );
        return;
      }
    }
    handler.next(response);
  }
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  final int retryCount;

  RetryInterceptor({this.retryCount = AppConfig.retryCount});

  final Map<String, int> _retryMap = {};

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final key = '${err.requestOptions.method}:${err.requestOptions.path}';
    final currentRetry = _retryMap[key] ?? 0;

    if (currentRetry < retryCount && _shouldRetry(err)) {
      _retryMap[key] = currentRetry + 1;
      LoggerService.info('Retry', 'Retrying $key (${currentRetry + 1}/$retryCount)');

      handler.resolve(
        err.requestOptions.fetch()
          ..then((value) {
            _retryMap.remove(key);
          }),
      );
    } else {
      _retryMap.remove(key);
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}
