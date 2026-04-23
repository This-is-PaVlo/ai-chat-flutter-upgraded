// Экран расходов по дням

import 'package:flutter/material.dart';

import '../services/database_service.dart';

class DailyCostChartScreen extends StatefulWidget {
  const DailyCostChartScreen({super.key});

  @override
  State<DailyCostChartScreen> createState() => _DailyCostChartScreenState();
}

class _DailyCostChartScreenState extends State<DailyCostChartScreen> {
  final DatabaseService _databaseService = DatabaseService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _dailyStats = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    final stats = await _databaseService.getDailyCostStats();

    if (!mounted) return;

    setState(() {
      _dailyStats = stats;
      _isLoading = false;
    });
  }

  Widget _buildBar(double value, double maxValue) {
    final ratio = maxValue > 0 ? value / maxValue : 0.0;
    final widthFactor = ratio.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 18,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Container(
              height: 18,
              width: constraints.maxWidth * widthFactor,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDayCard(Map<String, dynamic> item, double maxCost) {
    final day = item['day']?.toString() ?? '-';
    final messageCount = item['message_count'] ?? 0;
    final totalTokens = item['total_tokens'] ?? 0;
    final totalCost = (item['total_cost'] as num?)?.toDouble() ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildBar(totalCost, maxCost),
            const SizedBox(height: 12),
            Text('Сообщений: $messageCount'),
            Text('Токенов: $totalTokens'),
            Text('Расход: ${totalCost.toStringAsFixed(4)}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxCost = _dailyStats.isEmpty
        ? 0.0
        : _dailyStats
            .map((e) => (e['total_cost'] as num?)?.toDouble() ?? 0.0)
            .reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('График расходов'),
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
                  const Text(
                    'Расходы по дням',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_dailyStats.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Пока нет данных по расходам.'),
                      ),
                    )
                  else
                    ..._dailyStats.map((item) => _buildDayCard(item, maxCost)),
                ],
              ),
            ),
    );
  }
}
