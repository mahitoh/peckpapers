import 'dart:math';
import 'ai_models.dart';
import 'ai_pipeline.dart';

class HeuristicAiPipeline implements AiPipeline {
  final _rng = Random();

  @override
  Future<SummaryResult> summarize(String text, {int maxBullets = 5}) async {
    final sentences = _splitSentences(_cleanText(text));
    if (sentences.isEmpty) return const SummaryResult(summary: 'No content available.');
    final scored = _scoreSentences(sentences)..sort((a, b) => b.score.compareTo(a.score));
    final top = scored.take(max(3, maxBullets)).toList();
    final bullets = top.take(maxBullets).map((s) => s.text).toList();
    return SummaryResult(summary: bullets.join(' '), bullets: bullets);
  }

  @override
  Future<List<Flashcard>> generateFlashcards(String text, {String? subject, int count = 6}) async {
    final sentences = _splitSentences(_cleanText(text));
    if (sentences.isEmpty) return [];
    final scored = _scoreSentences(sentences)..sort((a, b) => b.score.compareTo(a.score));
    return scored.take(count).map((item) => Flashcard(
      question: _toQuestion(item.text),
      answer: item.text,
      subject: subject,
    )).toList();
  }

  @override
  Future<List<QuizQuestion>> generateQuiz(
    String text, {
    String? subject,
    QuestionDifficulty difficulty = QuestionDifficulty.medium,
    int count = 5,
  }) async {
    final sentences = _splitSentences(_cleanText(text));
    if (sentences.isEmpty) return [];
    final scored = _scoreSentences(sentences)..sort((a, b) => b.score.compareTo(a.score));
    // Repeat sentences cyclically if we need more than available
    final available = scored.length;
    return List.generate(count, (i) {
      final item = scored[i % available];
      // Easy: all MCQ; Medium: 70% MCQ 30% fill; Hard: 50/50
      final fillChance = difficulty == QuestionDifficulty.easy ? 0.0
          : difficulty == QuestionDifficulty.medium ? 0.3 : 0.5;
      return _rng.nextDouble() < fillChance
          ? _makeFill(item.text, difficulty: difficulty, subject: subject)
          : _makeMcq(item.text, difficulty: difficulty, subject: subject);
    });
  }

  @override
  Future<Map<QuestionDifficulty, List<QuizQuestion>>> generateAllDifficultyQuizzes(
    String text, {
    String? subject,
    int countPerDifficulty = 3,
  }) async {
    return {
      QuestionDifficulty.easy: await generateQuiz(text, subject: subject,
          difficulty: QuestionDifficulty.easy, count: max(5, countPerDifficulty * 2)),
      QuestionDifficulty.medium: await generateQuiz(text, subject: subject,
          difficulty: QuestionDifficulty.medium, count: max(10, countPerDifficulty * 4)),
      QuestionDifficulty.difficult: await generateQuiz(text, subject: subject,
          difficulty: QuestionDifficulty.difficult, count: max(30, countPerDifficulty * 10)),
    };
  }

  // ── Question builders ───────────────────────────────────────────────────────

  QuizQuestion _makeMcq(String sentence, {required QuestionDifficulty difficulty, String? subject}) {
    final correct = sentence.replaceAll(RegExp(r'[.!?]+$'), '');
    final distractors = [
      'This statement is historically incorrect.',
      'This applies only in specific conditions.',
      'The opposite of this is generally true.',
    ];
    final options = [correct, ...distractors]..shuffle(_rng);
    return QuizQuestion(
      question: _questionVariant(sentence, difficulty),
      options: options,
      correctIndex: options.indexOf(correct),
      type: AiQuestionType.multipleChoice,
      difficulty: difficulty,
      explanation: 'From source: $sentence',
      subject: subject,
    );
  }

  QuizQuestion _makeFill(String sentence, {required QuestionDifficulty difficulty, String? subject}) {
    final words = sentence.split(RegExp(r'\s+'));
    final candidates = words.where((w) => w.length > 4).toList();
    final target = candidates.isNotEmpty
        ? (candidates..sort((a, b) => b.length.compareTo(a.length))).first
        : words.last;
    final clean = target.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final blanked = sentence.replaceFirst(target, '______');
    return QuizQuestion(
      question: 'Fill in the blank: $blanked',
      options: const [],
      correctIndex: 0,
      type: AiQuestionType.fillInBlank,
      correctText: clean,
      difficulty: difficulty,
      explanation: 'The missing word is: $clean',
      subject: subject,
    );
  }

  String _questionVariant(String sentence, QuestionDifficulty difficulty) {
    final t = sentence.replaceAll(RegExp(r'[.!?]+$'), '');
    return switch (difficulty) {
      QuestionDifficulty.easy => 'Which of the following is true? $t',
      QuestionDifficulty.medium => 'Based on the material, which best describes: $t?',
      QuestionDifficulty.difficult => 'Which statement best captures the nuance of: $t?',
    };
  }

  // ── Text helpers ────────────────────────────────────────────────────────────

  String _cleanText(String text) =>
      text.replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'\s([?.!,])'), r'$1').trim();

  List<String> _splitSentences(String text) {
    if (text.isEmpty) return [];
    return text.split(RegExp(r'(?<=[.!?])\s+')).map((s) => s.trim()).where((s) => s.length > 20).toList();
  }

  List<_Scored> _scoreSentences(List<String> sentences) {
    final freq = <String, int>{};
    for (final s in sentences) {
      for (final w in _tokenize(s)) freq[w] = (freq[w] ?? 0) + 1;
    }
    return sentences.map((s) {
      final score = _tokenize(s).fold<int>(0, (sum, w) => sum + (freq[w] ?? 0));
      return _Scored(text: s, score: score);
    }).toList();
  }

  List<String> _tokenize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').split(RegExp(r'\s+')).where((w) => w.length > 3).toList();

  String _toQuestion(String sentence) {
    final t = sentence.replaceAll(RegExp(r'[.!?]+$'), '');
    return t.toLowerCase().startsWith(RegExp(r'what|how|why')) ? '$t?' : 'Explain: $t?';
  }
}

class _Scored {
  _Scored({required this.text, required this.score});
  final String text;
  final int score;
}
