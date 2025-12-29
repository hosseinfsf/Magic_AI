
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../providers/settings_provider.dart';

class GeminiService {
  // A list of free-tier API keys to use as a fallback
  static const List<String> _freeApiKeys = [
    'YOUR_DEFAULT_GEMINI_API_KEY_1', // Primary free key
    'YOUR_DEFAULT_GEMINI_API_KEY_2', // Backup free key
  ];

  Future<String> sendMessage(String message, SettingsProvider settings) async {
    String apiKey;
    String modelName;

    if (settings.aiModel == 'pro' && settings.userApiKey != null && settings.userApiKey!.isNotEmpty) {
      apiKey = settings.userApiKey!;
      modelName = 'gemini-1.5-pro-latest';
      return await _trySendMessage(message, apiKey, modelName, settings, isPro: true);
    } else {
      // Free Tier Logic with Fallback
      if (settings.isFreeTierLimitReached) {
        return 'متأسفانه محدودیت استفاده رایگان شما امروز به پایان رسیده است. 😕';
      }

      for (var key in _freeApiKeys) {
        try {
          final response = await _trySendMessage(message, key, 'gemini-1.5-flash-latest', settings);
          // If successful, increment usage and return the response
          await settings.incrementUsage();
          return response;
        } catch (e) {
          // If one key fails, the loop will automatically try the next one.
          if (kDebugMode) {
            print('API Key failed, trying next one. Error: $e');
          }
        }
      }
      // If all keys fail
      return 'سرویس هوش مصنوعی در حال حاضر در دسترس نیست. لطفاً چند دقیقه دیگر دوباره تلاش کنید.';
    }
  }

  Future<String> _trySendMessage(String message, String apiKey, String modelName, SettingsProvider settings, {bool isPro = false}) async {
    try {
      final model = GenerativeModel(model: modelName, apiKey: apiKey);
      final response = await model.generateContent([Content.text(message)]);
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from AI');
      }
      
      return response.text!;

    } on GenerativeAIException catch (e) {
      if (kDebugMode) print("GenerativeAIException: ${e.message}");
      // Rethrow specific errors to be handled by the main loop
      if (e.message.contains('API_KEY_INVALID') || e.message.contains('RATE_LIMIT_EXCEEDED')) {
        throw e; 
      }
      // For other errors, return a generic message
      return isPro 
          ? 'کلید API شما برای مدل $modelName معتبر نیست یا با مشکل مواجه شده.'
          : 'مشکلی در ارتباط با مدل $modelName پیش آمد.';
    } catch (e) {
      if (kDebugMode) print("Unknown Error: $e");
      throw Exception('An unknown error occurred.');
    }
  }
}
