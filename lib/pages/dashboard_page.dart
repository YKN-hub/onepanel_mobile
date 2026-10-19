import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/api/v2/api_client.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/data/models/dashboard_models.dart';
import 'package:onepanel_mobile/data/models/host_models.dart';
import 'package:onepanel_mobile/widgets/shimmer_loader.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late OnePanelApiClient _apiClient;
  bool _isLoading = true;
  DashboardOverview? _overview;
  BaseInfo? _baseInfo;
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
      final overview = await _apiClient.getDashboardOverview();
      final baseInfo = await _apiClient.getBaseInfo();
      
      setState(() {
        _overview = overview;
        _baseInfo = baseInfo;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Dashboard', 'Failed to load: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(),
      child: _isLoading
        ? const ShimmerLoader()
        : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  )),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _overview != null && _baseInfo != null
            ? _buildDashboard()
            : const Center(child: Text('No data')),
    );
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatsGrid(),
        const SizedBox(height: 24),
        _buildResourceCards(),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _StatCard(
          icon: Icons.web,
          label: 'Websites',
          value: _overview!.totalWebsites.toString(),
          color: Colors.blue,
        ),
        _StatCard(
          icon: Icons.database,
          label: 'Databases',
          value: _overview!.totalDatabases.toString(),
          color: Colors.green,
        ),
        _StatCard(
          icon: Icons.storage,
          label: 'Containers',
          value: _overview!.totalContainers.toString(),
          color: Colors.orange,
        ),
        _StatCard(
          icon: Icons.apps,
          label: 'Apps',
          value: _overview!.totalApps.toString(),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildResourceCards() {
    return Column(
      children: [
        _ResourceCard(
          title: 'CPU Usage',
          value: '${_overview!.cpuUsage.toStringAsFixed(1)}%',
          percent: _overview!.cpuUsage / 100,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _ResourceCard(
          title: 'Memory Usage',
          value: '${_overview!.memoryUsage.toStringAsFixed(1)}%',
          percent: _overview!.memoryUsage / 100,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _ResourceCard(
          title: 'Disk Usage',
          value: '${_overview!.diskUsage.toStringAsFixed(1)}%',
          percent: _overview!.diskUsage / 100,
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'System Info',
          items: [
            'OS: ${_baseInfo!.os}',
            'Platform: ${_baseInfo!.platform}',
            'Kernel: ${_baseInfo!.kernel}',
            'Arch: ${_baseInfo!.arch}',
            'CPU: ${_baseInfo!.cpuModel} (${_baseInfo!.cpuCores} cores)',
            'Panel: ${_baseInfo!.panelVersion}',
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String title;
  final String value;
  final double percent;
  final Color color;

  const _ResourceCard({
    required this.title,
    required this.value,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearPercentIndicator(
              lineHeight: 8,
              percent: percent.clamp(0, 1),
              progressColor: color,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              barRadius: const Radius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _InfoCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
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
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
