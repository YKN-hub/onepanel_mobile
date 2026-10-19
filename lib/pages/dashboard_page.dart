import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/api/v2/api_client.dart';
import 'package:onepanel_mobile/core/i18n/i18n.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/data/models/dashboard_models.dart';
import 'package:onepanel_mobile/widgets/shimmer_loader.dart';
import 'package:onepanel_mobile/widgets/refresh_icon_button.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late OnePanelApiClient _apiClient;
  bool _isLoading = true;
  DashboardOverview? _overview;
  BaseInfo? _baseInfo;
  String? _error;

  String t(String key) => I18n.tr(context, key);

  @override
  void initState() {
    super.initState();
    _apiClient = OnePanelApiClient(
      serverService: Provider.of<ServerService>(context, listen: false),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final overview = await _apiClient.getDashboardOverview();
      final base = await _apiClient.getBaseInfo();
      if (!mounted) return;
      setState(() {
        _overview = overview;
        _baseInfo = base;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Dashboard', 'Failed to load: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('dashboard')),
        actions: [
          RefreshIconButton(onPressed: _loadData),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ShimmerLoader();
    }
    if (_error != null) {
      return _buildError();
    }
    if (_overview == null) {
      return Center(child: Text(t('noData')));
    }
    return _buildDashboard();
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 64, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(t('error'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            child: Text(t('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatsGrid(),
        const SizedBox(height: 16),
        _buildResourceSection(),
        if (_baseInfo != null) ...[
          const SizedBox(height: 16),
          _buildSystemInfoSection(),
        ],
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = <_StatItem>[
      _StatItem(Icons.web, t('totalWebsites'), '${_overview!.totalWebsites}', Colors.blue),
      _StatItem(Icons.storage, t('totalDatabases'), '${_overview!.totalDatabases}', Colors.green),
      _StatItem(Icons.layers, t('totalContainers'), '${_overview!.totalContainers}', Colors.orange),
      _StatItem(Icons.apps, t('totalApps'), '${_overview!.totalApps}', Colors.purple),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: stats
          .map((s) => _buildStatCard(s.icon, s.label, s.value, s.color))
          .toList(),
    );
  }

  Widget _buildStatCard(
      IconData icon, String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('overview'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildResourceBar(t('cpuUsage'), _overview!.cpuUsage, Colors.blue),
            const SizedBox(height: 12),
            _buildResourceBar(
                t('memoryUsage'), _overview!.memoryUsage, Colors.green),
            const SizedBox(height: 12),
            _buildResourceBar(t('diskUsage'), _overview!.diskUsage, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceBar(String label, double percent, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: LinearPercentIndicator(
            lineHeight: 12,
            percent: percent / 100.0,
            barRadius: const Radius.circular(6),
            progressColor: color,
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            '${percent.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemInfoSection() {
    final items = <Map<String, String>>[
      {'label': t('os'), 'value': _baseInfo!.os},
      {'label': t('arch'), 'value': _baseInfo!.arch},
      {'label': t('version'), 'value': _baseInfo!.panelVersion},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('systemInfo'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e['label']!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      e['value']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 仪表盘统计卡片的数据
class _StatItem {
  const _StatItem(this.icon, this.label, this.value, this.color);

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}
