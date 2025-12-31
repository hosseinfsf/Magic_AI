
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../providers/settings_provider.dart';

// --- Default Model Configuration ---
// Note: Replace these placeholders with your actual API keys.
// The app will try KEY_1 first, then KEY_2 as a fallback.
const List<String> _freeApiKeys = [
  'YOUR_DEFAULT_GEMINI_API_KEY_1',
  'YOUR_DEFAULT_GEMINI_API_KEY_2',
];
const String _freeModel = 'gemini-2.5-flash';
const String _proModel = 'gemini-2.5-pro';

class GeminiService {
  // --- Helper to get the correct GenerativeModel ---
  GenerativeModel _getModel(String apiKey, String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        // Set higher for more creative tasks like generating content
        temperature: 0.7,
        // System instruction should be handled by the ChatSession in sendMessage
      ),
    );
  }

  // --- Core API Logic with Fallback ---
  Future<String> sendMessage(String message, SettingsProvider settings) async {
    // 1. Check Pro Tier (User's API Key)
    if (settings.aiModel == 'pro' && settings.userApiKey != null && settings.userApiKey!.isNotEmpty) {
      return await _trySendMessage(message, settings.userApiKey!, _proModel, settings);
    }

    // 2. Check Free Tier Limit
    if (settings.isFreeTierLimitReached) {
      return 'متأسفانه محدودیت استفاده رایگان شما امروز به پایان رسیده است. 😕\nلطفاً برای ادامه، کلید API شخصی خود را وارد کنید.';
    }

    // 3. Free Tier Logic with Fallback
    for (var key in _freeApiKeys) {
      try {
        final response = await _trySendMessage(message, key, _freeModel, settings, isFreeTier: true);
        // If successful, increment usage and return
        await settings.incrementUsage();
        return response;
      } on GenerativeAIException catch (e) {
        if (kDebugMode) print('Free API Key failed: ${e.message}');
        // If one key fails (invalid or rate-limited), the loop tries the next one.
      }
    }

    // 4. Final Fallback (All free keys failed)
    return 'سرویس هوش مصنوعی در حال حاضر در دسترس نیست. لطفاً چند دقیقه دیگر دوباره تلاش کنید.';
  }

  // --- Internal function to handle the API call ---
  Future<String> _trySendMessage(String message, String apiKey, String modelName, SettingsProvider settings, {bool isFreeTier = false}) async {
    try {
      final model = _getModel(apiKey, modelName);
      
      // Use the system instruction from the initial setup (or add here if needed)
      // For simplicity, we are using generateContent instead of startChat to avoid state issues in this generalized service method
      final response = await model.generateContent([Content.text(message)]);
      
      if (response.text == null || response.text!.trim().isEmpty) {
        throw Exception('Empty response from AI for model $modelName');
      }
      
      return response.text!;

    } on GenerativeAIException catch (e) {
      if (kDebugMode) print('GenerativeAIException on $modelName: ${e.message}');
      
      if (isFreeTier && (e.message.contains('API_KEY_INVALID') || e.message.contains('RATE_LIMIT_EXCEEDED'))) {
        // Only re-throw for specific errors in free tier so the loop can try the next key
        rethrow;
      } else if (!isFreeTier && e.message.contains('API_KEY_INVALID')) {
        // Specific message for Pro users if their key fails
        throw Exception('کلید API شما معتبر نیست. لطفاً آن را در تنظیمات بررسی کنید.');
      }
      
      throw Exception('مشکلی در ارتباط با مدل $modelName پیش آمد.');
    } catch (e) {
      if (kDebugMode) print('Unexpected Error: $e');
      throw Exception('خطای غیرمنتظره در سرویس AI.');
    }
  }

  // --- Other methods (Simplified to use the new sendMessage logic) ---
  
  // Note: All other methods (interpretHafez, generateReplies, etc.) need to be refactored
  // to accept the SettingsProvider instance and use the new core logic.
  // For this review, we only show the core refactoring.
  
  // Example refactored method signature:
  // Future<List<String>> generateReplies({required String message, required SettingsProvider settings}) async { ... }
}
