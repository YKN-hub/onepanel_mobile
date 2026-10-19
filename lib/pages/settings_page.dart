import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/api/v2/api_client.dart';
import 'package:onepanel_mobile/core/config/app_config.dart';
import 'package:onepanel_mobile/core/config/app_settings.dart';
import 'package:onepanel_mobile/core/i18n/i18n.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/data/models/system_models.dart';
import 'package:onepanel_mobile/widgets/shimmer_loader.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late OnePanelApiClient _apiClient;
  bool _isLoading = true;
  SystemInfo? _systemInfo;
  PanelSettings? _panelSettings;
  String? _error;

  String t(String key) => I18n.tr(context, key);

  @override
  void initState() {
    super.initState();
    _apiClient = OnePanelApiClient(
      serverService: Provider.of<ServerService>(context, listen: false),
    );
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final systemInfo = await _apiClient.getSystemInfo();
      final panelSettings = await _apiClient.getPanelSettings();

      if (!mounted) return;
      setState(() {
        _systemInfo = systemInfo;
        _panelSettings = panelSettings;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Settings', 'Failed to load: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmAndRun({
    required String title,
    required String content,
    required String confirmLabel,
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    if (ok != true) return;
    try {
      await action();
      _snack(successMessage);
    } catch (e) {
      _snack('${t('error')}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasServer =
        Provider.of<ServerService>(context).currentServer != null;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLanguageCard(),
          const SizedBox(height: 16),
          if (!hasServer)
            _buildCard(t('servers'), Text(t('noServerSelected')))
          else if (_isLoading)
            const SizedBox(height: 220, child: ShimmerLoader())
          else if (_error != null)
            _buildCard(
              t('error'),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            )
          else ...[
            _buildSystemInfoCard(),
            const SizedBox(height: 16),
            _buildPanelSettingsCard(),
            const SizedBox(height: 16),
            _buildSystemActionsCard(),
          ],
          const SizedBox(height: 16),
          _buildAboutCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLanguageCard() {
    final settings = context.watch<AppSettings>();
    return _buildCard(
      t('appLanguage'),
      Column(
        children: [
          RadioListTile<String>(
            value: 'system',
            groupValue: settings.localeCode,
            title: Text(t('followSystem')),
            onChanged: (v) => v == null ? null : settings.setLocale(v),
          ),
          RadioListTile<String>(
            value: 'zh',
            groupValue: settings.localeCode,
            title: Text(t('chinese')),
            onChanged: (v) => v == null ? null : settings.setLocale(v),
          ),
          RadioListTile<String>(
            value: 'en',
            groupValue: settings.localeCode,
            title: Text(t('english')),
            onChanged: (v) => v == null ? null : settings.setLocale(v),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return _buildCard(
      t('about'),
      _InfoRow(label: t('appVersion'), value: AppConfig.version),
    );
  }

  Widget _buildSystemInfoCard() {
    return _buildCard(
      t('systemInformation'),
      Column(
        children: [
          _InfoRow(label: t('version'), value: _systemInfo?.version ?? '-'),
          _InfoRow(label: t('os'), value: _systemInfo?.os ?? '-'),
          _InfoRow(label: t('arch'), value: _systemInfo?.arch ?? '-'),
          _InfoRow(label: t('goVersion'), value: _systemInfo?.goVersion ?? '-'),
          _InfoRow(
            label: t('database'),
            value: '${_systemInfo?.database ?? '-'} '
                '${_systemInfo?.databaseVersion ?? ''}'.trim(),
          ),
          _InfoRow(
              label: t('serverTime'), value: _systemInfo?.serverTime ?? '-'),
          _InfoRow(
              label: t('uptime'), value: _formatUptime(_systemInfo?.uptime)),
        ],
      ),
    );
  }

  Widget _buildPanelSettingsCard() {
    return _buildCard(
      t('panelSettings'),
      Column(
        children: [
          _InfoRow(label: t('title'), value: _panelSettings?.title ?? '-'),
          _InfoRow(
              label: t('port'), value: _panelSettings?.port?.toString() ?? '-'),
          _InfoRow(
              label: t('language'), value: _panelSettings?.language ?? '-'),
          _InfoRow(
              label: t('timezone'), value: _panelSettings?.timezone ?? '-'),
          _InfoRow(
            label: t('apiEnabled'),
            value: _panelSettings?.apiEnable == true ? t('yes') : t('no'),
          ),
          _InfoRow(
            label: t('mfa'),
            value: _panelSettings?.mfa == true
                ? t('mfaEnabled')
                : t('mfaDisabled'),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemActionsCard() {
    return _buildCard(
      t('systemActions'),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.restart_alt),
            label: Text(t('restartSystem')),
            onPressed: () => _confirmAndRun(
              title: t('restartSystem'),
              content: t('restartConfirm'),
              confirmLabel: t('confirm'),
              action: _apiClient.restartSystem,
              successMessage: t('systemRestartInitiated'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.power_settings_new),
            label: Text(t('shutdownSystem')),
            onPressed: () => _confirmAndRun(
              title: t('shutdownSystem'),
              content: t('shutdownConfirm'),
              confirmLabel: t('confirm'),
              action: _apiClient.shutdownSystem,
              successMessage: t('systemShutdownInitiated'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  String _formatUptime(int? uptime) {
    if (uptime == null) return '-';
    final days = uptime ~/ 86400;
    final hours = (uptime % 86400) ~/ 3600;
    final minutes = (uptime % 3600) ~/ 60;
    if (days > 0) return '$days d $hours h';
    if (hours > 0) return '$hours h $minutes m';
    return '$minutes m';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
