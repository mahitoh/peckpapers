import 'ai_cache.dart';
import 'ai_models.dart';
import 'ai_pipeline.dart';
import 'gemma_ai_pipeline.dart';
import 'heuristic_ai_pipeline.dart';
import 'onnx_text_generator.dart';

/// Priority chain: ONNX → Gemma → Heuristic
class OfflineAiService implements AiPipeline {
  OfflineAiService._();
  static final OfflineAiService instance = OfflineAiService._();

  final OnnxTextGenerator _onnx = OnnxTextGenerator();
  final GemmaAiPipeline _gemma = GemmaAiPipeline();
  final HeuristicAiPipeline _heuristic = HeuristicAiPipeline();
  final AiCache _cache = AiCache();

  @override
  Future<SummaryResult> summarize(String text, {int maxBullets = 5}) async {
    final cacheKey = _cacheKey(text, extra: 'summary:$maxBullets');
    final cached = await _cache.getSummary(cacheKey);
    if (cached != null) return cached;

    // 1. ONNX
    var result = await _trySummarizeOnnx(text, maxBullets);
    if (result.summary.isNotEmpty) {
      await _cache.setSummary(cacheKey, result);
      return result;
    }

    // 2. Gemma
    result = await _gemma.summarize(text, maxBullets: maxBullets);
    if (result.summary.isNotEmpty) {
      await _cache.setSummary(cacheKey, result);
      return result;
    }

    // 3. Heuristic fallback
    result = await _heuristic.summarize(text, maxBullets: maxBullets);
    await _cache.setSummary(cacheKey, result);
    return result;
  }

  @override
  Future<List<Flashcard>> generateFlashcards(
    String text, {
    String? subject,
    int count = 6,
  }) async {
    final cacheKey =
        _cacheKey(text, extra: 'flashcards:$count|subject:${subject ?? ''}');
    final cached = await _cache.getFlashcards(cacheKey);
    if (cached != null) return cached;

    // 1. ONNX
    var result = await _tryGenerateFlashcardsOnnx(text, subject, count);
    if (result.isNotEmpty) {
      await _cache.setFlashcards(cacheKey, result);
      return result;
    }

    // 2. Gemma
    result = await _gemma.generateFlashcards(text, subject: subject, count: count);
    if (result.isNotEmpty) {
      await _cache.setFlashcards(cacheKey, result);
      return result;
    }

    // 3. Heuristic fallback
    result = await _heuristic.generateFlashcards(text, subject: subject, count: count);
    await _cache.setFlashcards(cacheKey, result);
    return result;
  }

  @override
  Future<List<QuizQuestion>> generateQuiz(
    String text, {
    String? subject,
    QuestionDifficulty difficulty = QuestionDifficulty.medium,
    int count = 5,
  }) async {
    final cacheKey = _cacheKey(
      text,
      extra: 'quiz:$count|diff:${difficulty.name}|subject:${subject ?? ''}',
    );
    final cached = await _cache.getQuiz(cacheKey);
    if (cached != null) return cached;

    // 1. Gemma (better at structured quiz output than ONNX)
    var result = await _gemma.generateQuiz(
      text,
      subject: subject,
      difficulty: difficulty,
      count: count,
    );
    if (result.isNotEmpty) {
      await _cache.setQuiz(cacheKey, result);
      return result;
    }

    // 2. ONNX
    result = await _tryGenerateQuizOnnx(text, subject, difficulty, count);
    if (result.isNotEmpty) {
      await _cache.setQuiz(cacheKey, result);
      return result;
    }

    // 3. Heuristic fallback
    result = await _heuristic.generateQuiz(
      text,
      subject: subject,
      difficulty: difficulty,
      count: count,
    );
    await _cache.setQuiz(cacheKey, result);
    return result;
  }

  @override
  Future<Map<QuestionDifficulty, List<QuizQuestion>>>
      generateAllDifficultyQuizzes(
    String text, {
    String? subject,
    int countPerDifficulty = 3,
  }) async {
    // Easy: 5–10, Medium: 10–20, Hard: 30–50
    const easyCnt   = 8;
    const mediumCnt = 15;
    const hardCnt   = 30;

    // 1. Gemma
    if (await _gemma.isAvailable()) {
      final result = await _gemma.generateAllDifficultyQuizzes(
        text,
        subject: subject,
        countPerDifficulty: countPerDifficulty,
      );
      if (result.isNotEmpty) return result;
    }

    // 2. Heuristic fallback (generates per-difficulty with correct counts)
    return {
      QuestionDifficulty.easy: await _heuristic.generateQuiz(
        text, subject: subject, difficulty: QuestionDifficulty.easy, count: easyCnt),
      QuestionDifficulty.medium: await _heuristic.generateQuiz(
        text, subject: subject, difficulty: QuestionDifficulty.medium, count: mediumCnt),
      QuestionDifficulty.difficult: await _heuristic.generateQuiz(
        text, subject: subject, difficulty: QuestionDifficulty.difficult, count: hardCnt),
    };
  }

  // ── ONNX helpers ────────────────────────────────────────────────────────────

  Future<SummaryResult> _trySummarizeOnnx(String text, int maxBullets) async {
    try {
      final prompt = _summaryPrompt(text, maxBullets);
      final output = await _onnx.generate(prompt, maxTokens: 320);
      if (output != null && output.trim().isNotEmpty) {
        return _parseSummaryResponse(output, maxBullets);
      }
    } catch (_) {}
    return const SummaryResult(summary: '');
  }

  Future<List<Flashcard>> _tryGenerateFlashcardsOnnx(
      String text, String? subject, int count) async {
    try {
      final prompt = _flashcardPrompt(text, count);
      final output = await _onnx.generate(prompt, maxTokens: 520);
      if (output != null && output.trim().isNotEmpty) {
        return _parseFlashcardResponse(output, subject: subject);
      }
    } catch (_) {}
    return [];
  }

  Future<List<QuizQuestion>> _tryGenerateQuizOnnx(
      String text, String? subject, QuestionDifficulty difficulty, int count) async {
    try {
      final prompt = _quizPrompt(text, count, difficulty.name.toUpperCase());
      final output = await _onnx.generate(prompt, maxTokens: 720);
      if (output != null && output.trim().isNotEmpty) {
        return _parseQuizResponse(output, subject, difficulty);
      }
    } catch (_) {}
    return [];
  }

  // ── Parsers ─────────────────────────────────────────────────────────────────

  SummaryResult _parseSummaryResponse(String output, int maxBullets) {
    final lines = output.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return const SummaryResult(summary: '');

    final bullets = <String>[];
    final sections = <SummarySectionResult>[];
    String currentTopic = '';
    String currentContent = '';
    List<String> currentBullets = [];

    for (final line in lines) {
      if (line.toUpperCase().startsWith('TOPIC:')) {
        if (currentTopic.isNotEmpty) {
          sections.add(SummarySectionResult(topic: currentTopic, content: currentContent, bullets: List.from(currentBullets)));
        }
        currentTopic = line.substring(6).trim();
        currentContent = '';
        currentBullets = [];
      } else if (line.toUpperCase().startsWith('CONTENT:')) {
        currentContent = line.substring(8).trim();
      } else if (line.startsWith('-') || line.startsWith('•') || RegExp(r'^\d+\.').hasMatch(line)) {
        final cleaned = line.replaceFirst(RegExp(r'^[-•\d.]\s*'), '');
        if (cleaned.isNotEmpty) {
          currentBullets.add(cleaned);
          if (bullets.length < maxBullets) bullets.add(cleaned);
        }
      } else if (currentTopic.isNotEmpty) {
        currentContent += (currentContent.isEmpty ? '' : ' ') + line;
      } else {
        final cleaned = line.replaceFirst(RegExp(r'^[-•\d.]\s*'), '');
        if (cleaned.isNotEmpty && bullets.length < maxBullets) bullets.add(cleaned);
      }
    }
    if (currentTopic.isNotEmpty) {
      sections.add(SummarySectionResult(topic: currentTopic, content: currentContent, bullets: currentBullets));
    }
    return SummaryResult(summary: bullets.join(' '), bullets: bullets, sections: sections);
  }

  List<Flashcard> _parseFlashcardResponse(String output, {String? subject}) {
    final cards = <Flashcard>[];
    for (final block in output.split(RegExp(r'\n\s*\n'))) {
      final lines = block.split('\n').map((l) => l.trim()).toList();
      String? q, a;
      for (final line in lines) {
        if (line.toLowerCase().startsWith('q:')) q = line.substring(2).trim();
        else if (line.toLowerCase().startsWith('a:')) a = line.substring(2).trim();
      }
      if (q != null && a != null && q.isNotEmpty && a.isNotEmpty) {
        cards.add(Flashcard(question: q, answer: a, subject: subject));
      }
    }
    return cards;
  }

  List<QuizQuestion> _parseQuizResponse(
      String output, String? subject, QuestionDifficulty difficulty) {
    final questions = <QuizQuestion>[];
    for (final block in output.split('---')) {
      final qMatch = RegExp(r'Q:\s*(.+?)(?=A\)|$)', dotAll: true).firstMatch(block);
      final aMatches = RegExp(r'([A-D])\)\s*(.+?)(?=[A-D]\)|CORRECT:|$)', dotAll: true).allMatches(block);
      final correctMatch = RegExp(r'CORRECT:\s*([A-D])').firstMatch(block);
      final expMatch = RegExp(r'EXPLANATION:\s*(.+?)$', dotAll: true).firstMatch(block);

      final questionText = qMatch?.group(1)?.trim();
      final options = aMatches.map((m) => m.group(2)?.trim() ?? '').toList();
      final correctLetter = correctMatch?.group(1);

      if (questionText != null && questionText.isNotEmpty &&
          options.length == 4 && correctLetter != null) {
        final idx = 'ABCD'.indexOf(correctLetter.toUpperCase());
        questions.add(QuizQuestion(
          question: questionText,
          options: options,
          correctIndex: idx < 0 ? 0 : idx,
          difficulty: difficulty,
          explanation: expMatch?.group(1)?.trim(),
          subject: subject,
        ));
      }
    }
    return questions;
  }

  // ── Prompts ─────────────────────────────────────────────────────────────────

  String _summaryPrompt(String text, int maxBullets) => '''
You are a study assistant. Summarize these notes into sections.
Format:
TOPIC: [name]
CONTENT: [1-2 sentences]
- [bullet]
Notes: $text''';

  String _flashcardPrompt(String text, int count) => '''
Create $count flashcards from these notes.
Format:
Q: [question]
A: [answer]
Notes: $text''';

  String _quizPrompt(String text, int count, String difficulty) => '''
Create $count $difficulty multiple choice questions from this text.
Format each as:
Q: [question]
A) [option]
B) [option]
C) [option]
D) [option]
CORRECT: [A/B/C/D]
EXPLANATION: [why]
---
Text: $text''';

  String _cacheKey(String text, {required String extra}) {
    final hash = _fnv1a(text);
    return '$extra|$hash';
  }

  String _fnv1a(String text) {
    const int fnvPrime = 0x01000193;
    int hash = 0x811C9DC5;
    for (final c in text.codeUnits) {
      hash ^= c;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }
}
