import 'package:dio/dio.dart';
import 'package:onepanel_mobile/core/config/app_config.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:onepanel_mobile/core/network/interceptors/logging_interceptor.dart';
import 'package:onepanel_mobile/core/network/interceptors/business_response_interceptor.dart';
import 'package:onepanel_mobile/core/network/interceptors/retry_interceptor.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/data/models/server_info.dart';

/// Dio 客户端封装
class DioClient {
  final Dio _dio = Dio();
  final ServerService serverService;

  DioClient({required this.serverService}) {
    _initDio();
  }

  void _initDio() {
    _dio.options = BaseOptions(
      baseUrl: '',
      connectTimeout: Duration(seconds: AppConfig.connectTimeout),
      receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
      sendTimeout: Duration(seconds: AppConfig.sendTimeout),
      contentType: 'application/json',
      headers: {
        'Accept': 'application/json',
        'User-Agent': '1Panel-Client/${AppConfig.version}',
      },
    );

    // 添加拦截器
    _dio.interceptors.add(LoggingInterceptor());
    _dio.interceptors.add(AuthInterceptor(serverService));
    _dio.interceptors.add(BusinessResponseInterceptor());
    _dio.interceptors.add(RetryInterceptor());
  }

  /// 更新基础 URL
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    LoggerService.info('DioClient', 'Base URL updated: $baseUrl');
  }

  /// 更新 SSL 验证
  void updateSSLSettings(bool skipSSLVerify) {
    if (skipSSLVerify) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return null;
      };
    }
  }

  /// GET 请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// POST 请求
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PUT 请求
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE 请求
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// 文件下载
  Future<Response> download(
    String urlPath,
    savePath, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _dio.download(
      urlPath,
      savePath,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// 文件上传
  Future<Response> upload(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    void Function(int, int)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      if (data != null) ...data,
    });

    return _dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
    );
  }
}
