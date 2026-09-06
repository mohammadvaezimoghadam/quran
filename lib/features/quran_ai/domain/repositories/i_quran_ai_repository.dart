import '../entities/quran_ai_message.dart';
import '../entities/quran_ai_request.dart';

abstract class IQuranAiRepository {
  /// Sends a request with full Quranic context and returns AI response
  Future<String> sendPrompt({
    required QuranAiRequest context,
    required List<QuranAiMessage> history,
    required String prompt,
  });
}
