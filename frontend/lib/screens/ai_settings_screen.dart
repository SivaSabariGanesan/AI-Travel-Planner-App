import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/api_client.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  String _aiMode = 'app';
  final _keyController = TextEditingController();
  bool _saving = false;
  bool _hasPersonalKey = false;
  bool _editingKey = false;
  bool _loadingSettings = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isAuthenticated) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in first')),
        );
        return;
      }

      // Initialize the local UI state from the current user so the
      // selected radio reflects the backend `aiMode` (e.g. 'byok').
      final userProv = context.read<UserProvider>();
      final api = context.read<ApiClient>();

      if (userProv.user != null && mounted) {
        setState(() => _aiMode = userProv.user!.aiMode);
      }

      // Fetch AI settings from backend to know if a personal key exists.
      try {
        final data = await api.getAiSettings();
        final ai = data['aiSettings'] as Map<String, dynamic>? ?? {};
        if (mounted) {
          setState(() {
            _hasPersonalKey = ai['hasPersonalKey'] == true;
            // sync aiMode if backend returns it
            if (ai['aiMode'] != null) _aiMode = ai['aiMode'];
          });
        }
      } catch (_) {
        // ignore errors; keep defaults
      } finally {
        if (mounted) setState(() => _loadingSettings = false);
      }
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProv = context.watch<UserProvider>();

    if (!authProvider.isAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Please log in first')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select AI Mode', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            RadioListTile<String>(
              value: 'app',
              groupValue: _aiMode,
              title: const Text('Use App AI (developer key)'),
              onChanged: (v) => setState(() => _aiMode = v ?? 'app'),
            ),
            RadioListTile<String>(
              value: 'byok',
              groupValue: _aiMode,
              title: const Text('Use My Gemini API Key (BYOK)'),
              onChanged: (v) => setState(() => _aiMode = v ?? 'byok'),
            ),
            const SizedBox(height: 12),
            if (_aiMode == 'byok') ...[
              const SizedBox(height: 8),
              if (_hasPersonalKey && !_editingKey)
                Row(
                  children: [
                    const Text('Gemini API Key is configured'),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => setState(() => _editingKey = true),
                      child: const Text('Update Key'),
                    ),
                  ],
                )
              else ...[
                TextField(
                  controller: _keyController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Gemini API Key',
                    hintText: 'Enter your Gemini API key',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: userProv.isLoading
                          ? null
                          : () async {
                              final key = _keyController.text.trim();
                              if (key.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Enter a key to test')),
                                );
                                return;
                              }

                              final ok = await userProv.testGeminiKey(key);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok ? 'Key is valid' : 'Key is invalid'),
                                ),
                              );
                            },
                      child: const Text('Test API Key'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: userProv.isLoading || _saving
                          ? null
                          : null,
                      child: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ],

            const SizedBox(height: 12),
            // Always show Save so users can switch modes without losing the option
            Row(
              children: [
                ElevatedButton(
                  onPressed: userProv.isLoading || _saving
                      ? null
                      : () async {
                          setState(() => _saving = true);

                          final gemini = (_aiMode == 'byok')
                              ? (_editingKey || _keyController.text.trim().isNotEmpty
                                  ? _keyController.text.trim()
                                  : null)
                              : null;

                          final resp = await userProv.updateAiSettings(
                            aiMode: _aiMode,
                            geminiApiKey: gemini,
                          );

                          setState(() {
                            _saving = false;
                            if (resp['success'] == true) {
                              _hasPersonalKey = resp['aiSettings']?['hasPersonalKey'] == true;
                              _editingKey = false;
                            }
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(resp['success'] == true ? 'Saved' : (userProv.error ?? (resp['message'] ?? 'Failed'))),
                            ),
                          );
                        },
                  child: _saving ? const CircularProgressIndicator() : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
