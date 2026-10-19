import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/api/v2/api_client.dart';
import 'package:onepanel_mobile/core/i18n/i18n.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/data/models/website_models.dart';
import 'package:onepanel_mobile/widgets/shimmer_loader.dart';
import 'package:onepanel_mobile/widgets/refresh_icon_button.dart';

class WebsitesPage extends StatefulWidget {
  const WebsitesPage({super.key});

  @override
  State<WebsitesPage> createState() => _WebsitesPageState();
}

class _WebsitesPageState extends State<WebsitesPage> {
  late OnePanelApiClient _apiClient;
  bool _isLoading = true;
  List<WebsiteInfo> _websites = [];
  String? _error;
  String _search = '';

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
      final result = await _apiClient.getWebsiteList(
        page: 1,
        pageSize: 50,
        search: _search.isNotEmpty ? _search : null,
      );

      if (!mounted) return;
      setState(() {
        _websites = result.items;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Websites', 'Failed to load: $e');
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

  Future<void> _operateWebsite(WebsiteInfo website, String operation) async {
    String opLabel;
    switch (operation) {
      case 'start':
        opLabel = t('start');
        break;
      case 'stop':
        opLabel = t('stop');
        break;
      case 'restart':
        opLabel = t('restart');
        break;
      default:
        opLabel = operation;
    }
    try {
      await _apiClient.websiteOperation(website.id, operation);
      _snack('${website.name} · $opLabel');
      _refresh();
    } catch (e) {
      _snack('${t('error')}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: _isLoading
                ? const ShimmerLoader()
                : _error != null
                    ? Center(child: Text('${t('error')}: $_error'))
                    : _websites.isEmpty
                        ? Center(child: Text(t('noWebsitesFound')))
                        : ListView.builder(
                            itemCount: _websites.length,
                            itemBuilder: (context, index) {
                              final website = _websites[index];
                              return _WebsiteCard(
                                website: website,
                                onTap: () => _showWebsiteActions(website),
                              );
                            },
                          ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: t('searchWebsitesHint'),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) {
                setState(() => _search = v);
                _refresh();
              },
            ),
          ),
          RefreshIconButton(onPressed: _refresh),
        ],
      ),
    );
  }

  void _showWebsiteActions(WebsiteInfo website) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(website.name),
              subtitle: Text(website.domain),
            ),
            const Divider(),
            if (website.isRunning) ...[
              _ActionTile(
                icon: Icons.stop,
                title: t('stop'),
                onTap: () => _operateWebsite(website, 'stop'),
              ),
            ],
            if (website.isStopped) ...[
              _ActionTile(
                icon: Icons.play_arrow,
                title: t('start'),
                onTap: () => _operateWebsite(website, 'start'),
              ),
            ],
            _ActionTile(
              icon: Icons.restart_alt,
              title: t('restart'),
              onTap: () => _operateWebsite(website, 'restart'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebsiteCard extends StatelessWidget {
  final WebsiteInfo website;
  final VoidCallback onTap;

  const _WebsiteCard({
    required this.website,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = website.isRunning ? Colors.green : Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.web, size: 28),
        ),
        title: Text(
          website.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              website.domain,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (website.primaryDomain != null) ...[
              const SizedBox(height: 4),
              Text(
                '${I18n.tr(context, 'primary')}: ${website.primaryDomain}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
        trailing: Chip(
          label: Text(
            website.status ?? I18n.tr(context, 'unknown'),
            style: TextStyle(color: statusColor, fontSize: 12),
          ),
          backgroundColor: statusColor.withAlpha(50),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: color != null ? TextStyle(color: color) : null),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}
