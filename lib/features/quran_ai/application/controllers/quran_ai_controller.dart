import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/quran_ai_message.dart';
import '../../domain/entities/quran_ai_request.dart';
import '../../domain/repositories/i_quran_ai_repository.dart';
import '../../infrastructure/repositories/quran_ai_repository_impl.dart';
import '../states/quran_ai_state.dart';

final quranAiControllerProvider =
    NotifierProvider.autoDispose<QuranAiController, QuranAiState>(
  QuranAiController.new,
);

class QuranAiController extends Notifier<QuranAiState> {
  late final IQuranAiRepository _repository;

  @override
  QuranAiState build() {
    _repository = ref.watch(quranAiRepositoryProvider);
    return const QuranAiState();
  }

  /// Prepares the AI context for a Quranic ayah/word without sending an automatic request
  void prepareContext(QuranAiRequest request) {
    state = QuranAiState(
      request: request,
      isLoading: false,
      errorMessage: null,
      messages: const [],
    );
  }

  /// Sends a question from user (either a selected starter box or custom input)
  Future<void> askQuestion(String question) async {
    final cleanQuestion = question.trim();
    if (cleanQuestion.isEmpty || state.request == null) return;

    final isFirstMessage = state.messages.isEmpty;
    final userMessage = QuranAiMessage.user(cleanQuestion);
    final currentMessages = List<QuranAiMessage>.from(state.messages)..add(userMessage);

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      messages: currentMessages,
    );

    // If first message, enrich prompt with Quranic verse context
    final promptToSend = isFirstMessage
        ? '${state.request!.buildContextPrefix()}\n\nپرسش یا درخواست کاربر:\n$cleanQuestion'
        : cleanQuestion;

    try {
      final answer = await _repository.sendPrompt(
        context: state.request!,
        history: state.messages,
        prompt: promptToSend,
      );

      final aiResponse = QuranAiMessage.ai(answer);

      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        messages: [...currentMessages, aiResponse],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Legacy alias for askQuestion for backwards compatibility
  Future<void> askFollowUp(String question) => askQuestion(question);

  /// Retry last failed message
  void retry() {
    if (state.request == null) return;
    if (state.messages.isNotEmpty) {
      final lastUserMsg = state.messages.lastWhere(
        (m) => m.isUser,
        orElse: () => QuranAiMessage.user('تحلیل تدبری آیه'),
      );
      // Remove the last failed state if it had no response
      askQuestion(lastUserMsg.text);
    }
  }

  /// Clear / Reset conversation
  void reset() {
    state = const QuranAiState();
  }
}
