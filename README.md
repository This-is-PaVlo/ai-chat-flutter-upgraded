# AIChatFlutter - Flutter AI Chat Application Enhancement

## English

### Overview

This project is an enhanced version of the existing AIChatFlutter mobile application built with Flutter.

The application was redesigned into a multi-page architecture and extended with:
- provider configuration support
- token usage analytics
- daily cost statistics
- local data storage
- provider auto-detection

The project works with AI providers through HTTP APIs.

Supported providers:
- OpenRouter
- VSEGPT

---

## Implemented Features

The following improvements were implemented:

- multi-page application structure
- bottom navigation with 4 screens
- provider settings screen
- API key management
- automatic provider detection
- provider configuration persistence using SharedPreferences
- updated API client architecture
- token usage statistics screen
- daily expenses analytics
- SQLite storage for messages and analytics
- fixed cost calculation for VSEGPT
- compatibility fixes for modern Flutter versions

---

## Main Functionality

### Chat Screen
- AI chat interface
- model selection
- token usage display
- response cost display
- chat history export
- chat clearing

### Provider Settings Screen
- API key input
- OpenRouter / VSEGPT auto-detection
- provider configuration saving
- current provider display
- balance display

### Usage Statistics Screen
- total messages count
- total token usage
- per-model statistics
- total model costs

### Daily Cost Screen
- daily expenses
- daily message count
- daily token usage
- visual analytics charts

---

## Technologies

- Flutter
- Dart
- Provider
- SQLite (`sqflite`)
- SharedPreferences
- HTTP API
- OpenRouter
- VSEGPT

---

## Project Structure

```text
lib/
  api/
    openrouter_client.dart
  models/
    message.dart
    provider_config.dart
  providers/
    chat_provider.dart
  screens/
    chat_screen.dart
    home_shell_screen.dart
    provider_settings_screen.dart
    usage_stats_screen.dart
    daily_cost_chart_screen.dart
  services/
    analytics_service.dart
    database_service.dart
    provider_config_service.dart
  main.dart
```

---

## Installation

Clone repository:

```bash
git clone <your_repository_url>
cd AIChatFlutter
```

Install dependencies:

```bash
flutter pub get
```

Create `.env` file based on `.env.example`

Run project:

```bash
flutter run
```

The project was tested on Android Emulator API 35.

---

## Screenshots

### Main Chat Screen
<img width="390" height="895" alt="Main Screen" src="https://github.com/user-attachments/assets/3d2bf53b-12bc-458b-8b0f-9959a84cafab" />

### Provider Settings
<img width="390" height="895" alt="Provider Settings" src="https://github.com/user-attachments/assets/87e4c203-f522-40e1-9513-15c12d79e78c" />

### Usage Statistics
<img width="390" height="895" alt="Usage Statistics" src="https://github.com/user-attachments/assets/3689c791-2e3e-4d00-9591-3394db48e151" />

### Daily Costs
<img width="390" height="895" alt="Daily Costs" src="https://github.com/user-attachments/assets/32ae8aa1-2291-45df-9f11-3f9a73d5a060" />

---

## Note

The project was created based on the existing educational repository AIChatFlutter.

The main goal was not to create the application from scratch, but to redesign and extend the existing architecture with additional functionality.

---

## Original Project

Original educational project:
https://github.com/neuro-fill/AIChatFlutter

---

## Result

The final result is a multi-page Flutter AI chat application with:
- AI chat functionality
- provider configuration support
- token tracking
- request cost analytics
- local message storage
- usage statistics

---

## Русский

### Описание

Проект представляет собой доработанную версию мобильного AI-чата AIChatFlutter, созданного на Flutter.

Приложение было переработано в многостраничную архитектуру и дополнено:
- настройкой AI-провайдера
- аналитикой токенов
- статистикой расходов
- локальным хранением данных
- автоматическим определением провайдера

Проект работает с AI-провайдерами через HTTP API.

Поддерживаемые провайдеры:
- OpenRouter
- VSEGPT

---

## Реализованные возможности

В рамках проекта были реализованы:

- многостраничная структура приложения
- нижняя навигация между 4 экранами
- экран настройки провайдера
- управление API-ключом
- автоматическое определение провайдера
- сохранение конфигурации через SharedPreferences
- переработанная архитектура API-клиента
- экран статистики токенов
- экран аналитики расходов
- хранение сообщений и аналитики в SQLite
- исправление расчета стоимости для VSEGPT
- совместимость с современными версиями Flutter

---

## Основной функционал

### Экран чата
- AI-чат
- выбор модели
- отображение токенов
- отображение стоимости запросов
- экспорт истории
- очистка истории

### Экран настроек провайдера
- ввод API-ключа
- автоматическое определение OpenRouter / VSEGPT
- сохранение конфигурации
- отображение текущего провайдера
- отображение баланса

### Экран статистики
- общее количество сообщений
- общее количество токенов
- статистика по моделям
- суммарные расходы

### Экран расходов
- расходы по дням
- количество сообщений по дням
- количество токенов по дням
- визуальная аналитика

---

## Технологии

- Flutter
- Dart
- Provider
- SQLite (`sqflite`)
- SharedPreferences
- HTTP API
- OpenRouter
- VSEGPT

---

## Структура проекта

```text
lib/
  api/
    openrouter_client.dart
  models/
    message.dart
    provider_config.dart
  providers/
    chat_provider.dart
  screens/
    chat_screen.dart
    home_shell_screen.dart
    provider_settings_screen.dart
    usage_stats_screen.dart
    daily_cost_chart_screen.dart
  services/
    analytics_service.dart
    database_service.dart
    provider_config_service.dart
  main.dart
```

---

## Запуск проекта

Клонировать репозиторий:

```bash
git clone <ссылка_на_репозиторий>
cd AIChatFlutter
```

Установить зависимости:

```bash
flutter pub get
```

Создать `.env` на основе `.env.example`

Запустить проект:

```bash
flutter run
```

Проект тестировался на Android Emulator API 35.

---

## Примечание

Проект выполнен на основе готового учебного репозитория AIChatFlutter.

Основной задачей была не разработка приложения с нуля, а расширение существующей архитектуры и добавление нового функционала.

---

## Исходный проект

Исходный учебный проект:
https://github.com/neuro-fill/AIChatFlutter

---

## Результат

В результате был получен многостраничный Flutter AI-чат с:
- поддержкой AI-моделей
- настройкой провайдера
- учетом токенов
- аналитикой расходов
- локальным хранением сообщений
- статистикой использования
