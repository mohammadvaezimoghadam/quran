import '../../domain/entities/quran_ai_message.dart';
import '../../domain/entities/quran_ai_request.dart';

class QuranAiState {
  final bool isLoading;
  final String? errorMessage;
  final QuranAiRequest? request;
  final List<QuranAiMessage> messages;

  const QuranAiState({
    this.isLoading = false,
    this.errorMessage,
    this.request,
    this.messages = const [],
  });

  QuranAiState copyWith({
    bool? isLoading,
    String? errorMessage,
    QuranAiRequest? request,
    List<QuranAiMessage>? messages,
  }) {
    return QuranAiState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      request: request ?? this.request,
      messages: messages ?? this.messages,
    );
  }
}
