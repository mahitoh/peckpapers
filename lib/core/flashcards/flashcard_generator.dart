import 'flashcard_models.dart';

abstract class FlashcardGenerator {
  Future<List<Flashcard>> generate({
    required String sourceText,
    required String subject,
    int count = 8,
  });
}
