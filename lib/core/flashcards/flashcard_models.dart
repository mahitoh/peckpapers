class Flashcard {
  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    required this.subject,
    this.hint,
    this.createdAt,
  });

  final String id;
  final String question;
  final String answer;
  final String subject;
  final String? hint;
  final DateTime? createdAt;
}

class FlashcardDeck {
  const FlashcardDeck({
    required this.id,
    required this.title,
    required this.cards,
    required this.createdAt,
    this.docId,
  });

  final String id;
  final String title;
  final List<Flashcard> cards;
  final DateTime createdAt;
  final String? docId;
}

class ReviewLog {
  const ReviewLog({
    required this.cardId,
    required this.quality,
    required this.reviewedAt,
    required this.nextDue,
    required this.intervalDays,
    required this.easeFactor,
  });

  final String cardId;
  final int quality;
  final DateTime reviewedAt;
  final DateTime nextDue;
  final int intervalDays;
  final double easeFactor;
}
