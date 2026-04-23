// Экран статистики использования токенов

import 'package:flutter/material.dart';

import '../services/database_service.dart';

class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({super.key});

  @override
  State<UsageStatsScreen> createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
  final DatabaseService _databaseService = DatabaseService();

  bool _isLoading = true;
  Map<String, dynamic> _summaryStats = {};
  List<Map<String, dynamic>> _modelStats = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    final summary = await _databaseService.getStatistics();
    final models = await _databaseService.getModelUsageStats();

    if (!mounted) return;

    setState(() {
      _summaryStats = summary;
      _modelStats = models;
      _isLoading = false;
    });
  }

  Widget _buildSummaryCard() {
    final totalMessages = _summaryStats['total_messages'] ?? 0;
    final totalTokens = _summaryStats['total_tokens'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Общая статистика',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Всего сообщений: $totalMessages'),
            const SizedBox(height: 8),
            Text('Всего токенов: $totalTokens'),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCard(Map<String, dynamic> model) {
    final modelId = model['model_id']?.toString() ?? '-';
    final messageCount = model['message_count'] ?? 0;
    final totalTokens = model['total_tokens'] ?? 0;
    final totalCost = model['total_cost'] ?? 0.0;

    return Card(
      child: ListTile(
        title: Text(
          modelId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Сообщений: $messageCount'),
              Text('Токенов: $totalTokens'),
              Text('Суммарная стоимость: ${totalCost.toStringAsFixed(4)}'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика токенов'),
        actions: [
          IconButton(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  const Text(
                    'Статистика по моделям',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_modelStats.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Пока нет данных по моделям.'),
                      ),
                    )
                  else
                    ..._modelStats.map(_buildModelCard),
                ],
              ),
            ),
    );
  }
}
