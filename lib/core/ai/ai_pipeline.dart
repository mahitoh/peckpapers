import 'ai_models.dart';

abstract class AiPipeline {
  Future<SummaryResult> summarize(String text, {int maxBullets});

  Future<List<Flashcard>> generateFlashcards(
    String text, {
    String? subject,
    int count,
  });

  Future<List<QuizQuestion>> generateQuiz(
    String text, {
    String? subject,
    QuestionDifficulty difficulty = QuestionDifficulty.medium,
    int count = 5,
  });

  /// Generate quizzes at all three difficulty levels
  Future<Map<QuestionDifficulty, List<QuizQuestion>>> generateAllDifficultyQuizzes(
    String text, {
    String? subject,
    int countPerDifficulty = 3,
  });
}
