import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_client.dart';

class UsageScreen extends StatefulWidget {
  const UsageScreen({Key? key}) : super(key: key);

  @override
  State<UsageScreen> createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
  bool _loading = true;
  String? _error;
  int _usageCount = 0;
  DateTime? _lastUsedAt;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiClient>();
    try {
      final data = await api.getAiSettings();
      final ai = data['aiSettings'] as Map<String, dynamic>? ?? {};
      setState(() {
        _usageCount = ai['usageCount'] ?? 0;
        _lastUsedAt = ai['lastUsedAt'] != null ? DateTime.parse(ai['lastUsedAt']) : null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Usage')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Usage Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          title: const Text('Total AI Requests'),
                          trailing: Text('$_usageCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          title: const Text('Last AI Usage'),
                          trailing: Text(
                            _lastUsedAt != null ? DateFormat.yMMMd().add_jm().format(_lastUsedAt!) : 'Never',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetch,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
      ),
    );
  }
}
