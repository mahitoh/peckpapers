import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_models.dart';
import 'ai_pipeline.dart';

/// Gemma 2B AI Pipeline - uses local Ollama or similar service
/// Falls back to heuristic if service is unavailable
class GemmaAiPipeline implements AiPipeline {
  GemmaAiPipeline({
    this.baseUrl = 'http://localhost:11434',
    this.model = 'gemma:2b',
    this.timeout = const Duration(seconds: 30),
  });

  final String baseUrl;
  final String model;
  final Duration timeout;

  static const _generateEndpoint = '/api/generate';

  bool _available = false;
  bool _tested = false;

  /// Check if Gemma service is available
  Future<bool> isAvailable() async {
    if (_tested) return _available;
    
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 5));
      _tested = true;
      _available = response.statusCode == 200;
      return _available;
    } catch (_) {
      _tested = true;
      _available = false;
      return false;
    }
  }

  @override
  Future<SummaryResult> summarize(String text, {int maxBullets = 5}) async {
    if (!await isAvailable()) {
      return const SummaryResult(summary: ''); // Let caller handle fallback
    }

    try {
      final prompt = '''Generate an organized summary of these notes with logical sections and topics.
Format each section exactly as:
TOPIC: [Topic Name]
CONTENT: [1-2 sentence overview]
- [Bullet point 1]
- [Bullet point 2]
---

Text: $text''';

      final result = await _callGemma(prompt, maxTokens: 320);
      if (result == null || result.isEmpty) return const SummaryResult(summary: '');

      return _parseSummaryResponse(result, maxBullets);
    } catch (_) {
      return const SummaryResult(summary: '');
    }
  }

  @override
  Future<List<Flashcard>> generateFlashcards(
    String text, {
    String? subject,
    int count = 6,
  }) async {
    if (!await isAvailable()) {
      return []; // Let caller handle fallback
    }

    try {
      final prompt = '''Create exactly $count flashcard Q&A pairs from this text:

$text

Format each pair as:
Q: [question]
A: [answer]

Separate pairs with "---"

Make questions clear and answers concise.''';

      final result = await _callGemma(prompt, maxTokens: 520);
      if (result == null || result.isEmpty) return [];

      return _parseFlashcardResponse(result, subject);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<QuizQuestion>> generateQuiz(
    String text, {
    String? subject,
    QuestionDifficulty difficulty = QuestionDifficulty.medium,
    int count = 5,
  }) async {
    if (!await isAvailable()) {
      return []; // Let caller handle fallback
    }

    try {
      final difficultyStr = difficulty.name.toUpperCase();
      final prompt = '''Create $count multiple choice questions at $difficultyStr difficulty from this text:

$text

Format each question as:
Q: [question]
A) [option 1]
B) [option 2]
C) [option 3]
D) [option 4]
CORRECT: [A/B/C/D]
EXPLANATION: [brief explanation]

Separate questions with "---"

Make sure the correct answer is actually in the text and distractors are plausible.''';

      final result = await _callGemma(prompt, maxTokens: 720);
      if (result == null || result.isEmpty) return [];

      return _parseQuizResponse(result, subject, difficulty);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<QuestionDifficulty, List<QuizQuestion>>> generateAllDifficultyQuizzes(
    String text, {
    String? subject,
    int countPerDifficulty = 3,
  }) async {
    if (!await isAvailable()) {
      return {}; // Let caller handle fallback
    }

    try {
      final easyQuiz = await generateQuiz(
        text,
        subject: subject,
        difficulty: QuestionDifficulty.easy,
        count: countPerDifficulty,
      );
      final mediumQuiz = await generateQuiz(
        text,
        subject: subject,
        difficulty: QuestionDifficulty.medium,
        count: countPerDifficulty,
      );
      final hardQuiz = await generateQuiz(
        text,
        subject: subject,
        difficulty: QuestionDifficulty.difficult,
        count: countPerDifficulty,
      );

      return {
        QuestionDifficulty.easy: easyQuiz,
        QuestionDifficulty.medium: mediumQuiz,
        QuestionDifficulty.difficult: hardQuiz,
      };
    } catch (_) {
      return {};
    }
  }

  Future<String?> _callGemma(String prompt, {int maxTokens = 256}) async {
    try {
      final body = jsonEncode({
        'model': model,
        'prompt': prompt,
        'stream': false,
        'temperature': 0.7,
        'num_predict': maxTokens,
      });

      final response = await http
          .post(
            Uri.parse('$baseUrl$_generateEndpoint'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(timeout);

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['response'] as String?;
    } catch (_) {
      return null;
    }
  }

  SummaryResult _parseSummaryResponse(String response, int maxBullets) {
    try {
      final lines = response.split('\n').map((l) => l.trim()).toList();
      final sections = <SummarySectionResult>[];
      final bullets = <String>[];
      
      String currentTopic = '';
      String currentContent = '';
      List<String> currentBullets = [];

      for (final line in lines) {
        if (line.toUpperCase().startsWith('TOPIC:')) {
          if (currentTopic.isNotEmpty) {
            sections.add(SummarySectionResult(
              topic: currentTopic,
              content: currentContent,
              bullets: List.from(currentBullets),
            ));
          }
          currentTopic = line.substring(6).trim();
          currentContent = '';
          currentBullets = [];
        } else if (line.toUpperCase().startsWith('CONTENT:')) {
          currentContent = line.substring(8).trim();
        } else if (line.startsWith('-') || line.startsWith('•') || RegExp(r'^\d+\.').hasMatch(line)) {
          final cleaned = line.replaceFirst(RegExp(r'^[-•\d.]\s*'), '').trim();
          if (cleaned.isNotEmpty) {
            currentBullets.add(cleaned);
            if (bullets.length < maxBullets) bullets.add(cleaned);
          }
        } else if (line == '---') {
          continue;
        } else if (line.isNotEmpty) {
          if (currentTopic.isNotEmpty) {
            currentContent += (currentContent.isEmpty ? '' : ' ') + line;
          }
        }
      }

      if (currentTopic.isNotEmpty) {
        sections.add(SummarySectionResult(
          topic: currentTopic,
          content: currentContent,
          bullets: currentBullets,
        ));
      }

      final summary = bullets.join(' ');
      return SummaryResult(summary: summary, bullets: bullets, sections: sections);
    } catch (_) {
      return const SummaryResult(summary: '');
    }
  }

  List<Flashcard> _parseFlashcardResponse(
    String response,
    String? subject,
  ) {
    try {
      final pairs = response.split('---');
      final flashcards = <Flashcard>[];

      for (final pair in pairs) {
        final qMatch = RegExp(r'Q:\s*(.+?)(?=A:|$)', dotAll: true).firstMatch(pair);
        final aMatch = RegExp(r'A:\s*(.+?)$', dotAll: true).firstMatch(pair);

        final q = qMatch?.group(1)?.trim();
        final a = aMatch?.group(1)?.trim();

        if (q != null && q.isNotEmpty && a != null && a.isNotEmpty) {
          flashcards.add(Flashcard(
            question: q,
            answer: a,
            subject: subject,
          ));
        }
      }

      return flashcards;
    } catch (_) {
      return [];
    }
  }

  List<QuizQuestion> _parseQuizResponse(
    String response,
    String? subject,
    QuestionDifficulty difficulty,
  ) {
    try {
      final questions = response.split('---');
      final quizzes = <QuizQuestion>[];

      for (final q in questions) {
        final qMatch = RegExp(r'Q:\s*(.+?)(?=A\)|$)', dotAll: true).firstMatch(q);
        final aMatches = RegExp(r'([A-D])\)\s*(.+?)(?=[A-D]\)|CORRECT:|$)', dotAll: true)
            .allMatches(q);
        final correctMatch = RegExp(r'CORRECT:\s*([A-D])').firstMatch(q);
        final explanationMatch = RegExp(r'EXPLANATION:\s*(.+?)$', dotAll: true)
            .firstMatch(q);

        final questionText = qMatch?.group(1)?.trim();
        final options = <String>[];
        for (final match in aMatches) {
          options.add(match.group(2)?.trim() ?? '');
        }
        final correctLetter = correctMatch?.group(1);
        final explanation = explanationMatch?.group(1)?.trim();

        if (questionText != null &&
            questionText.isNotEmpty &&
            options.length == 4 &&
            correctLetter != null) {
          final correctIndex = _letterToIndex(correctLetter);
          quizzes.add(QuizQuestion(
            question: questionText,
            options: options,
            correctIndex: correctIndex,
            difficulty: difficulty,
            explanation: explanation,
            subject: subject,
          ));
        }
      }

      return quizzes;
    } catch (_) {
      return [];
    }
  }

  int _letterToIndex(String letter) {
    return switch (letter.toUpperCase()) {
      'A' => 0,
      'B' => 1,
      'C' => 2,
      'D' => 3,
      _ => 0,
    };
  }
}
