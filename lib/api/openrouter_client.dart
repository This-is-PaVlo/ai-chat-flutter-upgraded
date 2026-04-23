// Import JSON library
import 'dart:convert';
// Import HTTP client
import 'package:http/http.dart' as http;
// Import Flutter core classes
import 'package:flutter/foundation.dart';
// Import package for working with .env files
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Клиент для работы с OpenRouter и VSEGPT
class OpenRouterClient {
  String? _apiKey;
  String? _baseUrl;

  OpenRouterClient({
    String? apiKey,
    String? baseUrl,
  }) {
    _apiKey = apiKey ?? dotenv.env['OPENROUTER_API_KEY'];
    _baseUrl = baseUrl ?? dotenv.env['BASE_URL'];
  }

  String? get apiKey => _apiKey;
  String? get baseUrl => _baseUrl;

  Map<String, String> get headers {
    return {
      'Authorization': 'Bearer ${_apiKey ?? ''}',
      'Content-Type': 'application/json',
      'X-Title': 'AI Chat Flutter',
    };
  }

  // Обновление конфигурации клиента из приложения
  void updateConfig({
    required String apiKey,
    required String baseUrl,
  }) {
    _apiKey = apiKey.trim();
    _baseUrl = baseUrl.trim();
  }

  // Проверка готовности клиента
  bool get isConfigured {
    return (_apiKey ?? '').trim().isNotEmpty &&
        (_baseUrl ?? '').trim().isNotEmpty;
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw Exception('API client is not configured');
    }
  }

  // Метод получения списка доступных моделей
  Future<List<Map<String, dynamic>>> getModels() async {
    try {
      _ensureConfigured();

      final response = await http.get(
        Uri.parse('${_baseUrl!}/models'),
        headers: headers,
      );

      if (kDebugMode) {
        print('Models response status: ${response.statusCode}');
        print('Models response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final modelsData = json.decode(response.body);
        if (modelsData['data'] != null) {
          return (modelsData['data'] as List)
              .map((model) => {
                    'id': model['id'] as String,
                    'name': (() {
                      try {
                        return utf8.decode((model['name'] as String).codeUnits);
                      } catch (_) {
                        final cleaned = (model['name'] as String)
                            .replaceAll(RegExp(r'[^\x00-\x7F]'), '');
                        return utf8.decode(cleaned.codeUnits);
                      }
                    })(),
                    'pricing': {
                      'prompt': model['pricing']?['prompt']?.toString() ?? '0',
                      'completion':
                          model['pricing']?['completion']?.toString() ?? '0',
                    },
                    'context_length': (model['context_length'] ??
                            model['top_provider']?['context_length'] ??
                            0)
                        .toString(),
                  })
              .toList();
        }
        throw Exception('Invalid API response format');
      } else {
        return [
          {'id': 'deepseek/deepseek-chat-v3-0324:free', 'name': 'DeepSeek'},
          {'id': 'openai/gpt-4o-mini', 'name': 'GPT-4o mini'},
          {'id': 'anthropic/claude-3.5-sonnet', 'name': 'Claude 3.5 Sonnet'},
        ];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting models: $e');
      }
      return [
        {'id': 'deepseek/deepseek-chat-v3-0324:free', 'name': 'DeepSeek'},
        {'id': 'openai/gpt-4o-mini', 'name': 'GPT-4o mini'},
        {'id': 'anthropic/claude-3.5-sonnet', 'name': 'Claude 3.5 Sonnet'},
      ];
    }
  }

  // Метод отправки сообщения через API
  Future<Map<String, dynamic>> sendMessage(String message, String model) async {
    try {
      _ensureConfigured();

      final data = {
        'model': model,
        'messages': [
          {'role': 'user', 'content': message}
        ],
        'max_tokens': int.parse(dotenv.env['MAX_TOKENS'] ?? '1000'),
        'temperature': double.parse(dotenv.env['TEMPERATURE'] ?? '0.7'),
        'stream': false,
      };

      if (kDebugMode) {
        print('Sending message to API: ${json.encode(data)}');
      }

      final response = await http.post(
        Uri.parse('${_baseUrl!}/chat/completions'),
        headers: headers,
        body: json.encode(data),
      );

      if (kDebugMode) {
        print('Message response status: ${response.statusCode}');
        print('Message response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        return responseData;
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        return {
          'error': errorData['error']?['message'] ?? 'Unknown error occurred'
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      return {'error': e.toString()};
    }
  }

  // Метод получения текущего баланса
  Future<String> getBalance() async {
    try {
      _ensureConfigured();

      final isVsegpt = _baseUrl?.contains('vsegpt.ru') == true;

      final response = await http.get(
        Uri.parse(isVsegpt ? '${_baseUrl!}/balance' : '${_baseUrl!}/credits'),
        headers: headers,
      );

      if (kDebugMode) {
        print('Balance response status: ${response.statusCode}');
        print('Balance response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['data'] != null) {
          if (isVsegpt) {
            final credits =
                double.tryParse(data['data']['credits'].toString()) ?? 0.0;
            return '${credits.toStringAsFixed(2)}₽';
          } else {
            final credits =
                double.tryParse(data['data']['total_credits'].toString()) ??
                    0.0;
            final usage =
                double.tryParse(data['data']['total_usage'].toString()) ?? 0.0;
            return '\$${(credits - usage).toStringAsFixed(2)}';
          }
        }
      }

      return isVsegpt ? '0.00₽' : '\$0.00';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting balance: $e');
      }
      return 'Error';
    }
  }

  String formatPricing(double pricing) {
    try {
      if (_baseUrl?.contains('vsegpt.ru') == true) {
        return '${pricing.toStringAsFixed(3)}₽/K';
      } else {
        return '\$${(pricing * 1000000).toStringAsFixed(3)}/M';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting pricing: $e');
      }
      return '0.00';
    }
  }
}
