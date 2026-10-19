import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/api/v2/api_client.dart';
import 'package:onepanel_mobile/data/models/system_models.dart';
import 'package:onepanel_mobile/widgets/shimmer_loader.dart';
import 'package:onepanel_mobile/pages/server_list_page.dart';

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
      
      setState(() {
        _systemInfo = systemInfo;
        _panelSettings = panelSettings;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Settings', 'Failed to load: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _restartSystem() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart System'),
        content: const Text('Are you sure you want to restart the system?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restart'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _apiClient.restartSystem();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('System restart initiated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _shutdownSystem() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shutdown System'),
        content: const Text('Are you sure you want to shutdown the system?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Shutdown'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _apiClient.shutdownSystem();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('System shutdown initiated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(),
      child: _isLoading
        ? const ShimmerLoader()
        : _error != null
          ? Center(child: Text('Error: $_error'))
          : _systemInfo == null
            ? const Center(child: Text('No data'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSystemInfo(),
                    const SizedBox(height: 16),
                    _buildPanelSettings(),
                    const SizedBox(height: 16),
                    _buildSystemActions(),
                  ],
                ),
              ),
    );
  }

  Widget _buildSystemInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Version', value: _systemInfo?.version ?? '-'),
            _InfoRow(label: 'OS', value: _systemInfo?.os ?? '-'),
            _InfoRow(label: 'Architecture', value: _systemInfo?.arch ?? '-'),
            _InfoRow(label: 'Go Version', value: _systemInfo?.goVersion ?? '-'),
            _InfoRow(label: 'Database', value: '${_systemInfo?.database} ${_systemInfo?.databaseVersion}'),
            _InfoRow(label: 'Server Time', value: _systemInfo?.serverTime ?? '-'),
            _InfoRow(label: 'Uptime', value: _formatUptime(_systemInfo?.uptime)),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Title', value: _panelSettings?.title ?? '-'),
            _InfoRow(label: 'Port', value: _panelSettings?.port?.toString() ?? '-'),
            _InfoRow(label: 'Language', value: _panelSettings?.language ?? '-'),
            _InfoRow(label: 'Timezone', value: _panelSettings?.timezone ?? '-'),
            _InfoRow(label: 'API Enabled', value: _panelSettings?.apiEnable == true ? 'Yes' : 'No'),
            _InfoRow(label: 'MFA', value: _panelSettings?.mfa == true ? 'Enabled' : 'Disabled'),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: const Text('Restart System'),
              onPressed: _restartSystem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.power_settings_new),
              label: const Text('Shutdown System'),
              onPressed: _shutdownSystem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
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
    if (days > 0) return '$days days $hours hours';
    if (hours > 0) return '$hours hours $minutes minutes';
    return '$minutes minutes';
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
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
