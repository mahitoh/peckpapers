import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'ai_models.dart';

class AiCache {
  static const _summaryPrefix = 'ai_summary_';
  static const _cardsPrefix = 'ai_cards_';
  static const _quizPrefix = 'ai_quiz_';

  Future<SummaryResult?> getSummary(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_summaryPrefix$key');
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return SummaryResult(
      summary: map['summary'] as String? ?? '',
      bullets:
          (map['bullets'] as List<dynamic>? ?? []).map((e) => '$e').toList(),
    );
  }

  Future<void> setSummary(String key, SummaryResult summary) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode({
      'summary': summary.summary,
      'bullets': summary.bullets,
    });
    await prefs.setString('$_summaryPrefix$key', raw);
  }

  Future<List<Flashcard>?> getFlashcards(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_cardsPrefix$key');
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map(
          (item) => Flashcard(
            question: item['question'] as String? ?? '',
            answer: item['answer'] as String? ?? '',
            subject: item['subject'] as String?,
            difficulty: item['difficulty'] as int? ?? 3,
          ),
        )
        .where((c) => c.question.isNotEmpty && c.answer.isNotEmpty)
        .toList();
  }

  Future<void> setFlashcards(String key, List<Flashcard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      cards
          .map(
            (c) => {
              'question': c.question,
              'answer': c.answer,
              'subject': c.subject,
              'difficulty': c.difficulty,
            },
          )
          .toList(),
    );
    await prefs.setString('$_cardsPrefix$key', raw);
  }

  Future<List<QuizQuestion>?> getQuiz(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_quizPrefix$key');
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map(
          (item) => QuizQuestion(
            question: item['question'] as String? ?? '',
            options:
                (item['options'] as List<dynamic>? ?? []).map((e) => '$e').toList(),
            correctIndex: item['correctIndex'] as int? ?? 0,
            difficulty: _parseDifficulty(item['difficulty']),
            explanation: item['explanation'] as String?,
            subject: item['subject'] as String?,
          ),
        )
        .where((q) => q.question.isNotEmpty && q.options.length == 4)
        .toList();
  }

  Future<void> setQuiz(String key, List<QuizQuestion> questions) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      questions
          .map(
            (q) => {
              'question': q.question,
              'options': q.options,
              'correctIndex': q.correctIndex,
              'difficulty': q.difficulty.name,
              'explanation': q.explanation,
              'subject': q.subject,
            },
          )
          .toList(),
    );
    await prefs.setString('$_quizPrefix$key', raw);
  }

  QuestionDifficulty _parseDifficulty(dynamic value) {
    if (value is String) {
      return QuestionDifficulty.values
          .firstWhere((e) => e.name == value, orElse: () => QuestionDifficulty.medium);
    }
    return QuestionDifficulty.medium;
  }
}
