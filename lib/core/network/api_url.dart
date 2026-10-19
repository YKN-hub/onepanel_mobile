import 'package:onepanel_mobile/data/models/server_info.dart';

/// 1Panel v2 接口前缀
const String kApiV2Prefix = '/api/v2';

/// 由用户填写的地址构造 1Panel API 基地址。
///
/// 支持以下输入：
/// - `https://panel.example.com`
/// - `panel.example.com:14444`（无协议时按 useSSL 补全）
/// - `https://panel.example.com/安全入口`（1Panel 开启安全入口 entrance 时）
/// - `https://panel.example.com/api/v2`（已带前缀则不重复拼）
///
/// 规则：
/// 1. 无协议时按 [useSSL] 补 http/https；
/// 2. 去掉末尾斜杠；
/// 3. 若末尾已是 `/api/v1` 或 `/api/v2` 则原样使用，否则追加 `/api/v2`。
String buildApiBase(String rawUrl, {bool useSSL = false}) {
  var url = rawUrl.trim();
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = '${useSSL ? 'https' : 'http'}://$url';
  }
  while (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }
  final hasVersion = url.endsWith('/api/v1') || url.endsWith('/api/v2');
  if (!hasVersion) {
    url = '$url$kApiV2Prefix';
  }
  return url;
}

/// 根据服务器解析 API 基地址；未选择服务器时返回 null。
String? resolveApiBaseUrl(ServerInfo? server) {
  if (server == null) return null;
  final base = server.baseUrl.trim();
  if (base.isEmpty) return null;
  return buildApiBase(base, useSSL: server.useSSL);
}
