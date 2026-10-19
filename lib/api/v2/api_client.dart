import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:onepanel_mobile/core/config/app_config.dart';
import 'package:onepanel_mobile/core/network/api_url.dart';
import 'package:onepanel_mobile/core/network/dio_client.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/data/models/common_models.dart';
import 'package:onepanel_mobile/data/models/dashboard_models.dart';
import 'package:onepanel_mobile/data/models/container_models.dart';
import 'package:onepanel_mobile/data/models/website_models.dart';
import 'package:onepanel_mobile/data/models/database_models.dart';
import 'package:onepanel_mobile/data/models/file_models.dart';
import 'package:onepanel_mobile/data/models/host_models.dart';
import 'package:onepanel_mobile/data/models/monitor_models.dart';
import 'package:onepanel_mobile/data/models/app_models.dart';
import 'package:onepanel_mobile/data/models/firewall_models.dart';
import 'package:onepanel_mobile/data/models/cronjob_models.dart';
import 'package:onepanel_mobile/data/models/ssl_models.dart';
import 'package:onepanel_mobile/data/models/logs_models.dart';
import 'package:onepanel_mobile/data/models/system_models.dart';

/// 1Panel API 客户端
class OnePanelApiClient {
  final DioClient _dioClient;

  OnePanelApiClient({required ServerService serverService})
      : _dioClient = DioClient(serverService: serverService);

  /// 更新服务器配置
  void updateServerConfig(String baseUrl, bool skipSSLVerify) {
    _dioClient.updateBaseUrl(baseUrl);
    _dioClient.updateSSLSettings(skipSSLVerify);
  }

  /// 连通性/鉴权测试：使用传入的地址与密钥直接请求，不写入也不会改动已保存的服务器。
  /// 返回 null 表示成功，否则返回可读的错误描述（含 HTTP 状态与服务端提示）。
  static Future<String?> testConnection({
    required String baseUrl,
    required String apiKey,
    bool useSSL = false,
    bool skipSSLVerify = false,
  }) async {
    final dio = Dio(BaseOptions(
      baseUrl: buildApiBase(baseUrl, useSSL: useSSL),
      connectTimeout: Duration(seconds: AppConfig.connectTimeout),
      receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
      responseType: ResponseType.json,
    ));
    if (skipSSLVerify) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        },
      );
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final tokenBytes = md5.convert(utf8.encode('1panel$apiKey$timestamp'));
    final token = tokenBytes.toString();

    try {
      final resp = await dio.get<dynamic>(
        '/dashboard/base/os',
        options: Options(headers: {
          '1Panel-Token': token,
          '1Panel-Timestamp': timestamp.toString(),
        }),
      );
      final code = resp.statusCode ?? 0;
      if (code >= 200 && code < 300) return null;
      return 'HTTP $code';
    } on DioException catch (e) {
      return _describeDioError(e);
    } catch (e) {
      return e.toString();
    } finally {
      dio.close(force: true);
    }
  }

  static String _describeDioError(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final parts = <String>[e.type.name];
    if (status != null) parts.add('HTTP $status');
    if (body != null) {
      var s = body.toString();
      if (s.length > 200) s = '${s.substring(0, 200)}...';
      parts.add(s);
    } else if (e.message != null) {
      parts.add(e.message!);
    }
    return parts.join(' | ');
  }

  // ==================== 仪表盘 API ====================

  /// 获取仪表盘概览
  Future<DashboardOverview> getDashboardOverview() async {
    final response = await _dioClient.get('/dashboard/overview');
    return DashboardOverview.fromJson(response.data['data']);
  }

  /// 获取系统基础信息
  Future<BaseInfo> getBaseInfo() async {
    final response = await _dioClient.get('/dashboard/base/os');
    return BaseInfo.fromJson(response.data['data']);
  }

  /// 获取系统资源监控
  Future<ResourceMonitor> getResourceMonitor() async {
    final response = await _dioClient.get('/dashboard/monitor');
    return ResourceMonitor.fromJson(response.data['data']);
  }

  // ==================== 主机 API ====================

  /// 获取主机信息
  Future<HostInfo> getHostInfo() async {
    final response = await _dioClient.get('/hosts/info');
    return HostInfo.fromJson(response.data['data']);
  }

  /// 获取磁盘信息
  Future<List<DiskInfo>> getDiskInfo() async {
    final response = await _dioClient.get('/hosts/disk/list');
    return (response.data['data'] as List)
        .map((e) => DiskInfo.fromJson(e))
        .toList();
  }

  /// 获取进程列表
  Future<List<ProcessInfo>> getProcessList() async {
    final response = await _dioClient.get('/hosts/process/list');
    return (response.data['data'] as List)
        .map((e) => ProcessInfo.fromJson(e))
        .toList();
  }

  /// 终止进程
  Future<bool> killProcess(int pid) async {
    final response = await _dioClient.post('/hosts/process/operate', data: {
      'pid': pid,
      'operation': 'kill',
    });
    return response.data['success'];
  }

  // ==================== 容器 API ====================

  /// 获取容器列表
  Future<PageResult<ContainerInfo>> getContainerList({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? state,
  }) async {
    final response = await _dioClient.get('/containers/list', queryParameters: {
      'page': page,
      'pageSize': pageSize,
      if (search != null) 'search': search,
      if (state != null) 'state': state,
    });
    return PageResult.fromJson(
      response.data['data'],
      (e) => ContainerInfo.fromJson(e),
    );
  }

  /// 容器操作
  Future<bool> containerOperation(String id, String operation) async {
    final response = await _dioClient.post('/containers/operate', data: {
      'id': id,
      'operation': operation,
    });
    return response.data['success'];
  }

  /// 获取容器日志
  Future<String> getContainerLogs(String id, {int tail = 100}) async {
    final response = await _dioClient.get('/containers/log', queryParameters: {
      'id': id,
      'tail': tail,
    });
    return response.data['data']?.toString() ?? '';
  }

  /// 获取容器详情
  Future<ContainerDetail> getContainerDetail(String id) async {
    final response = await _dioClient.get('/containers/detail', queryParameters: {
      'id': id,
    });
    return ContainerDetail.fromJson(response.data['data']);
  }

  // ==================== 网站 API ====================

  /// 获取网站列表
  Future<PageResult<WebsiteInfo>> getWebsiteList({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final response = await _dioClient.get('/websites/list', queryParameters: {
      'page': page,
      'pageSize': pageSize,
      if (search != null) 'search': search,
    });
    return PageResult.fromJson(
      response.data['data'],
      (e) => WebsiteInfo.fromJson(e),
    );
  }

  /// 网站操作
  Future<bool> websiteOperation(int id, String operation) async {
    final response = await _dioClient.post('/websites/operate', data: {
      'id': id,
      'operation': operation,
    });
    return response.data['success'];
  }

  /// 获取网站详情
  Future<WebsiteDetail> getWebsiteDetail(int id) async {
    final response = await _dioClient.get('/websites/get', queryParameters: {
      'id': id,
    });
    return WebsiteDetail.fromJson(response.data['data']);
  }

  // ==================== 数据库 API ====================

  /// 获取数据库列表
  Future<PageResult<DatabaseInfo>> getDatabaseList({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? search,
  }) async {
    final response = await _dioClient.get('/databases/list', queryParameters: {
      'page': page,
      'pageSize': pageSize,
      if (type != null) 'type': type,
      if (search != null) 'search': search,
    });
    return PageResult.fromJson(
      response.data['data'],
      (e) => DatabaseInfo.fromJson(e),
    );
  }

  /// 数据库操作
  Future<bool> databaseOperation(int id, String operation) async {
    final response = await _dioClient.post('/databases/operate', data: {
      'id': id,
      'operation': operation,
    });
    return response.data['success'];
  }

  /// 获取数据库访问信息
  Future<DatabaseAccess> getDatabaseAccess(int id) async {
    final response = await _dioClient.get('/databases/access', queryParameters: {
      'id': id,
    });
    return DatabaseAccess.fromJson(response.data['data']);
  }

  // ==================== 文件管理 API ====================

  /// 获取文件列表
  Future<List<FileInfo>> getFileList(String path) async {
    final response = await _dioClient.get('/files/list', queryParameters: {
      'path': path,
    });
    return (response.data['data'] as List)
        .map((e) => FileInfo.fromJson(e))
        .toList();
  }

  /// 读取文件内容
  Future<String> readFileContent(String path) async {
    final response = await _dioClient.get('/files/content', queryParameters: {
      'path': path,
    });
    return response.data['data']?.toString() ?? '';
  }

  /// 保存文件内容
  Future<bool> saveFileContent(String path, String content) async {
    final response = await _dioClient.post('/files/content', data: {
      'path': path,
      'content': content,
    });
    return response.data['success'];
  }

  /// 创建文件/目录
  Future<bool> createFile(String path, bool isDir) async {
    final response = await _dioClient.post('/files/create', data: {
      'path': path,
      'isDir': isDir,
    });
    return response.data['success'];
  }

  /// 删除文件/目录
  Future<bool> deleteFile(String path) async {
    final response = await _dioClient.post('/files/delete', data: {
      'path': path,
    });
    return response.data['success'];
  }

  /// 重命名文件/目录
  Future<bool> renameFile(String oldPath, String newPath) async {
    final response = await _dioClient.post('/files/rename', data: {
      'oldPath': oldPath,
      'newPath': newPath,
    });
    return response.data['success'];
  }

  /// 压缩文件
  Future<bool> compressFile(String path, String dest) async {
    final response = await _dioClient.post('/files/compress', data: {
      'path': path,
      'dest': dest,
    });
    return response.data['success'];
  }

  /// 解压文件
  Future<bool> decompressFile(String path, String dest) async {
    final response = await _dioClient.post('/files/decompress', data: {
      'path': path,
      'dest': dest,
    });
    return response.data['success'];
  }

  // ==================== 监控 API ====================

  /// 获取实时监控数据
  Future<MonitorData> getMonitorData() async {
    final response = await _dioClient.get('/monitor/data');
    return MonitorData.fromJson(response.data['data']);
  }

  /// 获取监控配置
  Future<MonitorConfig> getMonitorConfig() async {
    final response = await _dioClient.get('/monitor/setting');
    return MonitorConfig.fromJson(response.data['data']);
  }

  /// 更新监控配置
  Future<bool> updateMonitorConfig(MonitorConfig config) async {
    final response = await _dioClient.post('/monitor/setting', data: config.toJson());
    return response.data['success'];
  }

  // ==================== 防火墙 API ====================

  /// 获取防火墙规则列表
  Future<List<FirewallRule>> getFirewallRules() async {
    final response = await _dioClient.get('/firewall/rule/search');
    return (response.data['data'] as List)
        .map((e) => FirewallRule.fromJson(e))
        .toList();
  }

  /// 操作防火墙
  Future<bool> firewallOperation(String operation) async {
    final response = await _dioClient.post('/firewall/operate', data: {
      'operation': operation,
    });
    return response.data['success'];
  }

  // ==================== 计划任务 API ====================

  /// 获取计划任务列表
  Future<List<CronjobInfo>> getCronjobList() async {
    final response = await _dioClient.get('/cronjobs/list');
    return (response.data['data'] as List)
        .map((e) => CronjobInfo.fromJson(e))
        .toList();
  }

  /// 操作计划任务
  Future<bool> cronjobOperation(int id, String operation) async {
    final response = await _dioClient.post('/cronjobs/operate', data: {
      'id': id,
      'operation': operation,
    });
    return response.data['success'];
  }

  // ==================== 应用商店 API ====================

  /// 获取已安装应用列表
  Future<List<AppInfo>> getInstalledApps() async {
    final response = await _dioClient.get('/apps/installed/list');
    return (response.data['data'] as List)
        .map((e) => AppInfo.fromJson(e))
        .toList();
  }

  /// 应用操作
  Future<bool> appOperation(int id, String operation) async {
    final response = await _dioClient.post('/apps/installed/op', data: {
      'id': id,
      'operation': operation,
    });
    return response.data['success'];
  }

  // ==================== 系统 API ====================

  /// 获取系统信息
  Future<SystemInfo> getSystemInfo() async {
    final response = await _dioClient.get('/system/info');
    return SystemInfo.fromJson(response.data['data']);
  }

  /// 重启系统
  Future<bool> restartSystem() async {
    final response = await _dioClient.post('/system/restart');
    return response.data['success'];
  }

  /// 关机
  Future<bool> shutdownSystem() async {
    final response = await _dioClient.post('/system/shutdown');
    return response.data['success'];
  }

  /// 获取面板设置
  Future<PanelSettings> getPanelSettings() async {
    final response = await _dioClient.get('/settings/setting');
    return PanelSettings.fromJson(response.data['data']);
  }

  /// 更新面板设置
  Future<bool> updatePanelSettings(PanelSettings settings) async {
    final response = await _dioClient.post('/settings/setting', data: settings.toJson());
    return response.data['success'];
  }

  // ==================== 日志 API ====================

  /// 获取操作日志
  Future<List<OperationLog>> getOperationLogs({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final response = await _dioClient.get('/logs/operation', queryParameters: {
      'page': page,
      'pageSize': pageSize,
      if (search != null) 'search': search,
    });
    return (response.data['data'] as List)
        .map((e) => OperationLog.fromJson(e))
        .toList();
  }

  /// 获取登录日志
  Future<List<LoginLog>> getLoginLogs({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.get('/logs/login', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    return (response.data['data'] as List)
        .map((e) => LoginLog.fromJson(e))
        .toList();
  }
}
