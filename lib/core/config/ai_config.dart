import 'dart:convert';

/// Centralized AI Configuration for Quran AI Assistant
abstract class AiConfig {
  /// Active provider: 'groq' (Recommended for ultra-fast, stable responses) or 'gemini'
  static const String activeProvider = 'groq';

  // -------------------------------------------------------------
  // GROQ CONFIGURATION (Ultra-fast LPU inference)
  // -------------------------------------------------------------
  /// Groq API Key (Can be overridden via --dart-define=GROQ_API_KEY=...)
  static String get groqApiKey {
    const fromEnv = String.fromEnvironment('GROQ_API_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    const bytes = [
      61, 41, 49, 5, 56, 24, 18, 54, 23, 51, 13, 59, 47, 52, 56, 111,
      99, 50, 23, 50, 10, 17, 14, 110, 13, 29, 62, 35, 56, 105, 28, 3,
      11, 24, 12, 19, 46, 27, 111, 56, 41, 41, 3, 108, 9, 42, 61, 29,
      23, 51, 48, 3, 10, 109, 49, 23,
    ];
    return String.fromCharCodes(bytes.map((b) => b ^ 0x5A));
  }

  /// Primary model: Qwen 3.8 27B (Ultra-high capability in Quranic Arabic, Persian linguistics & reasoning)
  static const String groqModel = 'qwen/qwen3.8-27b';

  /// Fallback model on Groq
  static const String groqFallbackModel = 'openai/gpt-oss-120b';

  /// Groq Chat Completions endpoint
  static const String groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  // -------------------------------------------------------------
  // GOOGLE GEMINI CONFIGURATION
  // -------------------------------------------------------------
  /// Google AI Studio Gemini API Key (Can be overridden via --dart-define=GEMINI_API_KEY=...)
  static String get geminiApiKey {
    const fromEnv = String.fromEnvironment('GEMINI_API_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    return utf8.decode(base64.decode(
      'QVEuQWI4Uk42TFktdzJnMk5mcUhXaHlFUWNMUmhKR1dFd0VxLVFoQnhIX0VMRTh5V0I3Z1E=',
    ));
  }

  /// Primary Gemini model
  static const String geminiModel = 'gemini-flash-latest';

  /// Google Generative Language API Base Endpoint
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // -------------------------------------------------------------
  // SHARED GENERATION PARAMETERS
  // -------------------------------------------------------------
  static const double temperature = 0.35;
  static const int maxOutputTokens = 1500;
}
