import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/data/models/server_info.dart';

class ServerAddPage extends StatefulWidget {
  final ServerInfo? server;

  const ServerAddPage({super.key, this.server});

  @override
  State<ServerAddPage> createState() => _ServerAddPageState();
}

class _ServerAddPageState extends State<ServerAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();

  bool _useSSL = false;
  bool _skipSSLVerify = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.server != null) {
      _nameController.text = widget.server!.name;
      _baseUrlController.text = widget.server!.baseUrl;
      _apiKeyController.text = widget.server!.apiKey;
      _usernameController.text = widget.server!.username ?? '';
      _passwordController.text = widget.server!.password ?? '';
      _notesController.text = widget.server!.notes ?? '';
      _useSSL = widget.server!.useSSL;
      _skipSSLVerify = widget.server!.skipSSLVerify;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final serverService = Provider.of<ServerService>(context, listen: false);

    try {
      if (widget.server != null) {
        await serverService.updateServer(widget.server!.id, {
          'name': _nameController.text.trim(),
          'baseUrl': _baseUrlController.text.trim(),
          'apiKey': _apiKeyController.text.trim(),
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
          'useSSL': _useSSL,
          'skipSSLVerify': _skipSSLVerify,
          'notes': _notesController.text.trim(),
        });
      } else {
        await serverService.addServer(
          name: _nameController.text.trim(),
          baseUrl: _baseUrlController.text.trim(),
          apiKey: _apiKeyController.text.trim(),
          username: _usernameController.text.trim().isNotEmpty
            ? _usernameController.text.trim()
            : null,
          password: _passwordController.text.trim().isNotEmpty
            ? _passwordController.text.trim()
            : null,
          useSSL: _useSSL,
          skipSSLVerify: _skipSSLVerify,
          notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final serverService = Provider.of<ServerService>(context, listen: false);
      
      // 临时添加服务器进行测试
      await serverService.addServer(
        name: 'Test Connection',
        baseUrl: _baseUrlController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        useSSL: _useSSL,
        skipSSLVerify: _skipSSLVerify,
      );

      // 测试连接
      final apiClient = OnePanelApiClient(serverService: serverService);
      apiClient.updateServerConfig(
        _baseUrlController.text.trim(),
        _skipSSLVerify,
      );

      await apiClient.getBaseInfo();

      // 删除测试服务器
      final servers = serverService.servers;
      if (servers.isNotEmpty) {
        await serverService.deleteServer(servers.last.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.server != null ? 'Edit Server' : 'Add Server'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              label: 'Server Name',
              hint: 'My Server',
              controller: _nameController,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              icon: Icons.label,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Base URL',
              hint: 'http://192.168.1.100:7800',
              controller: _baseUrlController,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!v.startsWith('http://') && !v.startsWith('https://')) {
                  return 'Must start with http:// or https://';
                }
                return null;
              },
              icon: Icons.link,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'API Key',
              hint: 'Enter API Key from 1Panel settings',
              controller: _apiKeyController,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              icon: Icons.key,
              obscure: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Username (optional)',
              hint: 'admin',
              controller: _usernameController,
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Password (optional)',
              hint: 'password',
              controller: _passwordController,
              icon: Icons.lock,
              obscure: true,
            ),
            const SizedBox(height: 16),
            _buildSSLSettings(),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Notes (optional)',
              hint: 'Production server',
              controller: _notesController,
              icon: Icons.note,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _testConnection,
                    child: const Text('Test Connection'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData icon,
    bool obscure = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _buildSSLSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SSL Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Use SSL/HTTPS'),
              subtitle: const Text('Connect using HTTPS'),
              value: _useSSL,
              onChanged: (v) => setState(() => _useSSL = v),
            ),
            SwitchListTile(
              title: const Text('Skip SSL Verification'),
              subtitle: const Text('Allow self-signed certificates'),
              value: _skipSSLVerify,
              onChanged: (v) => setState(() => _skipSSLVerify = v),
            ),
          ],
        ),
      ),
    );
  }
}
