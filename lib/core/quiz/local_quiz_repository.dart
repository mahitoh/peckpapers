import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../ai/ai_models.dart';

class LocalQuizRepository {
  LocalQuizRepository._();
  static final LocalQuizRepository _instance = LocalQuizRepository._();
  static LocalQuizRepository get instance => _instance;

  static const _prefix = 'quiz_';

  /// Save quiz questions for a document
  Future<void> saveQuiz(
    String documentId,
    QuestionDifficulty difficulty,
    List<QuizQuestion> questions,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${documentId}_${difficulty.name}';
    
    final json = jsonEncode(
      questions
          .map((q) => {
                'question': q.question,
                'options': q.options,
                'correctIndex': q.correctIndex,
                'explanation': q.explanation,
                'subject': q.subject,
                'difficulty': q.difficulty.name,
              })
          .toList(),
    );
    
    await prefs.setString(key, json);
  }

  /// Get quiz questions for a document at specific difficulty
  Future<List<QuizQuestion>> getQuiz(
    String documentId,
    QuestionDifficulty difficulty,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${documentId}_${difficulty.name}';
    final json = prefs.getString(key);
    
    if (json == null) return [];
    
    try {
      final list = jsonDecode(json) as List<dynamic>;
      final questions = list
          .map(
            (item) => QuizQuestion(
              question: item['question'] as String? ?? '',
              options: (item['options'] as List<dynamic>? ?? [])
                  .map((e) => '$e')
                  .toList(),
              correctIndex: item['correctIndex'] as int? ?? 0,
              explanation: item['explanation'] as String?,
              subject: item['subject'] as String?,
              difficulty: _parseDifficulty(item['difficulty']),
            ),
          )
          .toList();
      // Shuffle so every quiz session has a different question order
      questions.shuffle(Random());
      return questions;
    } catch (_) {
      return [];
    }
  }

  /// Get all quizzes for a document
  Future<Map<QuestionDifficulty, List<QuizQuestion>>> getAllQuizzes(
    String documentId,
  ) async {
    final easyQuiz = await getQuiz(documentId, QuestionDifficulty.easy);
    final mediumQuiz = await getQuiz(documentId, QuestionDifficulty.medium);
    final hardQuiz = await getQuiz(documentId, QuestionDifficulty.difficult);

    return {
      QuestionDifficulty.easy: easyQuiz,
      QuestionDifficulty.medium: mediumQuiz,
      QuestionDifficulty.difficult: hardQuiz,
    };
  }

  /// Delete all quizzes for a document
  Future<void> deleteAllQuizzes(String documentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix${documentId}_easy');
    await prefs.remove('$_prefix${documentId}_medium');
    await prefs.remove('$_prefix${documentId}_difficult');
  }

  QuestionDifficulty _parseDifficulty(dynamic value) {
    if (value is String) {
      return QuestionDifficulty.values
          .firstWhere((e) => e.name == value, orElse: () => QuestionDifficulty.medium);
    }
    return QuestionDifficulty.medium;
  }
}
