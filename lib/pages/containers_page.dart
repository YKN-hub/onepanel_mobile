import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/api/v2/api_client.dart';
import 'package:onepanel_mobile/core/i18n/i18n.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/data/models/container_models.dart';
import 'package:onepanel_mobile/widgets/shimmer_loader.dart';
import 'package:onepanel_mobile/widgets/refresh_icon_button.dart';

class ContainersPage extends StatefulWidget {
  const ContainersPage({super.key});

  @override
  State<ContainersPage> createState() => _ContainersPageState();
}

class _ContainersPageState extends State<ContainersPage>
    with SingleTickerProviderStateMixin {
  late OnePanelApiClient _apiClient;
  bool _isLoading = true;
  List<ContainerInfo> _containers = [];
  String? _error;
  String _search = '';
  String _filter = 'all';

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
      final result = await _apiClient.getContainerList(
        page: 1,
        pageSize: 50,
        search: _search.isNotEmpty ? _search : null,
        state: _filter != 'all' ? _filter : null,
      );

      if (!mounted) return;
      setState(() {
        _containers = result.items;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Containers', 'Failed to load: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _operateContainer(
      ContainerInfo container, String operation) async {
    try {
      await _apiClient.containerOperation(container.id, operation);
      _snack('${container.name} · ${_opLabel(operation)}');
      _refresh();
    } catch (e) {
      _snack('${t('error')}: $e');
    }
  }

  String _opLabel(String operation) {
    switch (operation) {
      case 'start':
        return t('start');
      case 'stop':
        return t('stop');
      case 'restart':
        return t('restart');
      case 'pause':
        return t('pause');
      case 'unpause':
        return t('resume');
      case 'delete':
        return t('delete');
      default:
        return operation;
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showContainerActions(ContainerInfo container) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(container.name),
              subtitle: Text(container.status),
            ),
            const Divider(),
            if (container.isRunning) ...[
              _ActionTile(
                icon: Icons.pause,
                title: t('pause'),
                onTap: () => _operateContainer(container, 'pause'),
              ),
              _ActionTile(
                icon: Icons.stop,
                title: t('stop'),
                onTap: () => _operateContainer(container, 'stop'),
              ),
              _ActionTile(
                icon: Icons.restart_alt,
                title: t('restart'),
                onTap: () => _operateContainer(container, 'restart'),
              ),
            ],
            if (container.isPaused) ...[
              _ActionTile(
                icon: Icons.play_arrow,
                title: t('resume'),
                onTap: () => _operateContainer(container, 'unpause'),
              ),
            ],
            if (container.isExited || container.isCreated) ...[
              _ActionTile(
                icon: Icons.play_arrow,
                title: t('start'),
                onTap: () => _operateContainer(container, 'start'),
              ),
            ],
            _ActionTile(
              icon: Icons.delete,
              title: t('delete'),
              color: Colors.red,
              onTap: () => _operateContainer(container, 'delete'),
            ),
          ],
        ),
      ),
    );
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
                    : _containers.isEmpty
                        ? Center(child: Text(t('noContainersFound')))
                        : ListView.builder(
                            itemCount: _containers.length,
                            itemBuilder: (context, index) {
                              final container = _containers[index];
                              return _ContainerCard(
                                container: container,
                                onTap: () => _showContainerActions(container),
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
                hintText: t('searchContainersHint'),
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
            value: _filter,
            items: [
              DropdownMenuItem(value: 'all', child: Text(t('all'))),
              DropdownMenuItem(value: 'running', child: Text(t('running'))),
              DropdownMenuItem(value: 'paused', child: Text(t('paused'))),
              DropdownMenuItem(value: 'exited', child: Text(t('exited'))),
            ],
            onChanged: (v) {
              setState(() => _filter = v ?? 'all');
              _refresh();
            },
          ),
          RefreshIconButton(onPressed: _refresh),
        ],
      ),
    );
  }
}

class _ContainerCard extends StatelessWidget {
  final ContainerInfo container;
  final VoidCallback onTap;

  const _ContainerCard({
    required this.container,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = container.isRunning
        ? Colors.green
        : container.isPaused
            ? Colors.orange
            : Colors.grey;

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
            container.isRunning ? Icons.play_arrow : Icons.stop,
            color: statusColor,
          ),
        ),
        title: Text(
          container.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              container.image,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (container.ports != null) ...[
              const SizedBox(height: 4),
              Text(
                '${I18n.tr(context, 'ports')}: ${container.ports}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
        trailing: Chip(
          label: Text(
            container.status,
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
