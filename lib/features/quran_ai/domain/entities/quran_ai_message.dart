/// Represents an interactive conversation turn between the user and Quran AI
class QuranAiMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const QuranAiMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  factory QuranAiMessage.user(String text) {
    return QuranAiMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory QuranAiMessage.ai(String text) {
    return QuranAiMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
