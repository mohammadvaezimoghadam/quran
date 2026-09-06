import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/quran_ai_message.dart';
import '../../domain/entities/quran_ai_request.dart';
import '../../domain/repositories/i_quran_ai_repository.dart';
import '../datasources/gemini_ai_datasource.dart';

final quranAiRepositoryProvider = Provider<IQuranAiRepository>((ref) {
  final dataSource = ref.watch(geminiAiDataSourceProvider);
  return QuranAiRepositoryImpl(dataSource);
});

class QuranAiRepositoryImpl implements IQuranAiRepository {
  final IGeminiAiDataSource _dataSource;

  QuranAiRepositoryImpl(this._dataSource);

  @override
  Future<String> sendPrompt({
    required QuranAiRequest context,
    required List<QuranAiMessage> history,
    required String prompt,
  }) {
    return _dataSource.generateContent(
      context: context,
      history: history,
      prompt: prompt,
    );
  }
}
