import 'ai_provider.dart';
import 'history_service.dart';
import 'gemini_service.dart' as legacy;
import '../providers/settings_provider.dart';

/// Placeholder imports for HTTP-based providers
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiProviderFactory {
  final String? geminiApiKey;
  final String? openRouterKey;
  final String? togetherAiKey;
  final HistoryStore history;

  AiProviderFactory({
    this.geminiApiKey,
    this.openRouterKey,
    this.togetherAiKey,
    required this.history,
  });

  AiProvider create(AiProviderType type, {required SettingsProvider settings}) {
    switch (type) {
      case AiProviderType.gemini:
        return GeminiProvider(apiKey: geminiApiKey, history: history, settings: settings);
      case AiProviderType.openRouter:
        return OpenRouterProvider(apiKey: openRouterKey, history: history);
      case AiProviderType.togetherAi:
        return TogetherAiProvider(apiKey: togetherAiKey, history: history);
    }
  }
}

class GeminiProvider implements AiProvider {
  final String? apiKey; // Optional override; legacy service also supports free keys
  final HistoryStore history;
  final legacy.GeminiService _legacy = legacy.GeminiService();
  final SettingsProvider settings;

  GeminiProvider({this.apiKey, required this.history, required this.settings});

  @override
  Future<String> generateText(String prompt, {AiOptions? options}) async {
    try {
      final response = await _legacy.sendMessage(prompt, settings);
      await history.add(HistoryEntry(
        provider: AiProviderType.gemini,
        timestamp: DateTime.now(),
        request: prompt,
        response: response,
        meta: {
          'model': options?.model ?? 'gemini-default',
          if (options?.temperature != null) 'temperature': options!.temperature,
        },
      ));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> summarize(String text, {AiOptions? options}) async {
    final prompt = 'Summarize briefly in Persian (fa):\n$text';
    return generateText(prompt, options: options);
  }
}

class OpenRouterProvider implements AiProvider {
  final String? apiKey;
  final HistoryStore history;

  OpenRouterProvider({required this.apiKey, required this.history});

  static const _defaultModel = 'meta-llama/Meta-Llama-3.1-8B-Instruct';

  @override
  Future<String> generateText(String prompt, {AiOptions? options}) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('کلید OpenRouter تنظیم نشده است.');
    }

    final uri = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final model = options?.model ?? _defaultModel;
    final temperature = options?.temperature ?? 0.7;
    final body = {
      'model': model,
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'temperature': temperature,
      if (options?.maxTokens != null) 'max_tokens': options!.maxTokens,
    };

    final res = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'mana.ai.app',
            'X-Title': 'Mana AI',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 45));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('OpenRouter error: HTTP ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final content =
        (((data['choices'] ?? []) as List).firstOrNull?['message']?['content']) ?? '';
    if (content is! String || content.trim().isEmpty) {
      throw Exception('پاسخ نامعتبر از OpenRouter');
    }

    await history.add(HistoryEntry(
      provider: AiProviderType.openRouter,
      timestamp: DateTime.now(),
      request: prompt,
      response: content,
      meta: {'model': model, 'temperature': temperature},
    ));

    return content;
  }

  @override
  Future<String> summarize(String text, {AiOptions? options}) async {
    final prompt = 'Summarize briefly in Persian (fa):\n$text';
    return generateText(prompt, options: options);
  }
}

class TogetherAiProvider implements AiProvider {
  final String? apiKey;
  final HistoryStore history;

  TogetherAiProvider({required this.apiKey, required this.history});

  static const _defaultModel = 'meta-llama/Llama-3-8b-chat-hf';

  @override
  Future<String> generateText(String prompt, {AiOptions? options}) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('کلید TogetherAI تنظیم نشده است.');
    }

    final uri = Uri.parse('https://api.together.xyz/v1/chat/completions');
    final model = options?.model ?? _defaultModel;
    final temperature = options?.temperature ?? 0.7;

    final body = {
      'model': model,
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'temperature': temperature,
      if (options?.maxTokens != null) 'max_tokens': options!.maxTokens,
    };

    final res = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 45));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('TogetherAI error: HTTP ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final content =
        (((data['choices'] ?? []) as List).firstOrNull?['message']?['content']) ?? '';

    if (content is! String || content.trim().isEmpty) {
      throw Exception('پاسخ نامعتبر از TogetherAI');
    }

    await history.add(HistoryEntry(
      provider: AiProviderType.togetherAi,
      timestamp: DateTime.now(),
      request: prompt,
      response: content,
      meta: {'model': model, 'temperature': temperature},
    ));

    return content;
  }

  @override
  Future<String> summarize(String text, {AiOptions? options}) async {
    final prompt = 'Summarize briefly in Persian (fa):\n$text';
    return generateText(prompt, options: options);
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
