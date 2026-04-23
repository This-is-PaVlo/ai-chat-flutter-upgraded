// Модель конфигурации провайдера API

enum ApiProviderType {
  openRouter,
  vsegpt,
}

class ProviderConfig {
  final ApiProviderType provider;
  final String apiKey;
  final String baseUrl;
  final bool isConfigured;

  const ProviderConfig({
    required this.provider,
    required this.apiKey,
    required this.baseUrl,
    required this.isConfigured,
  });

  // Пустая конфигурация по умолчанию
  factory ProviderConfig.empty() {
    return const ProviderConfig(
      provider: ApiProviderType.openRouter,
      apiKey: '',
      baseUrl: 'https://openrouter.ai/api/v1',
      isConfigured: false,
    );
  }

  // Определение провайдера по ключу
  factory ProviderConfig.fromApiKey(String apiKey) {
    final trimmedKey = apiKey.trim();

    if (trimmedKey.startsWith('sk-or-vv-')) {
      return ProviderConfig(
        provider: ApiProviderType.vsegpt,
        apiKey: trimmedKey,
        baseUrl: 'https://api.vsegpt.ru/v1',
        isConfigured: true,
      );
    }

    return ProviderConfig(
      provider: ApiProviderType.openRouter,
      apiKey: trimmedKey,
      baseUrl: 'https://openrouter.ai/api/v1',
      isConfigured: trimmedKey.isNotEmpty,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provider': provider.name,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'isConfigured': isConfigured,
    };
  }

  factory ProviderConfig.fromMap(Map<String, dynamic> map) {
    final providerName = map['provider'] as String? ?? 'openRouter';

    return ProviderConfig(
      provider: providerName == 'vsegpt'
          ? ApiProviderType.vsegpt
          : ApiProviderType.openRouter,
      apiKey: map['apiKey'] as String? ?? '',
      baseUrl: map['baseUrl'] as String? ?? 'https://openrouter.ai/api/v1',
      isConfigured: map['isConfigured'] as bool? ?? false,
    );
  }

  ProviderConfig copyWith({
    ApiProviderType? provider,
    String? apiKey,
    String? baseUrl,
    bool? isConfigured,
  }) {
    return ProviderConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }
}
