import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'flashcard_models.dart';
import 'flashcard_repository.dart';

class LocalFlashcardRepository implements FlashcardRepository {
  LocalFlashcardRepository({SharedPreferences? prefs}) : _prefs = prefs;

  static final LocalFlashcardRepository instance = LocalFlashcardRepository();

  static const _deckKey = 'flashcard_decks';
  static const _logKey = 'flashcard_logs';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _store async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> saveDeck(FlashcardDeck deck) async {
    final decks = await fetchDecks();
    final index = decks.indexWhere((d) => d.id == deck.id);
    if (index >= 0) {
      decks[index] = deck;
    } else {
      decks.add(deck);
    }
    final prefs = await _store;
    final jsonList = decks.map(_deckToJson).toList();
    await prefs.setString(_deckKey, jsonEncode(jsonList));
  }

  @override
  Future<List<FlashcardDeck>> fetchDecks() async {
    final prefs = await _store;
    final jsonString = prefs.getString(_deckKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((e) => _deckFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<FlashcardDeck?> getDeckByDocId(String docId) async {
    final decks = await fetchDecks();
    try {
      return decks.firstWhere((d) => d.docId == docId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveReviewLog(ReviewLog log) async {
    final logs = await _fetchLogs();
    logs.add(log);
    final prefs = await _store;
    final jsonList = logs.map(_logToJson).toList();
    await prefs.setString(_logKey, jsonEncode(jsonList));
  }

  @override
  Future<List<ReviewLog>> fetchLogsForCard(String cardId) async {
    final logs = await _fetchLogs();
    return logs.where((log) => log.cardId == cardId).toList();
  }

  @override
  Future<List<ReviewLog>> fetchDueReviews(DateTime now) async {
    final logs = await _fetchLogs();
    return logs.where((log) => !log.nextDue.isAfter(now)).toList();
  }

  Future<List<ReviewLog>> _fetchLogs() async {
    final prefs = await _store;
    final jsonString = prefs.getString(_logKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((e) => _logFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> _deckToJson(FlashcardDeck deck) {
    return {
      'id': deck.id,
      'title': deck.title,
      'createdAt': deck.createdAt.toIso8601String(),
      'cards': deck.cards.map(_cardToJson).toList(),
      'docId': deck.docId,
    };
  }

  FlashcardDeck _deckFromJson(Map<String, dynamic> json) {
    return FlashcardDeck(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      docId: json['docId'] as String?,
      cards: (json['cards'] as List<dynamic>)
          .map((c) => _cardFromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> _cardToJson(Flashcard card) {
    return {
      'id': card.id,
      'question': card.question,
      'answer': card.answer,
      'subject': card.subject,
      'hint': card.hint,
      'createdAt': card.createdAt?.toIso8601String(),
    };
  }

  Flashcard _cardFromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      subject: json['subject'] as String,
      hint: json['hint'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> _logToJson(ReviewLog log) {
    return {
      'cardId': log.cardId,
      'quality': log.quality,
      'reviewedAt': log.reviewedAt.toIso8601String(),
      'nextDue': log.nextDue.toIso8601String(),
      'intervalDays': log.intervalDays,
      'easeFactor': log.easeFactor,
    };
  }

  ReviewLog _logFromJson(Map<String, dynamic> json) {
    return ReviewLog(
      cardId: json['cardId'] as String,
      quality: json['quality'] as int,
      reviewedAt: DateTime.parse(json['reviewedAt'] as String),
      nextDue: DateTime.parse(json['nextDue'] as String),
      intervalDays: json['intervalDays'] as int,
      easeFactor: (json['easeFactor'] as num).toDouble(),
    );
  }
}
