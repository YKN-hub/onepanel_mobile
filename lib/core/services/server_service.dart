import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepanel_mobile/data/models/server_info.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

/// 服务器管理服务
class ServerService {
  static const String _serverKey = 'onepanel_servers';
  static const String _currentServerIdKey = 'onepanel_current_server_id';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SharedPreferences _prefs = _getPrefs();
  final Uuid _uuid = const Uuid();

  static SharedPreferences _getPrefs() {
    // 延迟初始化
    throw UnsupportedError('Use getInstance instead');
  }

  List<ServerInfo> _servers = [];
  ServerInfo? _currentServer;
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _servers = _loadServers(prefs);
    _currentServer = _loadCurrentServer(prefs);
    _initialized = true;
  }

  List<ServerInfo> _loadServers(SharedPreferences prefs) {
    final jsonList = prefs.getStringList(_serverKey) ?? [];
    return jsonList
        .map((e) => ServerInfo.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  ServerInfo? _loadCurrentServer(SharedPreferences prefs) {
    final currentId = prefs.getString(_currentServerIdKey);
    if (currentId == null) return null;
    return _servers.firstWhere((s) => s.id == currentId);
  }

  List<ServerInfo> get servers {
    if (!_initialized) return [];
    return List.unmodifiable(_servers);
  }

  ServerInfo? get currentServer {
    if (!_initialized) return null;
    return _currentServer;
  }

  /// 添加服务器
  Future<bool> addServer({
    required String name,
    required String baseUrl,
    required String apiKey,
    String? username,
    String? password,
    bool useSSL = false,
    bool skipSSLVerify = false,
    String? notes,
  }) async {
    await _init();
    final prefs = await SharedPreferences.getInstance();

    final server = ServerInfo(
      id: _uuid.v4(),
      name: name,
      baseUrl: baseUrl,
      apiKey: apiKey,
      username: username,
      password: password,
      useSSL: useSSL,
      skipSSLVerify: skipSSLVerify,
      createdAt: DateTime.now(),
      notes: notes,
    );

    _servers.add(server);
    await _saveServers(prefs);

    if (_currentServer == null) {
      _currentServer = server;
      await prefs.setString(_currentServerIdKey, server.id);
    }

    return true;
  }

  /// 更新服务器
  Future<bool> updateServer(String id, Map<String, dynamic> updates) async {
    await _init();
    final prefs = await SharedPreferences.getInstance();

    final index = _servers.indexWhere((s) => s.id == id);
    if (index == -1) return false;

    final server = _servers[index];
    final updated = ServerInfo(
      id: server.id,
      name: updates['name'] ?? server.name,
      baseUrl: updates['baseUrl'] ?? server.baseUrl,
      apiKey: updates['apiKey'] ?? server.apiKey,
      username: updates['username'] ?? server.username,
      password: updates['password'] ?? server.password,
      useSSL: updates['useSSL'] ?? server.useSSL,
      skipSSLVerify: updates['skipSSLVerify'] ?? server.skipSSLVerify,
      createdAt: server.createdAt,
      lastConnectedAt: server.lastConnectedAt,
      notes: updates['notes'] ?? server.notes,
    );

    _servers[index] = updated;
    await _saveServers(prefs);

    if (_currentServer?.id == id) {
      _currentServer = updated;
    }

    return true;
  }

  /// 删除服务器
  Future<bool> deleteServer(String id) async {
    await _init();
    final prefs = await SharedPreferences.getInstance();

    _servers.removeWhere((s) => s.id == id);
    await _saveServers(prefs);

    if (_currentServer?.id == id) {
      _currentServer = _servers.isNotEmpty ? _servers.first : null;
      if (_currentServer != null) {
        await prefs.setString(_currentServerIdKey, _currentServer!.id);
      } else {
        await prefs.remove(_currentServerIdKey);
      }
    }

    return true;
  }

  /// 切换当前服务器
  Future<bool> switchServer(String id) async {
    await _init();
    final prefs = await SharedPreferences.getInstance();

    final server = _servers.firstWhere((s) => s.id == id);
    if (server == null) return false;

    _currentServer = server;
    await prefs.setString(_currentServerIdKey, id);

    return true;
  }

  /// 更新最后连接时间
  Future<void> updateLastConnected() async {
    await _init();
    final prefs = await SharedPreferences.getInstance();

    if (_currentServer == null) return;

    final index = _servers.indexWhere((s) => s.id == _currentServer!.id);
    if (index == -1) return;

    final updated = ServerInfo(
      id: _currentServer!.id,
      name: _currentServer!.name,
      baseUrl: _currentServer!.baseUrl,
      apiKey: _currentServer!.apiKey,
      username: _currentServer!.username,
      password: _currentServer!.password,
      useSSL: _currentServer!.useSSL,
      skipSSLVerify: _currentServer!.skipSSLVerify,
      createdAt: _currentServer!.createdAt,
      lastConnectedAt: DateTime.now(),
      notes: _currentServer!.notes,
    );

    _servers[index] = updated;
    _currentServer = updated;
    await _saveServers(prefs);
  }

  Future<void> _saveServers(SharedPreferences prefs) async {
    final jsonList = _servers.map((s) => jsonEncode(s.toMap())).toList();
    await prefs.setStringList(_serverKey, jsonList);
  }
}
