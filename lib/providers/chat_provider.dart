// Импорт библиотеки для работы с JSON
import 'dart:convert';
// Импорт библиотеки для работы с файловой системой
import 'dart:io';
// Импорт основных классов Flutter
import 'package:flutter/foundation.dart';
// Импорт пакета для получения путей к директориям
import 'package:path_provider/path_provider.dart';

// Импорт модели сообщения
import '../models/message.dart';
import '../models/provider_config.dart';
// Импорт клиента для работы с API
import '../api/openrouter_client.dart';
// Импорт сервиса для работы с базой данных
import '../services/database_service.dart';
// Импорт сервиса для аналитики
import '../services/analytics_service.dart';
import '../services/provider_config_service.dart';

// Основной класс провайдера для управления состоянием чата
class ChatProvider with ChangeNotifier {
  // Клиент для работы с API
  final OpenRouterClient _api = OpenRouterClient();
  // Список сообщений чата
  final List<ChatMessage> _messages = [];
  // Логи для отладки
  final List<String> _debugLogs = [];
  // Список доступных моделей
  List<Map<String, dynamic>> _availableModels = [];
  // Текущая выбранная модель
  String? _currentModel;
  // Баланс пользователя
  String _balance = '\$0.00';
  // Флаг загрузки
  bool _isLoading = false;

  // Сервис для работы с базой данных
  final DatabaseService _db = DatabaseService();
  // Сервис для сбора аналитики
  final AnalyticsService _analytics = AnalyticsService();
  // Сервис хранения конфигурации провайдера
  final ProviderConfigService _configService = ProviderConfigService();

  // Текущая конфигурация провайдера
  ProviderConfig _providerConfig = ProviderConfig.empty();

  // Метод для логирования сообщений
  void _log(String message) {
    _debugLogs.add('${DateTime.now()}: $message');
    debugPrint(message);
  }

  // Геттеры
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<Map<String, dynamic>> get availableModels => _availableModels;
  String? get currentModel => _currentModel;
  String get balance => _balance;
  bool get isLoading => _isLoading;
  String? get baseUrl => _api.baseUrl;
  ProviderConfig get providerConfig => _providerConfig;
  bool get isConfigured => _providerConfig.isConfigured;
  bool get isVsegpt => _providerConfig.provider == ApiProviderType.vsegpt;
  String get providerDisplayName => isVsegpt ? 'VSEGPT' : 'OpenRouter';

  // Конструктор провайдера
  ChatProvider() {
    _initializeProvider();
  }

  // Метод инициализации провайдера
  Future<void> _initializeProvider() async {
    try {
      _log('Initializing provider...');

      // Загружаем сохраненную конфигурацию
      _providerConfig = await _configService.loadConfig();

      if (_providerConfig.isConfigured) {
        _api.updateConfig(
          apiKey: _providerConfig.apiKey,
          baseUrl: _providerConfig.baseUrl,
        );
        _log(
          'Loaded provider config: ${_providerConfig.provider.name}, ${_providerConfig.baseUrl}',
        );
      } else {
        _log('Provider config is empty');
      }

      // Историю загружаем всегда
      await _loadHistory();
      _log('History loaded: ${_messages.length} messages');

      // Модели и баланс загружаем только если клиент настроен
      if (_providerConfig.isConfigured) {
        await _loadModels();
        _log('Models loaded: $_availableModels');

        await _loadBalance();
        _log('Balance loaded: $_balance');
      }
    } catch (e, stackTrace) {
      _log('Error initializing provider: $e');
      _log('Stack trace: $stackTrace');
    } finally {
      notifyListeners();
    }
  }

  // Применение новой конфигурации из введенного ключа
  Future<bool> applyApiKey(String apiKey) async {
    try {
      final config = ProviderConfig.fromApiKey(apiKey);

      _api.updateConfig(
        apiKey: config.apiKey,
        baseUrl: config.baseUrl,
      );

      // Проверяем доступность API и валидность ключа через баланс
      final loadedBalance = await _api.getBalance();
      if (loadedBalance == 'Error') {
        return false;
      }

      _providerConfig = config;
      await _configService.saveConfig(_providerConfig);

      _currentModel = null;
      _availableModels = [];
      _balance = loadedBalance;

      await _loadModels();

      notifyListeners();
      return true;
    } catch (e) {
      _log('Error applying API key: $e');
      return false;
    }
  }

  // Сброс текущей конфигурации
  Future<void> resetProviderConfig() async {
    try {
      _providerConfig = ProviderConfig.empty();
      await _configService.clearConfig();

      _availableModels = [];
      _currentModel = null;
      _balance = '\$0.00';

      notifyListeners();
    } catch (e) {
      _log('Error resetting provider config: $e');
    }
  }

  // Метод загрузки доступных моделей
  Future<void> _loadModels() async {
    try {
      if (!_providerConfig.isConfigured) return;

      _availableModels = await _api.getModels();
      _availableModels.sort(
        (a, b) => (a['name'] as String).compareTo(b['name'] as String),
      );

      if (_availableModels.isNotEmpty &&
          (_currentModel == null ||
              !_availableModels.any((m) => m['id'] == _currentModel))) {
        _currentModel = _availableModels[0]['id'] as String;
      }

      notifyListeners();
    } catch (e) {
      _log('Error loading models: $e');
    }
  }

  // Метод загрузки баланса пользователя
  Future<void> _loadBalance() async {
    try {
      if (!_providerConfig.isConfigured) return;

      _balance = await _api.getBalance();
      notifyListeners();
    } catch (e) {
      _log('Error loading balance: $e');
    }
  }

  // Публичный метод обновления баланса
  Future<void> refreshBalance() async {
    await _loadBalance();
  }

  // Метод загрузки истории сообщений
  Future<void> _loadHistory() async {
    try {
      final messages = await _db.getMessages();
      _messages.clear();
      _messages.addAll(messages);
      notifyListeners();
    } catch (e) {
      _log('Error loading history: $e');
    }
  }

  // Метод сохранения сообщения в базу данных
  Future<void> _saveMessage(ChatMessage message) async {
    try {
      await _db.saveMessage(message);
    } catch (e) {
      _log('Error saving message: $e');
    }
  }

  // Метод отправки сообщения
  Future<void> sendMessage(String content, {bool trackAnalytics = true}) async {
    if (!_providerConfig.isConfigured) {
      final errorMessage = ChatMessage(
        content: 'Сначала настройте провайдера и API-ключ.',
        isUser: false,
        modelId: _currentModel,
      );
      _messages.add(errorMessage);
      notifyListeners();
      return;
    }

    if (content.trim().isEmpty || _currentModel == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      content = utf8.decode(utf8.encode(content));

      final userMessage = ChatMessage(
        content: content,
        isUser: true,
        modelId: _currentModel,
      );
      _messages.add(userMessage);
      notifyListeners();

      await _saveMessage(userMessage);

      final startTime = DateTime.now();

      final response = await _api.sendMessage(content, _currentModel!);
      _log('API Response: $response');

      final responseTime =
          DateTime.now().difference(startTime).inMilliseconds / 1000;

      if (response.containsKey('error')) {
        final errorMessage = ChatMessage(
          content: utf8.decode(utf8.encode('Error: ${response['error']}')),
          isUser: false,
          modelId: _currentModel,
        );
        _messages.add(errorMessage);
        await _saveMessage(errorMessage);
      } else if (response.containsKey('choices') &&
          response['choices'] is List &&
          response['choices'].isNotEmpty &&
          response['choices'][0] is Map &&
          response['choices'][0].containsKey('message') &&
          response['choices'][0]['message'] is Map &&
          response['choices'][0]['message'].containsKey('content')) {
        final aiContent = utf8.decode(
          utf8.encode(response['choices'][0]['message']['content'] as String),
        );
        final tokens = response['usage']?['total_tokens'] as int? ?? 0;

        if (trackAnalytics) {
          _analytics.trackMessage(
            model: _currentModel!,
            messageLength: content.length,
            responseTime: responseTime,
            tokensUsed: tokens,
          );
        }

        final promptTokens = response['usage']?['prompt_tokens'] ?? 0;
        final completionTokens = response['usage']?['completion_tokens'] ?? 0;
        final totalCost = response['usage']?['total_cost'];

        final Map<String, dynamic> model =
            _availableModels.cast<Map<String, dynamic>>().firstWhere(
                  (model) => model['id'] == _currentModel,
                  orElse: () => <String, dynamic>{
                    'id': _currentModel,
                    'name': 'Unknown model',
                    'pricing': <String, dynamic>{
                      'prompt': '0',
                      'completion': '0',
                    },
                  },
                );

        final promptPrice =
            double.tryParse(model['pricing']?['prompt']?.toString() ?? '0') ??
                0.0;
        final completionPrice = double.tryParse(
                model['pricing']?['completion']?.toString() ?? '0') ??
            0.0;

        final double cost;

        if (totalCost != null) {
          cost = (totalCost as num).toDouble();
        } else {
          if (isVsegpt) {
            // VSEGPT отдает цену в рублях за 1000 токенов
            cost = ((promptTokens / 1000) * promptPrice) +
                ((completionTokens / 1000) * completionPrice);
          } else {
            // OpenRouter обычно отдает цену в долларах за 1M токенов
            cost = ((promptTokens / 1000000) * promptPrice) +
                ((completionTokens / 1000000) * completionPrice);
          }
        }

        _log('Cost Response: $cost');

        final aiMessage = ChatMessage(
          content: aiContent,
          isUser: false,
          modelId: _currentModel,
          tokens: tokens,
          cost: cost,
        );
        _messages.add(aiMessage);
        await _saveMessage(aiMessage);

        await _loadBalance();
      } else {
        throw Exception('Invalid API response format');
      }
    } catch (e) {
      _log('Error sending message: $e');
      final errorMessage = ChatMessage(
        content: utf8.decode(utf8.encode('Error: $e')),
        isUser: false,
        modelId: _currentModel,
      );
      _messages.add(errorMessage);
      await _saveMessage(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Метод установки текущей модели
  void setCurrentModel(String modelId) {
    _currentModel = modelId;
    notifyListeners();
  }

  // Метод очистки истории
  Future<void> clearHistory() async {
    _messages.clear();
    await _db.clearHistory();
    _analytics.clearData();
    notifyListeners();
  }

  // Метод экспорта логов
  Future<String> exportLogs() async {
    final directory = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final fileName =
        'chat_logs_${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}.txt';
    final file = File('${directory.path}/$fileName');

    final buffer = StringBuffer();
    buffer.writeln('=== Debug Logs ===\n');
    for (final log in _debugLogs) {
      buffer.writeln(log);
    }

    buffer.writeln('\n=== Chat Logs ===\n');
    buffer.writeln('Generated: ${now.toString()}\n');

    for (final message in _messages) {
      buffer.writeln('${message.isUser ? "User" : "AI"} (${message.modelId}):');
      buffer.writeln(message.content);
      if (message.tokens != null) {
        buffer.writeln('Tokens: ${message.tokens}');
      }
      buffer.writeln('Time: ${message.timestamp}');
      buffer.writeln('---\n');
    }

    await file.writeAsString(buffer.toString());
    return file.path;
  }

  // Метод экспорта сообщений в формате JSON
  Future<String> exportMessagesAsJson() async {
    final directory = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final fileName =
        'chat_history_${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}.json';
    final file = File('${directory.path}/$fileName');

    final List<Map<String, dynamic>> messagesJson =
        _messages.map((message) => message.toJson()).toList();

    await file.writeAsString(jsonEncode(messagesJson));
    return file.path;
  }

  String formatPricing(double pricing) {
    return _api.formatPricing(pricing);
  }

  // Метод экспорта истории
  Future<Map<String, dynamic>> exportHistory() async {
    final dbStats = await _db.getStatistics();
    final analyticsStats = _analytics.getStatistics();
    final sessionData = _analytics.exportSessionData();
    final modelEfficiency = _analytics.getModelEfficiency();
    final responseTimeStats = _analytics.getResponseTimeStats();
    final messageLengthStats = _analytics.getMessageLengthStats();

    return {
      'database_stats': dbStats,
      'analytics_stats': analyticsStats,
      'session_data': sessionData,
      'model_efficiency': modelEfficiency,
      'response_time_stats': responseTimeStats,
      'message_length_stats': messageLengthStats,
    };
  }
}
