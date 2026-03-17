class SummarySectionResult {
  const SummarySectionResult({
    required this.topic,
    required this.content,
    this.bullets = const [],
  });
  final String topic;
  final String content;
  final List<String> bullets;
}

class SummaryResult {
  const SummaryResult({
    required this.summary,
    this.bullets = const [],
    this.sections = const [],
  });

  final String summary;
  final List<String> bullets;
  final List<SummarySectionResult> sections;
}

class Flashcard {
  const Flashcard({
    required this.question,
    required this.answer,
    this.subject,
    this.difficulty = 3,
  });

  final String question;
  final String answer;
  final String? subject;
  final int difficulty;
}

enum QuestionDifficulty { easy, medium, difficult }

enum AiQuestionType { multipleChoice, fillInBlank }

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.type = AiQuestionType.multipleChoice,
    this.correctText,
    this.difficulty = QuestionDifficulty.medium,
    this.explanation,
    this.subject,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final AiQuestionType type;
  final String? correctText; // for fill-in-blank
  final QuestionDifficulty difficulty;
  final String? explanation;
  final String? subject;
}

class Quiz {
  const Quiz({
    required this.id,
    required this.documentId,
    required this.title,
    required this.questions,
    required this.difficulty,
    required this.createdAt,
    this.subject,
  });

  final String id;
  final String documentId;
  final String title;
  final List<QuizQuestion> questions;
  final QuestionDifficulty difficulty;
  final DateTime createdAt;
  final String? subject;

  int get questionCount => questions.length;
}
