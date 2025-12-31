import 'package:flutter/foundation.dart';

/// Supported AI provider types selectable from Settings
enum AiProviderType { gemini, openRouter, togetherAi }

/// Unified options for text generation
class AiOptions {
  final double? temperature;
  final int? maxTokens;
  final String? model;
  final Map<String, dynamic>? extra;

  const AiOptions({this.temperature, this.maxTokens, this.model, this.extra});

  Map<String, dynamic> toJson() => {
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'maxTokens': maxTokens,
        if (model != null) 'model': model,
        if (extra != null) 'extra': extra,
      };
}

/// Unified AI provider interface so domain services stay provider-agnostic
abstract class AiProvider {
  /// Generate free-form text for a single prompt
  Future<String> generateText(String prompt, {AiOptions? options});

  /// Summarize a given text using provider-specific implementation
  @mustCallSuper
  Future<String> summarize(String text, {AiOptions? options}) async {
    final prompt = 'Summarize briefly in Persian (fa):\n$text';
    return generateText(prompt, options: options);
  }
}
