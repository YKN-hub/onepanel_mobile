import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/api/v2/api_client.dart';
import 'package:onepanel_mobile/core/i18n/i18n.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/data/models/database_models.dart';
import 'package:onepanel_mobile/widgets/shimmer_loader.dart';
import 'package:onepanel_mobile/widgets/refresh_icon_button.dart';

class DatabasesPage extends StatefulWidget {
  const DatabasesPage({super.key});

  @override
  State<DatabasesPage> createState() => _DatabasesPageState();
}

class _DatabasesPageState extends State<DatabasesPage> {
  late OnePanelApiClient _apiClient;
  bool _isLoading = true;
  List<DatabaseInfo> _databases = [];
  String? _error;
  String _search = '';
  String _typeFilter = 'all';

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
      final result = await _apiClient.getDatabaseList(
        page: 1,
        pageSize: 50,
        type: _typeFilter != 'all' ? _typeFilter : null,
        search: _search.isNotEmpty ? _search : null,
      );

      if (!mounted) return;
      setState(() {
        _databases = result.items;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Databases', 'Failed to load: $e');
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

  Future<void> _operateDatabase(
      DatabaseInfo database, String operation) async {
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
      await _apiClient.databaseOperation(database.id, operation);
      _snack('${database.name} · $opLabel');
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
                    : _databases.isEmpty
                        ? Center(child: Text(t('noDatabasesFound')))
                        : ListView.builder(
                            itemCount: _databases.length,
                            itemBuilder: (context, index) {
                              final database = _databases[index];
                              return _DatabaseCard(
                                database: database,
                                onTap: () => _showDatabaseActions(database),
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
                hintText: t('searchDatabasesHint'),
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
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _typeFilter,
            items: [
              DropdownMenuItem(value: 'all', child: Text(t('all'))),
              const DropdownMenuItem(value: 'mysql', child: Text('MySQL')),
              const DropdownMenuItem(value: 'mariadb', child: Text('MariaDB')),
              const DropdownMenuItem(
                  value: 'postgresql', child: Text('PostgreSQL')),
              const DropdownMenuItem(value: 'redis', child: Text('Redis')),
              const DropdownMenuItem(value: 'mongodb', child: Text('MongoDB')),
            ],
            onChanged: (v) {
              setState(() => _typeFilter = v ?? 'all');
              _refresh();
            },
          ),
          RefreshIconButton(onPressed: _refresh),
        ],
      ),
    );
  }

  void _showDatabaseActions(DatabaseInfo database) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(database.name),
              subtitle: Text(database.typeLabel),
            ),
            const Divider(),
            if (database.isRunning) ...[
              _ActionTile(
                icon: Icons.stop,
                title: t('stop'),
                onTap: () => _operateDatabase(database, 'stop'),
              ),
            ],
            if (database.isStopped) ...[
              _ActionTile(
                icon: Icons.play_arrow,
                title: t('start'),
                onTap: () => _operateDatabase(database, 'start'),
              ),
            ],
            _ActionTile(
              icon: Icons.restart_alt,
              title: t('restart'),
              onTap: () => _operateDatabase(database, 'restart'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatabaseCard extends StatelessWidget {
  final DatabaseInfo database;
  final VoidCallback onTap;

  const _DatabaseCard({
    required this.database,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = database.isRunning ? Colors.green : Colors.grey;

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
          child: Icon(
            Icons.storage,
            color: _getTypeColor(database.type),
          ),
        ),
        title: Text(
          database.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              database.typeLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (database.host != null) ...[
              const SizedBox(height: 4),
              Text(
                '${database.host}:${database.port}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
        trailing: Chip(
          label: Text(
            database.status ?? I18n.tr(context, 'unknown'),
            style: TextStyle(color: statusColor, fontSize: 12),
          ),
          backgroundColor: statusColor.withAlpha(50),
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'mysql':
      case 'mariadb':
        return Colors.blue;
      case 'postgresql':
        return Colors.orange;
      case 'redis':
        return Colors.red;
      case 'mongodb':
        return Colors.green;
      default:
        return Colors.grey;
    }
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
