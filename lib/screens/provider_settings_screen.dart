// Экран настроек провайдера и API-ключа

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

class ProviderSettingsScreen extends StatefulWidget {
  const ProviderSettingsScreen({super.key});

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isSaving = false;
  String? _statusMessage;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final provider = context.read<ChatProvider>();
    final apiKey = _apiKeyController.text.trim();

    if (apiKey.isEmpty) {
      setState(() {
        _statusMessage = 'Введите API-ключ.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    final success = await provider.applyApiKey(apiKey);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _statusMessage = success
          ? 'Ключ сохранен. Провайдер: ${provider.providerDisplayName}'
          : 'Не удалось применить ключ. Проверьте ключ и баланс.';
    });
  }

  Future<void> _resetApiKey() async {
    final provider = context.read<ChatProvider>();

    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    await provider.resetProviderConfig();

    if (!mounted) return;

    _apiKeyController.clear();

    setState(() {
      _isSaving = false;
      _statusMessage = 'Конфигурация провайдера сброшена.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки провайдера'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Текущая конфигурация',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Провайдер: ${provider.providerDisplayName}'),
                    const SizedBox(height: 8),
                    Text(
                      'Статус: ${provider.isConfigured ? "настроен" : "не настроен"}',
                    ),
                    const SizedBox(height: 8),
                    Text('Base URL: ${provider.baseUrl ?? "-"}'),
                    const SizedBox(height: 8),
                    Text('Баланс: ${provider.balance}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API-ключ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ключ VSEGPT начинается с sk-or-vv-..., ключ OpenRouter с sk-or-v1-...',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Введите API-ключ',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _isSaving ? null : _saveApiKey,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Сохранить ключ'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving ? null : _resetApiKey,
                            child: const Text('Сбросить'),
                          ),
                        ),
                      ],
                    ),
                    if (_statusMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(_statusMessage!),
                    ],
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
