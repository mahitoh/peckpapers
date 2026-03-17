import '../ai/ai_models.dart' as ai;
import '../ai/offline_ai_service.dart';
import 'flashcard_generator.dart';
import 'flashcard_models.dart';

class OfflineFlashcardGenerator implements FlashcardGenerator {
  OfflineFlashcardGenerator({OfflineAiService? service})
      : _service = service ?? OfflineAiService.instance;

  final OfflineAiService _service;

  @override
  Future<List<Flashcard>> generate({
    required String sourceText,
    required String subject,
    int count = 8,
  }) async {
    final cards = await _service.generateFlashcards(
      sourceText,
      subject: subject,
      count: count,
    );

    final now = DateTime.now().microsecondsSinceEpoch;
    return cards.asMap().entries.map((entry) {
      final index = entry.key;
      final aiCard = entry.value;
      return Flashcard(
        id: 'card_${now}_$index',
        question: aiCard.question,
        answer: aiCard.answer,
        subject: aiCard.subject ?? subject,
        hint: _hintFromDifficulty(aiCard),
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  String? _hintFromDifficulty(ai.Flashcard card) {
    if (card.difficulty <= 2) return 'Focus on the core definition.';
    if (card.difficulty >= 4) return 'Try recalling without notes first.';
    return null;
  }
}
