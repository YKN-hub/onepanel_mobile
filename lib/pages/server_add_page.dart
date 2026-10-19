import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/api/v2/api_client.dart';
import 'package:onepanel_mobile/core/i18n/i18n.dart';
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

  bool _useSSL = true;
  bool _skipSSLVerify = false;
  bool _isTesting = false;
  bool _isSaving = false;

  String t(String key) => I18n.tr(context, key);

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

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final serverService = Provider.of<ServerService>(context, listen: false);

    try {
      if (widget.server != null) {
        await serverService.updateServer(widget.server!.id, {
          'name': _nameController.text.trim(),
          'baseUrl': _baseUrlController.text.trim(),
          'apiKey': _apiKeyController.text.trim(),
          'username': _usernameController.text.trim().isNotEmpty
              ? _usernameController.text.trim()
              : null,
          'password': _passwordController.text.trim().isNotEmpty
              ? _passwordController.text.trim()
              : null,
          'useSSL': _useSSL,
          'skipSSLVerify': _skipSSLVerify,
          'notes': _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
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
      _showSnack('${t('error')}: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isTesting = true);
    final error = await OnePanelApiClient.testConnection(
      baseUrl: _baseUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      useSSL: _useSSL,
      skipSSLVerify: _skipSSLVerify,
    );

    if (mounted) {
      setState(() => _isTesting = false);
      _showSnack(error == null ? t('connectionSuccess') : '${t('connectionFailed')}: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.server != null ? t('editServer') : t('addServer')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              label: t('serverName'),
              hint: t('myServerHint'),
              controller: _nameController,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? t('nameRequired') : null,
              icon: Icons.label,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: t('baseUrl'),
              hint: t('urlHint'),
              controller: _baseUrlController,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return t('urlRequired');
                final s = v.trim();
                if (!s.startsWith('http://') && !s.startsWith('https://')) {
                  return t('urlFormat');
                }
                return null;
              },
              icon: Icons.link,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: t('apiKey'),
              hint: t('keyHint'),
              controller: _apiKeyController,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? t('keyRequired') : null,
              icon: Icons.key,
              obscure: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: t('usernameHint'),
              hint: 'admin',
              controller: _usernameController,
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: t('passwordHint'),
              hint: '******',
              controller: _passwordController,
              icon: Icons.lock,
              obscure: true,
            ),
            const SizedBox(height: 16),
            _buildSSLSettings(),
            const SizedBox(height: 16),
            _buildTextField(
              label: t('notesHint'),
              hint: '',
              controller: _notesController,
              icon: Icons.note,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isTesting ? null : _testConnection,
                    child: _isTesting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t('testConnection')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t('save')),
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
    required IconData icon,
    String? Function(String?)? validator,
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
              t('sslSettings'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t('useSSL')),
              value: _useSSL,
              onChanged: (v) => setState(() => _useSSL = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t('skipSSLVerify')),
              subtitle: Text(t('allowSelfSigned')),
              value: _skipSSLVerify,
              onChanged: (v) => setState(() => _skipSSLVerify = v),
            ),
          ],
        ),
      ),
    );
  }
}
