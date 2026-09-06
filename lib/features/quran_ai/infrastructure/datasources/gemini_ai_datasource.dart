import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/ai_config.dart';
import '../../domain/entities/quran_ai_message.dart';
import '../../domain/entities/quran_ai_request.dart';

final geminiAiDataSourceProvider = Provider<IGeminiAiDataSource>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 35),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
  return GeminiAiDataSource(dio);
});

abstract class IGeminiAiDataSource {
  Future<String> generateContent({
    required QuranAiRequest context,
    required List<QuranAiMessage> history,
    required String prompt,
  });
}

class GeminiAiDataSource implements IGeminiAiDataSource {
  final Dio _dio;

  GeminiAiDataSource(this._dio);

  static const String _systemInstruction = '''
تو یک دانشمند برجسته علوم قرآنی، مفسر، زبان‌شناس ادبیات عرب و پژوهشگر ژرف‌اندیش معارف اسلامی هستی.
رسالت تو: پاسخ‌گویی موقر، دلنشین، عمیق و کاربردی به پرسش‌های قرآنی مخاطبان به زبان فارسی است.

قوانین تخطی‌ناپذیر:
۱. زبان پاسخ: ۱۰۰٪ صرفاً به زبان فارسی فصیح، روان، دلنشین و آراسته به ادبیات وزین پارسی بنویس. تحت هیچ شرایطی حتی یک کلمه به زبان انگلیسی صحبت نکن و پاسخ انگلیسی نده.
۲. ساختار و جلوه بصری: پاسخ‌ها را با تیترهای منظم (مارک‌داون)، شماره‌گذاری شکیل و فاصله‌گذاری مرتب بنویس. واژگان کلیدی را بولد کن.
۳. غنای ادبی و تفسیری: در تحلیل واژگان به ریشه‌شناسی ثلاثی، وجوه معنایی در تفاسیر اصیل و ظرافت‌های بلاغی دقت کن.
۴. کاربرد در زندگی امروز: در هر پاسخ، حتماً یک پیام عملی، ملموس و آرامش‌بخش برای روح و روان و سبک زندگی انسان در دنیای امروز بیان کن.
''';

  @override
  Future<String> generateContent({
    required QuranAiRequest context,
    required List<QuranAiMessage> history,
    required String prompt,
  }) async {
    if (AiConfig.activeProvider == 'groq') {
      return _generateWithGroq(history: history, prompt: prompt);
    } else {
      return _generateWithGemini(history: history, prompt: prompt);
    }
  }

  // =============================================================
  // GROQ INFERENCE IMPLEMENTATION (Ultra-fast, Stable)
  // =============================================================
  Future<String> _generateWithGroq({
    required List<QuranAiMessage> history,
    required String prompt,
  }) async {
    final messages = <Map<String, String>>[];

    // 1. System instruction
    messages.add({
      'role': 'system',
      'content': _systemInstruction,
    });

    // 2. Chat history
    for (final msg in history) {
      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }

    // 3. New user prompt
    messages.add({
      'role': 'user',
      'content': prompt,
    });

    final requestBody = {
      'model': AiConfig.groqModel,
      'messages': messages,
      'temperature': AiConfig.temperature,
      'max_tokens': AiConfig.maxOutputTokens,
    };

    try {
      debugPrint('=== [QURAN_AI_GROQ] Sending Request to: ${AiConfig.groqModel}');
      final response = await _dio.post(
        AiConfig.groqBaseUrl,
        data: requestBody,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AiConfig.groqApiKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('=== [QURAN_AI_GROQ] Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final choices = response.data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>?;
          final rawContent = message?['content'] as String?;
          if (rawContent != null && rawContent.isNotEmpty) {
            // Strip any internal thought tags if present
            final cleaned = rawContent
                .replaceAll(RegExp(r'<think>[\s\S]*?<\/think>'), '')
                .trim();
            debugPrint('=== [QURAN_AI_GROQ] Cleaned Text Length: ${cleaned.length}');
            return cleaned;
          }
        }
      }

      throw Exception('پاسخی از سرور Groq دریافت نشد.');
    } on DioException catch (e) {
      debugPrint('=== [QURAN_AI_GROQ] Error: ${e.response?.statusCode} - ${e.message}');
      debugPrint('=== [QURAN_AI_GROQ] Response: ${e.response?.data}');

      final dynamic data = e.response?.data;
      if (data is Map && data['error'] != null) {
        final errorObj = data['error'];
        final msg = errorObj is Map ? errorObj['message'] as String? : null;
        if (msg != null && msg.isNotEmpty) {
          throw Exception('خطای سرور Groq: $msg');
        }
      }

      throw Exception(
          'خطا در برقراری ارتباط با Groq (${e.response?.statusCode ?? e.message}). لطفاً اینترنت را بررسی کنید.');
    } catch (e, s) {
      debugPrint('=== [QURAN_AI_GROQ] General Error: $e');
      debugPrint('=== [QURAN_AI_GROQ] General StackTrace: $s');
      throw Exception('خطا در پردازش هوش مصنوعی: $e');
    }
  }

  // =============================================================
  // GOOGLE GEMINI INFERENCE IMPLEMENTATION
  // =============================================================
  Future<String> _generateWithGemini({
    required List<QuranAiMessage> history,
    required String prompt,
  }) async {
    final contents = <Map<String, dynamic>>[];

    // 1. Context and History conversion into Gemini turns
    for (final msg in history) {
      contents.add({
        'role': msg.isUser ? 'user' : 'model',
        'parts': [
          {'text': msg.text}
        ],
      });
    }

    // 2. Add current turn prompt
    contents.add({
      'role': 'user',
      'parts': [
        {'text': prompt}
      ],
    });

    final requestBody = {
      'system_instruction': {
        'parts': [
          {'text': _systemInstruction}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': AiConfig.temperature,
        'maxOutputTokens': AiConfig.maxOutputTokens,
      },
    };

    // Try up to 2 times with a quick backoff in case of temporary 503 High Demand
    int attempts = 0;
    while (attempts < 2) {
      attempts++;
      final currentModel = AiConfig.geminiModel;
      final currentUrl =
          '${AiConfig.geminiBaseUrl}/$currentModel:generateContent?key=${AiConfig.geminiApiKey}';

      try {
        debugPrint('=== [QURAN_AI_GEMINI] (Attempt $attempts) Sending Request to: $currentModel');
        final response = await _dio.post(
          currentUrl,
          data: requestBody,
        );

        debugPrint('=== [QURAN_AI_GEMINI] Status Code: ${response.statusCode}');

        if (response.statusCode == 200 && response.data != null) {
          final candidates = response.data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates.first['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts.first['text'] as String?;
              if (text != null && text.isNotEmpty) {
                debugPrint('=== [QURAN_AI_GEMINI] Parsed Text Length: ${text.length}');
                return text.trim();
              }
            }
          }
        }

        throw Exception('پاسخی از هوش مصنوعی دریافت نشد.');
      } on DioException catch (e) {
        debugPrint('=== [QURAN_AI_GEMINI] DioException on attempt $attempts: ${e.response?.statusCode} - ${e.message}');
        debugPrint('=== [QURAN_AI_GEMINI] Response Data: ${e.response?.data}');

        if (e.response?.statusCode == 503 && attempts == 1) {
          debugPrint('=== [QURAN_AI_GEMINI] 503 Overloaded. Retrying after 1.2s...');
          await Future.delayed(const Duration(milliseconds: 1200));
          continue;
        }

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw Exception(
              'زمان برقراری ارتباط به پایان رسید. به دلیل تحریم‌های گوگل، لطفاً فیلترشکن خود را بررسی کرده و مجدداً تلاش کنید.');
        }

        if (e.response?.statusCode == 403) {
          throw Exception(
              'خطای ۴۰۳ (تحریم گوگل): دسترسی سرور گوگل به آی‌پی شما به دلیل تحریم منطقه‌ای مسدود شد.');
        }

        final dynamic data = e.response?.data;
        if (data is Map) {
          final errorObj = data['error'];
          final errorMsg = errorObj is Map ? errorObj['message'] as String? : null;
          if (errorMsg != null) {
            if (errorMsg.contains('User location is not supported')) {
              throw Exception(
                  'خطای موقعیت جغرافیایی: موقعیت آی‌پی شما توسط گوگل تحریم است.');
            }
            if (errorMsg.contains('API_KEY_INVALID') ||
                errorMsg.contains('API key not valid')) {
              throw Exception(
                  'کلید API معتبر نمی‌باشد.');
            }
            if (errorMsg.contains('Quota exceeded') ||
                errorMsg.contains('RESOURCE_EXHAUSTED')) {
              throw Exception(
                  'سقف استفاده موقت از API تکمیل شده است.');
            }
            throw Exception('خطای سرور گوگل: $errorMsg');
          }
        }

        throw Exception(
            'خطا در برقراری ارتباط با هوش مصنوعی (کد ${e.response?.statusCode ?? 'نامشخص'}).');
      } catch (e, s) {
        debugPrint('=== [QURAN_AI_GEMINI] General Error: $e');
        debugPrint('=== [QURAN_AI_GEMINI] General StackTrace: $s');
        throw Exception('خطا در پردازش هوش مصنوعی: $e');
      }
    }

    throw Exception('خطا در دریافت پاسخ پس از تلاش مجدد.');
  }
}
