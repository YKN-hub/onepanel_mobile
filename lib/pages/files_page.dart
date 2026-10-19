import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/api/v2/api_client.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/data/models/file_models.dart';
import 'package:onepanel_mobile/widgets/shimmer_loader.dart';
import 'package:onepanel_mobile/widgets/refresh_icon_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  late OnePanelApiClient _apiClient;
  bool _isLoading = true;
  List<FileInfo> _files = [];
  String? _error;
  String _currentPath = '/';
  String _search = '';

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
      final files = await _apiClient.getFileList(_currentPath);
      
      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Files', 'Failed to load: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateTo(String path) async {
    setState(() {
      _currentPath = path;
    });
    _refresh();
  }

  Future<void> _createFile(bool isDir) async {
    final name = await _showCreateDialog(isDir);
    if (name == null || name.isEmpty) return;

    final path = _currentPath == '/' 
      ? '/$name' 
      : '${_currentPath}/$name';

    try {
      await _apiClient.createFile(path, isDir);
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<String?> _showCreateDialog(bool isDir) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDir ? 'Create Directory' : 'Create File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _deleteFile(FileInfo file) async {
    final path = _currentPath == '/' 
      ? '/${file.name}' 
      : '${_currentPath}/${file.name}';

    try {
      await _apiClient.deleteFile(path);
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _renameFile(FileInfo file) async {
    final newName = await _showRenameDialog(file.name);
    if (newName == null || newName.isEmpty) return;

    final oldPath = _currentPath == '/' 
      ? '/${file.name}' 
      : '${_currentPath}/${file.name}';
    final newPath = _currentPath == '/' 
      ? '/$newName' 
      : '${_currentPath}/$newName';

    try {
      await _apiClient.renameFile(oldPath, newPath);
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<String?> _showRenameDialog(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    return result;
  }

  void _showFileActions(FileInfo file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(file.name),
              subtitle: Text(file.isDir ? 'Directory' : 'File'),
            ),
            const Divider(),
            if (file.isDir) ...[
              _ActionTile(
                icon: Icons.folder_open,
                title: 'Open',
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateTo(_currentPath == '/' 
                    ? '/${file.name}' 
                    : '${_currentPath}/${file.name}');
                },
              ),
            ],
            if (file.isFile) ...[
              _ActionTile(
                icon: Icons.visibility,
                title: 'View',
                onTap: () {
                  Navigator.of(context).pop();
                  _viewFile(file);
                },
              ),
            ],
            _ActionTile(
              icon: Icons.edit,
              title: 'Rename',
              onTap: () {
                Navigator.of(context).pop();
                _renameFile(file);
              },
            ),
            _ActionTile(
              icon: Icons.delete,
              title: 'Delete',
              color: Colors.red,
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(FileInfo file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteFile(file);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _viewFile(FileInfo file) async {
    final path = _currentPath == '/' 
      ? '/${file.name}' 
      : '${_currentPath}/${file.name}';

    try {
      final content = await _apiClient.readFileContent(path);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(file.name),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SelectableText(content),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPathBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(),
            child: _isLoading
              ? const ShimmerLoader()
              : _error != null
                ? Center(child: Text('Error: $_error'))
                : _files.isEmpty
                  ? const Center(child: Text('No files found'))
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        return _FileCard(
                          file: file,
                          onTap: () => _showFileActions(file),
                        );
                      },
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildPathBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => _navigateTo('/'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    _currentPath,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              RefreshIconButton(onPressed: _refresh),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.create_new_folder),
                onPressed: () => _createFile(true),
                tooltip: 'New Folder',
              ),
              IconButton(
                icon: const Icon(Icons.note_add),
                onPressed: () => _createFile(false),
                tooltip: 'New File',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  final FileInfo file;
  final VoidCallback onTap;

  const _FileCard({
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = file.isDir ? Icons.folder : Icons.insert_drive_file;
    final color = file.isDir 
      ? Theme.of(context).colorScheme.primary 
      : Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: file.isDir 
              ? Theme.of(context).colorScheme.primary.withAlpha(50)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          file.name,
          style: file.isDir 
            ? const TextStyle(fontWeight: FontWeight.bold)
            : null,
        ),
        subtitle: file.isDir 
          ? null
          : Text(
              file.sizeDisplay,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        trailing: file.isDir 
          ? const Icon(Icons.chevron_right)
          : null,
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
