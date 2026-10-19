import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/api/v2/api_client.dart';
import 'package:onepanel_mobile/core/i18n/i18n.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/data/models/monitor_models.dart';
import 'package:onepanel_mobile/widgets/shimmer_loader.dart';
import 'package:fl_chart/fl_chart.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage>
    with SingleTickerProviderStateMixin {
  late OnePanelApiClient _apiClient;
  bool _isLoading = true;
  MonitorData? _monitorData;
  String? _error;
  int _timeRange = 1; // 1: 1h, 2: 6h, 3: 24h, 4: 7d

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
      final data = await _apiClient.getMonitorData();

      if (!mounted) return;
      setState(() {
        _monitorData = data;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Monitor', 'Failed to load: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: _isLoading
          ? const ShimmerLoader()
          : _error != null
              ? Center(child: Text('${t('error')}: $_error'))
              : _monitorData == null
                  ? Center(child: Text(t('noMonitorData')))
                  : _buildMonitor(),
    );
  }

  Widget _buildMonitor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTimeRangeSelector(),
          const SizedBox(height: 16),
          _buildChart(t('cpuChart'), _monitorData!.cpu, Colors.blue),
          const SizedBox(height: 16),
          _buildChart(t('memoryChart'), _monitorData!.memory, Colors.green),
          const SizedBox(height: 16),
          _buildChart(
            t('networkChart'),
            _monitorData!.networkIn,
            Colors.orange,
            isOut: _monitorData!.networkOut,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TimeRangeButton(
          label: '1H',
          selected: _timeRange == 1,
          onTap: () => setState(() => _timeRange = 1),
        ),
        _TimeRangeButton(
          label: '6H',
          selected: _timeRange == 2,
          onTap: () => setState(() => _timeRange = 2),
        ),
        _TimeRangeButton(
          label: '24H',
          selected: _timeRange == 3,
          onTap: () => setState(() => _timeRange = 3),
        ),
        _TimeRangeButton(
          label: '7D',
          selected: _timeRange == 4,
          onTap: () => setState(() => _timeRange = 4),
        ),
      ],
    );
  }

  Widget _buildChart(
    String title,
    List<double> data,
    Color color, {
    List<double>? isOut,
  }) {
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
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: data.length > 10 ? data.length.toDouble() - 1 : 10,
                  minY: 0,
                  maxY: data.isNotEmpty
                      ? data.reduce((a, b) => a > b ? a : b) * 1.2
                      : 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                    if (isOut != null)
                      LineChartBarData(
                        spots: isOut
                            .asMap()
                            .entries
                            .map((e) =>
                                FlSpot(e.key.toDouble(), e.value.toDouble()))
                            .toList(),
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(show: false),
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

class _TimeRangeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TimeRangeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
