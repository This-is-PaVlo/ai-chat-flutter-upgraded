// Сервис хранения конфигурации провайдера и API-ключа

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/provider_config.dart';

class ProviderConfigService {
  static const String _configKey = 'provider_config';

  // Загрузка сохраненной конфигурации
  Future<ProviderConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final rawConfig = prefs.getString(_configKey);

    if (rawConfig == null || rawConfig.isEmpty) {
      return ProviderConfig.empty();
    }

    try {
      final decoded = jsonDecode(rawConfig) as Map<String, dynamic>;
      return ProviderConfig.fromMap(decoded);
    } catch (_) {
      return ProviderConfig.empty();
    }
  }

  // Сохранение конфигурации
  Future<void> saveConfig(ProviderConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, jsonEncode(config.toMap()));
  }

  // Сброс конфигурации
  Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_configKey);
  }
}
