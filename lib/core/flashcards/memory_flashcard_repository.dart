import 'flashcard_models.dart';
import 'flashcard_repository.dart';

class MemoryFlashcardRepository implements FlashcardRepository {
  final List<FlashcardDeck> _decks = [];
  final List<ReviewLog> _logs = [];

  @override
  Future<void> saveDeck(FlashcardDeck deck) async {
    final index = _decks.indexWhere((d) => d.id == deck.id);
    if (index >= 0) {
      _decks[index] = deck;
    } else {
      _decks.add(deck);
    }
  }

  @override
  Future<List<FlashcardDeck>> fetchDecks() async {
    return List<FlashcardDeck>.from(_decks);
  }

  @override
  Future<void> saveReviewLog(ReviewLog log) async {
    _logs.add(log);
  }

  @override
  Future<List<ReviewLog>> fetchLogsForCard(String cardId) async {
    return _logs.where((log) => log.cardId == cardId).toList();
  }

  @override
  Future<List<ReviewLog>> fetchDueReviews(DateTime now) async {
    return _logs.where((log) => !log.nextDue.isAfter(now)).toList();
  }

  @override
  Future<FlashcardDeck?> getDeckByDocId(String docId) async {
    return _decks.where((d) => d.docId == docId).firstOrNull;
  }
}
