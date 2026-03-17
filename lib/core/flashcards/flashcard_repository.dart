import 'flashcard_models.dart';

abstract class FlashcardRepository {
  Future<void> saveDeck(FlashcardDeck deck);
  Future<List<FlashcardDeck>> fetchDecks();
  Future<void> saveReviewLog(ReviewLog log);
  Future<List<ReviewLog>> fetchLogsForCard(String cardId);
  Future<List<ReviewLog>> fetchDueReviews(DateTime now);
  Future<FlashcardDeck?> getDeckByDocId(String docId);
}
